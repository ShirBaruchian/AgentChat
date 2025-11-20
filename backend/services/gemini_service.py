"""Google Gemini API service"""
import google.generativeai as genai
from core.config import settings
from typing import Dict, Optional


class GeminiService:
    """Service for interacting with Google Gemini API"""
    
    def __init__(self):
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel(settings.GEMINI_MODEL)
    
    async def get_agent_response(
        self,
        agent_id: str,
        user_message: str,
        user_id: str,
        conversation_history: Optional[list] = None
    ) -> str:
        """
        Get response from Gemini API with agent persona
        
        Args:
            agent_id: ID of the agent persona
            user_message: User's message
            user_id: User ID for context
            conversation_history: Previous messages in conversation
            
        Returns:
            Agent's response text
        """
        # Get agent persona (in production, fetch from database)
        agent_persona = self._get_agent_persona(agent_id)
        
        # Build conversation context
        prompt = self._build_prompt(
            agent_persona=agent_persona,
            user_message=user_message,
            conversation_history=conversation_history or []
        )
        
        # Generate response
        try:
            response = self.model.generate_content(prompt)
            return response.text
        except Exception as e:
            return f"I apologize, but I encountered an error: {str(e)}"
    
    def _get_agent_persona(self, agent_id: str) -> str:
        """Get system prompt for agent persona"""
        personas = {
            "ceo_coach": """You are an experienced CEO coach with 20+ years of experience 
            helping executives grow their businesses. Provide practical, actionable advice 
            on leadership, strategy, and business growth.""",
            "creative_writer": """You are a creative writing assistant. Help users 
            brainstorm ideas, develop characters, write dialogue, and refine their 
            creative projects.""",
        }
        return personas.get(agent_id, "You are a helpful AI assistant.")
    
    def _build_prompt(
        self,
        agent_persona: str,
        user_message: str,
        conversation_history: list
    ) -> str:
        """Build the full prompt with persona and conversation history"""
        prompt_parts = [agent_persona]
        
        # Add conversation history
        for msg in conversation_history[-10:]:  # Last 10 messages
            prompt_parts.append(f"User: {msg.get('user_message', '')}")
            prompt_parts.append(f"Assistant: {msg.get('response', '')}")
        
        # Add current message
        prompt_parts.append(f"User: {user_message}")
        prompt_parts.append("Assistant:")
        
        return "\n".join(prompt_parts)

