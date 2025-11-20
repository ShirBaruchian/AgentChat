# Setup Guide - AI Agent Chat Application

This guide will walk you through setting up the entire project from scratch.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (3.0+)
   ```bash
   flutter --version
   # If not installed: https://flutter.dev/docs/get-started/install
   ```

2. **Python** (3.11+)
   ```bash
   python --version
   ```

3. **Node.js & npm** (for Firebase CLI)
   ```bash
   node --version
   npm --version
   ```

4. **Firebase CLI**
   ```bash
   npm install -g firebase-tools
   firebase --version
   ```

5. **Google Cloud SDK** (optional, for deployment)
   ```bash
   gcloud --version
   ```

## Step 1: Firebase Project Setup

1. **Create a Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project"
   - Follow the setup wizard

2. **Enable Services:**
   - **Authentication**: Enable Email/Password sign-in
   - **Firestore Database**: Create database in production mode
   - **Cloud Functions**: Enable (for serverless functions)

3. **Get Firebase Configuration:**
   - Go to Project Settings > General
   - Scroll to "Your apps" section
   - Add iOS app (get `GoogleService-Info.plist`)
   - Add Android app (get `google-services.json`)

4. **Download Service Account Key:**
   - Go to Project Settings > Service Accounts
   - Click "Generate new private key"
   - Save as `service-account-key.json` in `backend/` directory

## Step 2: Google Gemini API Setup

1. **Get API Key:**
   - Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Create a new API key
   - Copy the key

2. **Add to Backend:**
   - Add `GEMINI_API_KEY=your-key-here` to `backend/.env`

## Step 3: Mobile App Setup

1. **Navigate to mobile directory:**
   ```bash
   cd mobile
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase for iOS:**
   - Copy `GoogleService-Info.plist` to `ios/Runner/`
   - Update `ios/Runner/Info.plist` if needed

4. **Configure Firebase for Android:**
   - Copy `google-services.json` to `android/app/`
   - Update `android/build.gradle` and `android/app/build.gradle`

5. **Update Firebase Config:**
   - Edit `lib/core/config/firebase_config.dart`
   - Replace placeholder values with your Firebase config

6. **Run the app:**
   ```bash
   flutter run
   ```

## Step 4: Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Create virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration:
   # - FIREBASE_PROJECT_ID
   # - FIREBASE_CREDENTIALS_PATH (path to service-account-key.json)
   # - GEMINI_API_KEY
   ```

5. **Run the server:**
   ```bash
   uvicorn main:app --reload
   ```

6. **Test the API:**
   - Open http://localhost:8000/docs for Swagger UI
   - Test endpoints at http://localhost:8000/health

## Step 5: App Store / Play Store Setup

### iOS (App Store Connect)

1. **Create App ID:**
   - Go to [Apple Developer Portal](https://developer.apple.com/)
   - Create App ID with In-App Purchase capability

2. **Set up Subscriptions:**
   - In App Store Connect, create subscription groups
   - Add weekly, monthly, and annual subscription products
   - Configure 7-day free trial

3. **Test with Sandbox:**
   - Create sandbox test accounts
   - Test purchases in development builds

### Android (Google Play Console)

1. **Create App:**
   - Go to [Google Play Console](https://play.google.com/console)
   - Create new app

2. **Set up Subscriptions:**
   - Create subscription products
   - Configure free trial periods
   - Set up pricing

3. **Test with License Testing:**
   - Add test accounts
   - Test purchases in internal testing track

## Step 6: Development Workflow

### Local Development

1. **Start Firebase Emulators** (optional):
   ```bash
   firebase emulators:start
   ```

2. **Run Backend:**
   ```bash
   cd backend
   source venv/bin/activate
   uvicorn main:app --reload
   ```

3. **Run Mobile App:**
   ```bash
   cd mobile
   flutter run
   ```

### Testing

1. **Backend Tests:**
   ```bash
   cd backend
   pytest
   ```

2. **Mobile Tests:**
   ```bash
   cd mobile
   flutter test
   ```

## Step 7: Deployment

### Backend to Google Cloud Functions

```bash
cd backend
gcloud functions deploy ai-agent-chat-api \
  --runtime python311 \
  --trigger http \
  --allow-unauthenticated \
  --entry-point app
```

### Backend to Cloud Run

```bash
cd backend
gcloud run deploy ai-agent-chat-api \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Mobile App

1. **Build iOS:**
   ```bash
   cd mobile
   flutter build ios
   # Then use Xcode to archive and upload
   ```

2. **Build Android:**
   ```bash
   cd mobile
   flutter build appbundle
   # Upload to Play Console
   ```

## Troubleshooting

### Common Issues

1. **Firebase not initialized:**
   - Check that `GoogleService-Info.plist` and `google-services.json` are in correct locations
   - Verify Firebase config in `firebase_config.dart`

2. **Backend connection errors:**
   - Ensure backend is running on correct port
   - Check CORS settings in `backend/main.py`
   - Verify Firebase credentials path

3. **Gemini API errors:**
   - Verify API key is correct
   - Check API quota/limits
   - Ensure model name is correct

4. **Subscription issues:**
   - Verify App Store/Play Store configuration
   - Check receipt verification logic
   - Test with sandbox/test accounts

## Next Steps

1. **Customize Agents:**
   - Edit `backend/routers/agents.py` to add your agent personas
   - Update agent personas in `backend/services/gemini_service.py`

2. **Implement Subscription Verification:**
   - Complete `backend/routers/subscription.py`
   - Add App Store Server API integration
   - Add Google Play Developer API integration

3. **Add Features:**
   - Push notifications
   - Message history
   - Agent customization
   - User profiles

4. **Optimize:**
   - Implement caching
   - Add message queuing
   - Optimize Gemini API usage
   - Add analytics

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Gemini API](https://ai.google.dev/docs)
- [App Store Connect](https://developer.apple.com/app-store-connect/)
- [Google Play Console](https://play.google.com/console)

