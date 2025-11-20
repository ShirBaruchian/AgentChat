"""
AI Agent Chat Backend
FastAPI application for handling chat requests and agent interactions
"""

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import os
from dotenv import load_dotenv

from routers import chat, agents, subscription, health
from core.config import settings
from core.firebase import initialize_firebase

# Load environment variables
load_dotenv()

# Initialize Firebase (optional - app will work without it for development)
try:
    firebase_initialized = initialize_firebase()
    if not firebase_initialized:
        print("Running without Firebase - some features will be disabled")
except Exception as e:
    print(f"Firebase initialization failed: {e}")
    print("Running without Firebase - some features will be disabled")

# Create FastAPI app
app = FastAPI(
    title="AI Agent Chat API",
    description="Backend API for AI Agent Chat Application",
    version="1.0.0",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, prefix="/health", tags=["health"])
app.include_router(chat.router, prefix="/api/chat", tags=["chat"])
app.include_router(agents.router, prefix="/api/agents", tags=["agents"])
app.include_router(subscription.router, prefix="/api/subscription", tags=["subscription"])


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "AI Agent Chat API",
        "version": "1.0.0",
        "status": "running"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )

