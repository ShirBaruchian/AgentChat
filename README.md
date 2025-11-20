# AI Agent Chat Application

A cross-platform AI chat application with multiple agent personas, built with Flutter (mobile) and Python FastAPI (backend).

## Project Structure

```
ai-agent-chat/
├── mobile/              # Flutter mobile app (iOS & Android)
├── backend/            # Python FastAPI backend
├── functions/          # Serverless functions (Firebase/Cloud Functions)
├── docs/               # Documentation
└── scripts/            # Deployment and utility scripts
```

## Technology Stack

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: Provider/Riverpod
- **Real-time**: Firebase Firestore streams
- **Authentication**: Firebase Auth
- **In-App Purchases**: 
  - iOS: StoreKit 2
  - Android: Google Play Billing Library

### Backend
- **Framework**: Python FastAPI
- **Real-time**: WebSockets
- **Database**: Firebase Firestore
- **AI/LLM**: Google Gemini API
- **Deployment**: Google Cloud Functions / Cloud Run

## Getting Started

### Prerequisites

1. **Flutter SDK** (3.x or later)
   ```bash
   flutter --version
   ```

2. **Python** (3.11 or later)
   ```bash
   python --version
   ```

3. **Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

4. **Google Cloud SDK** (for deployment)
   ```bash
   gcloud --version
   ```

### Setup Instructions

See individual README files in each directory:
- [Mobile App Setup](./mobile/README.md)
- [Backend Setup](./backend/README.md)
- [Functions Setup](./functions/README.md)

## Monetization

- **Free Trial**: 7-day free trial (credit card required)
- **Subscription**: Weekly auto-renewable subscriptions
- **Pricing Tiers**: 
  - Weekly: Base tier (500 messages/week)
  - Monthly: Higher tier (unlimited messages)
  - Annual: Best value (unlimited + premium features)

## Development Workflow

1. **Local Development**
   - Run Flutter app: `cd mobile && flutter run`
   - Run FastAPI backend: `cd backend && uvicorn main:app --reload`
   - Use Firebase Emulator Suite for local testing

2. **Testing**
   - Unit tests: `flutter test` / `pytest`
   - Integration tests: Firebase Test Lab

3. **Deployment**
   - Mobile: Build and submit via Xcode/Android Studio
   - Backend: Deploy to Cloud Functions/Cloud Run
   - Database: Configure Firestore rules and indexes

## Key Features

- ✅ Multi-agent personas (CEO Coach, Fictional Characters, etc.)
- ✅ Real-time chat with WebSocket support
- ✅ Subscription management with App Store/Play Store billing
- ✅ Rate limiting and usage tracking
- ✅ Offline support with local caching
- ✅ Push notifications for new messages

## License

[Your License Here]

