# Backend Integration Guide

This document describes the integration between the Flutter mobile app and the FastAPI backend.

## Overview

The mobile app now communicates with the backend API for:
- **Chat Messages**: Sending messages and receiving AI agent responses
- **Agents**: Fetching available AI agents
- **Authentication**: Using Firebase Auth tokens for API authentication

## Architecture

```
Mobile App (Flutter)
    ↓ HTTP/REST API
Backend (FastAPI)
    ↓
Gemini API (AI Responses)
    ↓
Firestore (Message Storage)
```

## API Endpoints

### 1. Chat Messages
- **Endpoint**: `POST /api/chat/message`
- **Authentication**: Firebase ID token in `Authorization: Bearer <token>` header
- **Request Body**:
  ```json
  {
    "user_id": "firebase_user_id",
    "agent_id": "ceo_coach",
    "message": "User's message text",
    "conversation_history": [
      {"user_message": "Previous message"},
      {"response": "Previous response"}
    ]
  }
  ```
- **Response**:
  ```json
  {
    "agent_id": "ceo_coach",
    "response": "AI agent's response",
    "user_id": "firebase_user_id"
  }
  ```

### 2. Get Agents
- **Endpoint**: `GET /api/agents`
- **Authentication**: Firebase ID token (optional for now)
- **Response**: Array of agent objects
  ```json
  [
    {
      "id": "ceo_coach",
      "name": "CEO Coach",
      "description": "Get expert business advice...",
      "persona": "You are an experienced CEO coach...",
      "category": "Business"
    }
  ]
  ```

### 3. Subscription Status
- **Endpoint**: `GET /api/subscription/status/{user_id}`
- **Authentication**: Firebase ID token
- **Response**: Subscription information

## Configuration

### Mobile App Configuration

The backend URL is configured in `mobile/lib/core/config/api_config.dart`:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);
```

**For Development:**
- Local backend: `http://localhost:8000` (for iOS Simulator)
- Android Emulator: `http://10.0.2.2:8000`
- Physical device: `http://<your-computer-ip>:8000`

**For Production:**
Set the `API_BASE_URL` environment variable when building:
```bash
flutter build apk --dart-define=API_BASE_URL=https://your-api-domain.com
```

### Backend Configuration

Update `backend/core/config.py` to restrict CORS origins in production:

```python
ALLOWED_ORIGINS: List[str] = [
    "https://your-app-domain.com",  # Production domain
    # Remove "*" in production
]
```

## Authentication Flow

1. User signs in with Firebase Auth in the mobile app
2. Mobile app gets Firebase ID token: `await user.getIdToken()`
3. Token is sent in `Authorization: Bearer <token>` header
4. Backend verifies token using Firebase Admin SDK
5. Backend processes request with authenticated user ID

## Running the Integration

### 1. Start the Backend

```bash
cd backend
# Install dependencies
pip install -r requirements.txt

# Set environment variables in .env file
GEMINI_API_KEY=your_gemini_api_key
FIREBASE_CREDENTIALS_PATH=path/to/firebase-credentials.json
FIREBASE_PROJECT_ID=your-project-id

# Run the server
python main.py
# Or with uvicorn directly
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 2. Update Mobile App Configuration

For iOS Simulator:
- No changes needed (uses `localhost:8000`)

For Android Emulator:
- Update `api_config.dart` to use `http://10.0.2.2:8000`

For Physical Device:
- Update `api_config.dart` to use `http://<your-computer-ip>:8000`
- Ensure your computer and device are on the same network
- Check firewall settings

### 3. Run the Mobile App

```bash
cd mobile
flutter pub get
flutter run
```

## Testing

### Test Backend Health
```bash
curl http://localhost:8000/health
```

### Test Agents Endpoint
```bash
curl http://localhost:8000/api/agents
```

### Test Chat Endpoint (with auth token)
```bash
curl -X POST http://localhost:8000/api/chat/message \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -d '{
    "user_id": "test_user",
    "agent_id": "ceo_coach",
    "message": "Hello, how can you help me?"
  }'
```

## Error Handling

The mobile app handles these error cases:
- **Network errors**: Shows user-friendly error message
- **Rate limiting (429)**: Shows "Rate limit exceeded" message
- **Authentication errors**: Prompts user to sign in again
- **Server errors (500)**: Shows generic error with retry option

## Next Steps

1. **WebSocket Support**: Implement WebSocket connection for real-time chat (currently using HTTP)
2. **Message History**: Fetch previous messages from Firestore
3. **Subscription Verification**: Implement App Store/Play Store receipt verification
4. **Rate Limiting UI**: Show remaining messages to user
5. **Offline Support**: Cache messages and sync when online

## Troubleshooting

### "Network error" in mobile app
- Check backend is running: `curl http://localhost:8000/health`
- Check CORS settings in backend
- Verify API URL in `api_config.dart`
- For physical device, ensure correct IP address

### "Rate limit exceeded"
- Check rate limiter configuration in backend
- Verify user subscription status

### "Failed to load agents"
- Check backend `/api/agents` endpoint
- Verify network connectivity
- Check backend logs for errors

### Authentication issues
- Ensure Firebase is properly configured
- Verify Firebase ID token is being sent
- Check backend Firebase Admin SDK setup


