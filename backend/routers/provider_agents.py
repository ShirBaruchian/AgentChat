"""Provider Agent endpoints - AI models from different providers"""
from fastapi import APIRouter, Query
from typing import List, Optional
from models.provider_agent import ProviderAgent

router = APIRouter()


# Predefined provider agents (AI models)
PROVIDER_AGENTS = [
    # Auto mode
    {
        "id": "auto",
        "name": "Auto Select",
        "description": "Automatically chooses the best model",
        "provider": "auto",
        "model_id": "auto",
        "is_default": True,
    },
    
    # OpenAI Agents
    {
        "id": "openai-gpt-4",
        "name": "GPT-4",
        "description": "Most capable model, best for complex tasks",
        "provider": "openai",
        "model_id": "gpt-4",
        "is_default": False,
    },
    {
        "id": "openai-gpt-4-turbo",
        "name": "GPT-4 Turbo",
        "description": "Faster GPT-4, great balance",
        "provider": "openai",
        "model_id": "gpt-4-turbo",
        "is_default": False,
    },
    {
        "id": "openai-gpt-3.5-turbo",
        "name": "GPT-3.5 Turbo",
        "description": "Fast and cost-effective",
        "provider": "openai",
        "model_id": "gpt-3.5-turbo",
        "is_default": True,
    },
    
    # Claude Agents
    {
        "id": "claude-opus",
        "name": "Claude Opus",
        "description": "Most powerful Claude model",
        "provider": "claude",
        "model_id": "claude-3-opus-20240229",
        "is_default": False,
    },
    {
        "id": "claude-sonnet",
        "name": "Claude Sonnet",
        "description": "Balanced performance and speed",
        "provider": "claude",
        "model_id": "claude-3-sonnet-20240229",
        "is_default": True,
    },
    {
        "id": "claude-haiku",
        "name": "Claude Haiku",
        "description": "Fastest Claude model",
        "provider": "claude",
        "model_id": "claude-3-haiku-20240307",
        "is_default": False,
    },
    
    # Gemini Agents
    {
        "id": "gemini-ultra",
        "name": "Gemini Ultra",
        "description": "Most advanced Gemini model",
        "provider": "gemini",
        "model_id": "gemini-ultra",
        "is_default": False,
    },
    {
        "id": "gemini-pro",
        "name": "Gemini Pro",
        "description": "Best for most tasks",
        "provider": "gemini",
        "model_id": "gemini-pro",
        "is_default": True,
    },
    {
        "id": "gemini-flash",
        "name": "Gemini Flash",
        "description": "Fast and efficient",
        "provider": "gemini",
        "model_id": "gemini-flash",
        "is_default": False,
    },
]


@router.get("/", response_model=List[ProviderAgent])
async def list_provider_agents(
    provider: Optional[str] = Query(None, description="Filter by provider (auto, openai, claude, gemini)")
):
    """
    Get list of available provider agents (AI models)
    
    Args:
        provider: Optional filter by provider name
        
    Returns:
        List of provider agents
    """
    if provider:
        # Filter by provider
        filtered = [
            ProviderAgent(**agent) 
            for agent in PROVIDER_AGENTS 
            if agent["provider"].lower() == provider.lower()
        ]
        return filtered
    
    # Return all provider agents
    return [ProviderAgent(**agent) for agent in PROVIDER_AGENTS]


@router.get("/{agent_id}", response_model=ProviderAgent)
async def get_provider_agent(agent_id: str):
    """
    Get specific provider agent by ID
    
    Args:
        agent_id: Provider agent ID
        
    Returns:
        Provider agent details
    """
    agent = next((a for a in PROVIDER_AGENTS if a["id"] == agent_id), None)
    if not agent:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Provider agent not found")
    return ProviderAgent(**agent)

