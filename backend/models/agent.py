"""Agent models"""
from pydantic import BaseModel
from typing import Optional


class Agent(BaseModel):
    """Agent model"""
    id: str
    name: str
    description: str
    persona: str
    avatar_url: Optional[str] = None
    category: Optional[str] = None

