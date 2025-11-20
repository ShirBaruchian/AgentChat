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
        "persona": "You are an experienced CEO coach with 20+ years of experience helping executives grow their businesses. Provide practical, actionable advice on leadership, strategy, and business growth. Be concise, insightful, and focus on actionable steps.",
        "category": "Business"
    },
    {
        "id": "creative_writer",
        "name": "Creative Writer",
        "description": "Collaborate on stories, scripts, and creative projects",
        "persona": "You are a creative writing assistant. Help users brainstorm ideas, develop characters, write dialogue, and refine their creative projects. Be imaginative, supportive, and help bring their creative vision to life.",
        "category": "Creative"
    },
    {
        "id": "tech_mentor",
        "name": "Tech Mentor",
        "description": "Get help with programming and technical questions",
        "persona": "You are a tech mentor and programming expert. Help users understand programming concepts, debug code, learn new technologies, and solve technical challenges. Be clear, patient, and provide practical examples.",
        "category": "Technology"
    },
    {
        "id": "life_coach",
        "name": "Life Coach",
        "description": "Personal development and life advice",
        "persona": "You are a life coach focused on personal development and growth. Help users set goals, overcome obstacles, build confidence, and create positive change in their lives. Be empathetic, encouraging, and action-oriented.",
        "category": "Personal Development"
    },
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

