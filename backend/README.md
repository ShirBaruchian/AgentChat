# Backend (Python FastAPI)

Backend API for the AI Agent Chat application.

## Setup

1. **Create virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Run the server:**
   ```bash
   uvicorn main:app --reload
   ```

## Environment Variables

Create a `.env` file with:

```env
# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CREDENTIALS_PATH=path/to/service-account-key.json

# Gemini API
GEMINI_API_KEY=your-gemini-api-key
GEMINI_MODEL=gemini-2.0-flash-exp

# App Settings
DEBUG=True
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

## Project Structure

```
backend/
├── main.py                 # FastAPI app entry point
├── core/                   # Core functionality
│   ├── config.py          # Configuration
│   └── firebase.py        # Firebase setup
├── routers/               # API routes
│   ├── chat.py           # Chat endpoints
│   ├── agents.py         # Agent management
│   ├── subscription.py   # Subscription handling
│   └── health.py         # Health checks
├── services/             # Business logic
│   ├── gemini_service.py
│   └── rate_limiter.py
├── models/               # Pydantic models
└── tests/                # Tests
```

## API Endpoints

- `GET /` - Root endpoint
- `GET /health` - Health check
- `WS /api/chat/ws/{user_id}` - WebSocket for real-time chat
- `GET /api/agents/` - List all agents
- `GET /api/subscription/status/{user_id}` - Get subscription status

## Deployment

### Google Cloud Functions

```bash
gcloud functions deploy ai-agent-chat-api \
  --runtime python311 \
  --trigger http \
  --allow-unauthenticated
```

### Google Cloud Run

```bash
gcloud run deploy ai-agent-chat-api \
  --source . \
  --platform managed \
  --region us-central1
```

