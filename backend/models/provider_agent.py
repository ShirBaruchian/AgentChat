"""Provider Agent models"""
from pydantic import BaseModel
from typing import Optional


class ProviderAgent(BaseModel):
    """Provider Agent model - represents AI models from different providers"""
    id: str
    name: str
    description: str
    provider: str  # 'auto', 'openai', 'claude', 'gemini'
    model_id: str  # e.g., 'gpt-4', 'claude-3-opus', 'gemini-pro'
    is_default: bool = False

    class Config:
        json_schema_extra = {
            "example": {
                "id": "openai-gpt-4",
                "name": "GPT-4",
                "description": "Most capable model, best for complex tasks",
                "provider": "openai",
                "model_id": "gpt-4",
                "is_default": False
            }
        }

