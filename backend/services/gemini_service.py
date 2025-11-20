"""Google Gemini API service"""
import google.generativeai as genai
from core.config import settings
from typing import Dict, Optional


class GeminiService:
    """Service for interacting with Google Gemini API"""
    
    def __init__(self):
        if not settings.GEMINI_API_KEY:
            raise ValueError(
                "GEMINI_API_KEY is not set. Please set it in your .env file. "
                "Get your API key from: https://aistudio.google.com/app/apikey"
            )
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
            error_msg = str(e)
            # Provide user-friendly error messages
            if "429" in error_msg or "quota" in error_msg.lower() or "rate limit" in error_msg.lower():
                # Extract retry time if available
                retry_time = None
                if "retry" in error_msg.lower():
                    import re
                    retry_match = re.search(r'retry.*?(\d+\.?\d*)\s*s', error_msg, re.IGNORECASE)
                    if retry_match:
                        retry_time = int(float(retry_match.group(1)))
                
                if retry_time:
                    return f"I apologize, but I've reached the API rate limit. Please try again in {retry_time} seconds. You may need to upgrade your Gemini API plan for higher limits."
                else:
                    return "I apologize, but I've reached the API rate limit. Please try again in a moment, or consider upgrading your Gemini API plan for higher limits."
            elif "ACCESS_TOKEN_SCOPE_INSUFFICIENT" in error_msg or "insufficient authentication scopes" in error_msg:
                return "I apologize, but there's an authentication error. Please check that the Gemini API key is properly configured in the backend."
            elif "API_KEY_INVALID" in error_msg or "invalid API key" in error_msg.lower():
                return "I apologize, but the API key is invalid. Please check the Gemini API key configuration."
            else:
                return f"I apologize, but I encountered an error: {error_msg}"
    
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

