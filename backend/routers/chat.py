"""Chat endpoints"""
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, HTTPException
from typing import List
import json
from google.cloud import firestore

from core.firebase import verify_firebase_token, get_firestore_client
from services.gemini_service import GeminiService
from services.rate_limiter import RateLimiter
from services.token_service import get_token_service

router = APIRouter()
gemini_service = GeminiService()

# Lazy initialization - will be created on first use
_rate_limiter = None

def get_rate_limiter():
    """Get rate limiter instance (lazy initialization)"""
    global _rate_limiter
    if _rate_limiter is None:
        _rate_limiter = RateLimiter()
    return _rate_limiter


class ConnectionManager:
    """Manages WebSocket connections"""
    
    def __init__(self):
        self.active_connections: List[WebSocket] = []
    
    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
    
    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)
    
    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)
    
    async def broadcast(self, message: str):
        for connection in self.active_connections:
            await connection.send_text(message)


manager = ConnectionManager()


@router.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: str):
    """WebSocket endpoint for real-time chat"""
    await manager.connect(websocket)
    
    try:
        while True:
            data = await websocket.receive_text()
            message_data = json.loads(data)
            
            # Verify user has access (check subscription, rate limits, etc.)
            # For now, simplified version
            
            # Get agent response from Gemini
            agent_id = message_data.get("agent_id")
            user_message = message_data.get("message")
            
            if not agent_id or not user_message:
                await websocket.send_text(json.dumps({
                    "error": "Missing agent_id or message"
                }))
                continue
            
            # Check rate limits
            if not await get_rate_limiter().check_limit(user_id):
                await websocket.send_text(json.dumps({
                    "error": "Rate limit exceeded. Please upgrade your plan."
                }))
                continue
            
            # Get agent response
            response = await gemini_service.get_agent_response(
                agent_id=agent_id,
                user_message=user_message,
                user_id=user_id
            )
            
            # Save to Firestore
            db = get_firestore_client()
            db.collection("messages").add({
                "user_id": user_id,
                "agent_id": agent_id,
                "message": user_message,
                "response": response,
                "timestamp": firestore.SERVER_TIMESTAMP,
            })
            
            # Update rate limiter
            await get_rate_limiter().increment_usage(user_id)
            
            # Send response
            await websocket.send_text(json.dumps({
                "agent_id": agent_id,
                "response": response,
            }))
            
    except WebSocketDisconnect:
        manager.disconnect(websocket)


@router.post("/message")
async def send_message(message_data: dict):
    """HTTP endpoint for sending messages (fallback)"""
    try:
        user_id = message_data.get("user_id")
        agent_id = message_data.get("agent_id")
        user_message = message_data.get("message")
        conversation_history = message_data.get("conversation_history", [])
        
        if not user_id or not agent_id or not user_message:
            raise HTTPException(
                status_code=400,
                detail="Missing required fields: user_id, agent_id, or message"
            )
        
        # Check tokens (each message = 1 token)
        token_service = get_token_service()
        can_use_token = await token_service.can_use_token(user_id)
        
        if not can_use_token:
            # Get token status for error message
            token_status = await token_service.get_token_status(user_id)
            raise HTTPException(
                status_code=429,
                detail=f"Free tokens exhausted. You've used {token_status['tokens_used']}/{token_status['tokens_limit']} tokens. Upgrade to Premium for unlimited messages."
            )
        
        # Use a token before processing the message
        token_used = await token_service.use_token(user_id)
        if not token_used:
            raise HTTPException(
                status_code=429,
                detail="Unable to use token. Please try again or upgrade to Premium."
            )
        
        # Get agent response
        response = await gemini_service.get_agent_response(
            agent_id=agent_id,
            user_message=user_message,
            user_id=user_id,
            conversation_history=conversation_history
        )
        
        # Save to Firestore (optional - don't fail if Firestore not configured)
        try:
            db = get_firestore_client()
            db.collection("messages").add({
                "user_id": user_id,
                "agent_id": agent_id,
                "message": user_message,
                "response": response,
                "timestamp": firestore.SERVER_TIMESTAMP,
            })
        except Exception as e:
            # Log but don't fail if Firestore isn't configured
            error_str = str(e)
            # Check for database existence error FIRST (most common after API is enabled)
            if "does not exist" in error_str or ("404" in error_str and "database" in error_str.lower()):
                # Database doesn't exist - need to create it
                if not hasattr(send_message, '_firestore_db_warning_logged'):
                    print("⚠️  Firestore database doesn't exist. Messages won't be persisted. Create database at: https://console.firebase.google.com/project/agentchat-f7eb8/firestore")
                    send_message._firestore_db_warning_logged = True
            elif "SERVICE_DISABLED" in error_str or ("firestore.googleapis.com" in error_str and "not been used" in error_str):
                # API not enabled
                if not hasattr(send_message, '_firestore_warning_logged'):
                    print("⚠️  Firestore API not enabled. Messages won't be persisted. Enable at: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=agentchat-f7eb8")
                    send_message._firestore_warning_logged = True
            else:
                # Other errors - log once
                if not hasattr(send_message, '_firestore_other_warning_logged'):
                    print(f"⚠️  Failed to save message to Firestore (continuing anyway): {e}")
                    send_message._firestore_other_warning_logged = True
        
        # Update rate limiter (optional)
        try:
            await get_rate_limiter().increment_usage(user_id)
        except Exception as e:
            print(f"Failed to update rate limiter (continuing anyway): {e}")
        
        return {
            "agent_id": agent_id,
            "response": response,
            "user_id": user_id,
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

