"""Rate limiting service"""
from datetime import datetime, timedelta
from core.config import settings
from core.firebase import get_firestore_client
from typing import Dict


class RateLimiter:
    """Service for checking and enforcing rate limits"""
    
    def __init__(self):
        self._db = None
    
    @property
    def db(self):
        """Lazy initialization of Firestore client"""
        if self._db is None:
            try:
                self._db = get_firestore_client()
            except Exception as e:
                # Firestore not available - return None to indicate unavailable
                if "SERVICE_DISABLED" in str(e) or "firestore.googleapis.com" in str(e):
                    print("⚠️  Firestore API not enabled. Rate limiting disabled. Enable at: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=agentchat-f7eb8")
                raise
        return self._db
    
    async def check_limit(self, user_id: str) -> bool:
        """
        Check if user has remaining message quota
        
        Returns:
            True if user can send message, False otherwise
        """
        try:
            # Try to get Firestore client - if it fails, allow messages
            try:
                db = self.db
            except Exception:
                # Firestore not available - allow messages
                return True
            
            # Get user's subscription tier
            subscription = await self._get_subscription(user_id)
            
            # If no subscription found, allow messages (for development/testing)
            # In production, you'd want to check subscription status
            if not subscription:
                return True  # Allow for now - implement subscription check later
            
            # Get message count for current period
            period_start = self._get_period_start(subscription.get("tier", "weekly"))
            message_count = await self._get_message_count(user_id, period_start)
            
            # Check against limit
            limit = self._get_limit_for_tier(subscription.get("tier", "weekly"))
            
            return message_count < limit
        except Exception as e:
            # If there's an error checking limits, allow the message
            # Only log if it's not a known Firestore disabled error
            if "SERVICE_DISABLED" not in str(e) and "firestore.googleapis.com" not in str(e):
                print(f"Error checking rate limit: {e}")
            return True
    
    async def _get_subscription(self, user_id: str) -> Dict:
        """Get user's subscription info"""
        doc = self.db.collection("subscriptions").document(user_id).get()
        if doc.exists:
            return doc.to_dict()
        return None
    
    def _get_period_start(self, tier: str) -> datetime:
        """Get start of current billing period"""
        now = datetime.utcnow()
        if tier == "weekly":
            return now - timedelta(days=now.weekday())
        elif tier == "monthly":
            return now.replace(day=1)
        elif tier == "annual":
            return now.replace(month=1, day=1)
        return now
    
    async def _get_message_count(self, user_id: str, period_start: datetime) -> int:
        """Get message count for user in current period"""
        messages_ref = self.db.collection("messages")
        query = messages_ref.where("user_id", "==", user_id).where(
            "timestamp", ">=", period_start
        )
        docs = query.stream()
        return sum(1 for _ in docs)
    
    def _get_limit_for_tier(self, tier: str) -> int:
        """Get message limit for subscription tier"""
        limits = {
            "weekly": settings.MESSAGE_RATE_LIMIT,
            "monthly": settings.MESSAGE_RATE_LIMIT * 4,
            "annual": float("inf"),  # Unlimited
        }
        return limits.get(tier, settings.MESSAGE_RATE_LIMIT)
    
    async def increment_usage(self, user_id: str):
        """Increment message usage counter for user"""
        # This would typically update a counter in Firestore
        # For now, it's a placeholder
        pass

