# Firebase Configuration Guide for Mobile App

Your Firebase project ID is: **agentchat-f7eb8**

## Step 1: Get Firebase Configuration Values

### For Web App:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **agentchat-f7eb8**
3. Click the gear icon ⚙️ → **Project Settings**
4. Scroll down to **Your apps** section
5. If you don't have a Web app, click **Add app** → Select **Web** (</> icon)
6. Copy the configuration values:
   - `apiKey`
   - `appId`
   - `messagingSenderId`
   - `authDomain` (usually `project-id.firebaseapp.com`)
   - `storageBucket` (usually `project-id.appspot.com`)

### For iOS App:
1. In Firebase Console → Project Settings → **Your apps**
2. If you don't have an iOS app, click **Add app** → Select **iOS**
3. Register your app with bundle ID (check `ios/Runner.xcodeproj` for your bundle ID)
4. Download `GoogleService-Info.plist`
5. Place it in `ios/Runner/`
6. Copy the configuration values from the Firebase Console

### For Android App:
1. In Firebase Console → Project Settings → **Your apps**
2. If you don't have an Android app, click **Add app** → Select **Android**
3. Register your app with package name (check `android/app/build.gradle` for `applicationId`)
4. Download `google-services.json`
5. Place it in `android/app/`
6. Copy the configuration values from the Firebase Console

### For macOS App:
1. Similar to iOS - use the same bundle ID
2. Download `GoogleService-Info.plist` for macOS
3. Place it in `macos/Runner/`
4. Copy the configuration values

## Step 2: Update firebase_config.dart

Open `mobile/lib/core/config/firebase_config.dart` and replace the placeholder values:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_WEB_API_KEY',  // Replace this
  appId: 'YOUR_ACTUAL_WEB_APP_ID',    // Replace this
  messagingSenderId: 'YOUR_ACTUAL_MESSAGING_SENDER_ID',  // Replace this
  projectId: 'agentchat-f7eb8',  // Already set ✓
  authDomain: 'agentchat-f7eb8.firebaseapp.com',  // Already set ✓
  storageBucket: 'agentchat-f7eb8.appspot.com',  // Already set ✓
);
```

Do the same for `android`, `ios`, and `macos` configurations.

## Step 3: Enable Email/Password Authentication

1. Go to Firebase Console → **Authentication**
2. Click **Get Started** (if not already enabled)
3. Go to **Sign-in method** tab
4. Click on **Email/Password**
5. Enable **Email/Password** (toggle ON)
6. Click **Save**

## Step 4: Test the Setup

After updating the config values:

```bash
cd mobile
flutter pub get
flutter run
```

## Quick Setup Using FlutterFire CLI (Alternative)

If you prefer, you can use FlutterFire CLI to automatically configure:

```bash
cd mobile
export PATH="$PATH:$HOME/.pub-cache/bin"
flutterfire configure
```

Select your project **agentchat-f7eb8** and it will automatically update the config files.

## Troubleshooting

### "FirebaseApp not initialized"
- Make sure you've updated all the config values in `firebase_config.dart`
- Ensure `projectId` matches: `agentchat-f7eb8`

### "Email/password accounts are not enabled"
- Go to Firebase Console → Authentication → Sign-in method
- Enable Email/Password provider

### Web-specific issues
- Make sure `firebase_core_web` is in your dependencies (already added ✓)
- For web, you might need to configure Firebase Hosting (optional)


