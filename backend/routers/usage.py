"""Usage/Token tracking endpoints"""
from fastapi import APIRouter, HTTPException, Depends
from typing import Optional
from services.token_service import get_token_service

router = APIRouter()


@router.get("/status/{user_id}")
async def get_usage_status(user_id: str):
    """
    Get token/usage status for a user
    Returns: {
        'tokens_remaining': int,  # -1 for premium (unlimited)
        'tokens_used': int,
        'tokens_limit': int,
        'is_premium': bool,
        'reset_date': Optional[str]
    }
    """
    try:
        token_service = get_token_service()
        status = await token_service.get_token_status(user_id)
        
        # Convert datetime to ISO string if present
        if status.get('reset_date'):
            reset_date = status['reset_date']
            if hasattr(reset_date, 'isoformat'):
                status['reset_date'] = reset_date.isoformat()
            else:
                status['reset_date'] = str(reset_date)
        
        return status
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to get usage status: {str(e)}"
        )


@router.post("/reset/{user_id}")
async def reset_tokens(user_id: str):
    """
    Reset tokens for a user (admin/testing endpoint)
    Note: In production, this should be protected or removed
    """
    try:
        token_service = get_token_service()
        # This will reset tokens on next status check
        # For immediate reset, we'd need to add a method
        status = await token_service.get_token_status(user_id)
        return {
            "message": "Tokens will be reset on next check",
            "current_status": status
        }
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to reset tokens: {str(e)}"
        )

