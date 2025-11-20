# Mobile App (Flutter)

Cross-platform mobile application for iOS and Android.

## Setup

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase:**
   - Add `google-services.json` (Android) to `android/app/`
   - Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`

3. **Run the app:**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Core functionality
│   ├── config/              # App configuration
│   ├── constants/           # Constants
│   ├── theme/               # App theme
│   └── utils/               # Utilities
├── features/                 # Feature modules
│   ├── auth/                # Authentication
│   ├── chat/                # Chat functionality
│   ├── agents/              # Agent selection
│   ├── subscription/        # Subscription management
│   └── settings/           # Settings
├── models/                  # Data models
├── services/               # Business logic services
│   ├── firebase_service.dart
│   ├── chat_service.dart
│   ├── subscription_service.dart
│   └── gemini_service.dart
└── widgets/                # Reusable widgets
```

## Key Features

- Firebase Authentication
- Real-time chat with Firestore
- In-app purchases (StoreKit/Play Billing)
- Agent persona management
- Message rate limiting
- Offline support

