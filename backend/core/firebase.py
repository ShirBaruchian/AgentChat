"""Firebase initialization and utilities"""
import firebase_admin
from firebase_admin import credentials, firestore, auth
import os
from pathlib import Path

from core.config import settings


def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    if not firebase_admin._apps:
        if settings.FIREBASE_CREDENTIALS_PATH:
            cred_path = Path(settings.FIREBASE_CREDENTIALS_PATH)
            if cred_path.exists():
                cred = credentials.Certificate(str(cred_path))
                firebase_admin.initialize_app(cred)
            else:
                print(f"Warning: Firebase credentials file not found: {cred_path}")
                print("Firebase features will be disabled. Set FIREBASE_CREDENTIALS_PATH to enable.")
                return False
        else:
            # Try to use default credentials (for Cloud Functions/Cloud Run)
            try:
                firebase_admin.initialize_app()
            except Exception as e:
                print(f"Warning: Firebase initialization failed: {e}")
                print("Firebase features will be disabled. Configure Firebase credentials to enable.")
                return False
    return True


def get_firestore_client():
    """Get Firestore client"""
    try:
        return firestore.client()
    except Exception as e:
        raise ValueError(
            f"Firestore not available: {str(e)}. "
            "Make sure Firebase is properly initialized with a project ID."
        )


def verify_firebase_token(token: str):
    """Verify Firebase ID token"""
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        raise ValueError(f"Invalid token: {str(e)}")

