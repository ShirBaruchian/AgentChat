"""Rate limiting service"""
from datetime import datetime, timedelta
from core.config import settings
from core.firebase import get_firestore_client
from typing import Dict


class RateLimiter:
    """Service for checking and enforcing rate limits"""
    
    def __init__(self):
        self.db = get_firestore_client()
    
    async def check_limit(self, user_id: str) -> bool:
        """
        Check if user has remaining message quota
        
        Returns:
            True if user can send message, False otherwise
        """
        # Get user's subscription tier
        subscription = await self._get_subscription(user_id)
        
        if not subscription:
            return False
        
        # Get message count for current period
        period_start = self._get_period_start(subscription.get("tier", "weekly"))
        message_count = await self._get_message_count(user_id, period_start)
        
        # Check against limit
        limit = self._get_limit_for_tier(subscription.get("tier", "weekly"))
        
        return message_count < limit
    
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

