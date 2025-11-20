"""Subscription models"""
from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class SubscriptionStatus(BaseModel):
    """Subscription status model"""
    user_id: str
    status: str  # active, expired, cancelled
    tier: str  # weekly, monthly, annual
    messages_remaining: int
    reset_date: datetime
    purchase_date: Optional[datetime] = None

