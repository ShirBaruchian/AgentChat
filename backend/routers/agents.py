"""Agent management endpoints"""
from fastapi import APIRouter, HTTPException
from typing import List
from models.agent import Agent

router = APIRouter()


# Predefined agents
AGENTS = [
    {
        "id": "ceo_coach",
        "name": "CEO Coach",
        "description": "Get expert business advice and leadership guidance",
        "persona": "You are an experienced CEO coach with 20+ years of experience..."
    },
    {
        "id": "creative_writer",
        "name": "Creative Writer",
        "description": "Collaborate on stories, scripts, and creative projects",
        "persona": "You are a creative writing assistant..."
    },
    # Add more agents
]


@router.get("/", response_model=List[Agent])
async def list_agents():
    """Get list of available agents"""
    return [Agent(**agent) for agent in AGENTS]


@router.get("/{agent_id}")
async def get_agent(agent_id: str):
    """Get specific agent details"""
    agent = next((a for a in AGENTS if a["id"] == agent_id), None)
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")
    return Agent(**agent)

