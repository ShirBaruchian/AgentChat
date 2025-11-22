"""Token/Usage tracking service - tracks free tokens per user"""
from typing import Optional
from datetime import datetime, timedelta
from google.cloud import firestore
from core.firebase import get_firestore_client

# Constants
FREE_TOKENS_LIMIT = 6
TOKEN_RESET_INTERVAL_DAYS = 7  # Reset tokens weekly for free users


class TokenService:
    """Service to track and manage user tokens"""
    
    def __init__(self):
        self._db = None
    
    def _get_db(self):
        """Get Firestore client (lazy initialization)"""
        if self._db is None:
            self._db = get_firestore_client()
        return self._db
    
    async def get_token_status(self, user_id: str) -> dict:
        """
        Get current token status for a user
        Returns: {
            'tokens_remaining': int,
            'tokens_used': int,
            'tokens_limit': int,
            'is_premium': bool,
            'reset_date': Optional[datetime]
        }
        """
        try:
            print(f"🔍 TokenService: Getting token status for user_id: {user_id}")
            db = self._get_db()
            user_doc_ref = db.collection("users").document(user_id)
            user_doc = user_doc_ref.get()
            
            if not user_doc.exists:
                # New user - initialize with free tokens
                await self._initialize_user(user_id)
                return {
                    'tokens_remaining': FREE_TOKENS_LIMIT,
                    'tokens_used': 0,
                    'tokens_limit': FREE_TOKENS_LIMIT,
                    'is_premium': False,
                    'reset_date': None,
                }
            
            user_data = user_doc.to_dict()
            is_premium = user_data.get('is_premium', False)
            tokens_used = user_data.get('tokens_used', 0)
            last_reset = user_data.get('last_reset')
            
            # Check if tokens should be reset (weekly reset for free users)
            if not is_premium and last_reset:
                last_reset_date = last_reset
                if isinstance(last_reset_date, datetime):
                    # Handle both timezone-aware and naive datetimes
                    now = datetime.now(last_reset_date.tzinfo) if last_reset_date.tzinfo else datetime.now()
                    # Make both timezone-aware or both naive
                    if last_reset_date.tzinfo and not now.tzinfo:
                        now = datetime.now(last_reset_date.tzinfo)
                    elif not last_reset_date.tzinfo and now.tzinfo:
                        now = datetime.now()
                    
                    days_since_reset = (now - last_reset_date).days
                    if days_since_reset >= TOKEN_RESET_INTERVAL_DAYS:
                        # Reset tokens
                        await self._reset_tokens(user_id)
                        tokens_used = 0
            
            tokens_remaining = 0 if is_premium else max(0, FREE_TOKENS_LIMIT - tokens_used)
            
            return {
                'tokens_remaining': tokens_remaining if not is_premium else -1,  # -1 = unlimited
                'tokens_used': tokens_used,
                'tokens_limit': FREE_TOKENS_LIMIT,
                'is_premium': is_premium,
                'reset_date': last_reset,
            }
        except Exception as e:
            # Return default values on error
            return {
                'tokens_remaining': FREE_TOKENS_LIMIT,
                'tokens_used': 0,
                'tokens_limit': FREE_TOKENS_LIMIT,
                'is_premium': False,
                'reset_date': None,
            }
    
    async def can_use_token(self, user_id: str) -> bool:
        """Check if user can use a token (has tokens remaining or is premium)"""
        try:
            status = await self.get_token_status(user_id)
            # Premium users have unlimited tokens
            if status['is_premium']:
                return True
            # Free users need tokens remaining
            return status['tokens_remaining'] > 0
        except Exception as e:
            print(f"Error checking token availability: {e}")
            # On error, allow (fail open for development)
            return True
    
    async def use_token(self, user_id: str) -> bool:
        """
        Use a token (decrement token count)
        Returns True if token was used, False if no tokens available
        """
        try:
            db = self._get_db()
            user_doc_ref = db.collection("users").document(user_id)
            user_doc = user_doc_ref.get()
            
            if not user_doc.exists:
                await self._initialize_user(user_id)
                user_doc = user_doc_ref.get()
            
            user_data = user_doc.to_dict() if user_doc.exists else {}
            is_premium = user_data.get('is_premium', False)
            
            # Premium users have unlimited tokens - don't decrement
            if is_premium:
                return True
            
            tokens_used = user_data.get('tokens_used', 0)
            
            # Check if user has tokens remaining
            if tokens_used >= FREE_TOKENS_LIMIT:
                return False
            
            # Increment tokens used
            tokens_used += 1
            user_doc_ref.set({
                'tokens_used': tokens_used,
                'last_used': firestore.SERVER_TIMESTAMP,
                'updated_at': firestore.SERVER_TIMESTAMP,
            }, merge=True)
            
            return True
        except Exception as e:
            # On error, allow (fail open for development)
            return True
    
    async def _initialize_user(self, user_id: str):
        """Initialize user document with default token values"""
        try:
            db = self._get_db()
            user_doc_ref = db.collection("users").document(user_id)
            user_doc_ref.set({
                'user_id': user_id,
                'tokens_used': 0,
                'tokens_limit': FREE_TOKENS_LIMIT,
                'is_premium': False,
                'created_at': firestore.SERVER_TIMESTAMP,
                'last_reset': firestore.SERVER_TIMESTAMP,
                'updated_at': firestore.SERVER_TIMESTAMP,
            })
        except Exception as e:
            print(f"Error initializing user: {e}")
    
    async def _reset_tokens(self, user_id: str):
        """Reset tokens for a user (weekly reset for free users)"""
        try:
            db = self._get_db()
            user_doc_ref = db.collection("users").document(user_id)
            user_doc_ref.set({
                'tokens_used': 0,
                'last_reset': firestore.SERVER_TIMESTAMP,
                'updated_at': firestore.SERVER_TIMESTAMP,
            }, merge=True)
        except Exception as e:
            print(f"Error resetting tokens: {e}")
    
    async def set_premium_status(self, user_id: str, is_premium: bool):
        """Update user's premium status"""
        try:
            db = self._get_db()
            user_doc_ref = db.collection("users").document(user_id)
            user_doc_ref.set({
                'is_premium': is_premium,
                'updated_at': firestore.SERVER_TIMESTAMP,
            }, merge=True)
            
            # Reset tokens when upgrading to premium
            if is_premium:
                await self._reset_tokens(user_id)
        except Exception as e:
            print(f"Error setting premium status: {e}")


# Global instance
_token_service = None

def get_token_service() -> TokenService:
    """Get token service instance (singleton)"""
    global _token_service
    if _token_service is None:
        _token_service = TokenService()
    return _token_service

