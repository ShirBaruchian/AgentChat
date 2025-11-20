# Firebase Setup Guide

## Prerequisites
1. A Firebase project created at [Firebase Console](https://console.firebase.google.com/)
2. FlutterFire CLI installed (recommended) or manual configuration

## Option 1: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase for your Flutter app:
```bash
cd mobile
flutterfire configure
```

This will automatically:
- Detect your Firebase projects
- Configure Firebase for all platforms (iOS, Android, Web, macOS)
- Update `firebase_config.dart` with the correct values

## Option 2: Manual Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Go to Project Settings (gear icon) > General
4. Scroll down to "Your apps" section

### For Web:
- Click the web icon (`</>`) to add a web app
- Copy the Firebase configuration object
- Update `lib/core/config/firebase_config.dart` with the `web` values:
  - `apiKey`
  - `appId`
  - `messagingSenderId`
  - `projectId`
  - `authDomain`
  - `storageBucket`

### For Android:
- Click the Android icon to add an Android app
- Register your app with package name (check `android/app/build.gradle` for `applicationId`)
- Download `google-services.json`
- Place it in `android/app/`
- Update `lib/core/config/firebase_config.dart` with Android values

### For iOS:
- Click the iOS icon to add an iOS app
- Register your app with bundle ID (check `ios/Runner.xcodeproj` or `macos/Runner.xcodeproj`)
- Download `GoogleService-Info.plist`
- Place it in `ios/Runner/` and `macos/Runner/` (if using macOS)
- Update `lib/core/config/firebase_config.dart` with iOS values

### For macOS:
- Use the same bundle ID as iOS
- Download `GoogleService-Info.plist` for macOS
- Place it in `macos/Runner/`
- Update `lib/core/config/firebase_config.dart` with macOS values

## Enable Authentication

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Email/Password** provider
3. Click **Save**

## Install Dependencies

After configuring Firebase, install the Flutter dependencies:

```bash
cd mobile
flutter pub get
```

## Test the Setup

1. Run your app:
```bash
flutter run
```

2. Try to sign up with a new email/password
3. Check Firebase Console > Authentication to see if the user was created

## Troubleshooting

### Error: "FirebaseApp not initialized"
- Make sure you've run `flutterfire configure` or manually updated `firebase_config.dart`
- Ensure all required Firebase config values are set (not "YOUR_*_KEY")

### Error: "Platform not supported"
- Make sure you've configured Firebase for the platform you're running on
- For web, ensure `firebase_core_web` is properly configured

### Error: "Email/password accounts are not enabled"
- Go to Firebase Console > Authentication > Sign-in method
- Enable Email/Password provider

## Next Steps

- The authentication service is now fully integrated with Firebase
- Users can sign up, sign in, and sign out
- The app automatically navigates based on authentication state
- You can extend the auth service with additional features like:
  - Password reset
  - Email verification
  - Social authentication (Google, Apple, etc.)


