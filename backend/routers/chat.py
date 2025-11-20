"""Chat endpoints"""
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, HTTPException
from typing import List
import json
from google.cloud import firestore

from core.firebase import verify_firebase_token, get_firestore_client
from services.gemini_service import GeminiService
from services.rate_limiter import RateLimiter

router = APIRouter()
gemini_service = GeminiService()
rate_limiter = RateLimiter()


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
            if not await rate_limiter.check_limit(user_id):
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
            await rate_limiter.increment_usage(user_id)
            
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
    # Similar logic to WebSocket but returns response directly
    pass

