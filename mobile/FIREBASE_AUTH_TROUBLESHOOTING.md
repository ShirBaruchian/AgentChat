# Firebase Authentication Troubleshooting

## Error: CONFIGURATION_NOT_FOUND

This error means Firebase can't find the authentication configuration. Here's how to fix it:

### Step 1: Enable Email/Password Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **agentchat-f7eb8**
3. Click **Authentication** in the left sidebar
4. If you see "Get Started", click it
5. Go to the **Sign-in method** tab
6. Find **Email/Password** in the list
7. Click on it
8. **Enable** the toggle switch
9. Click **Save**

### Step 2: Verify Your App is Registered

Make sure your app is registered in Firebase Console for the platform you're running:

#### For Web:
1. Firebase Console → Project Settings → General
2. Scroll to "Your apps"
3. Look for a Web app (</> icon)
4. If missing, click "Add app" → Select Web

#### For Android:
1. Firebase Console → Project Settings → General
2. Scroll to "Your apps"
3. Look for an Android app (Android icon)
4. Verify package name matches: `com.company.AgentChat`
5. If missing, click "Add app" → Select Android

#### For iOS/macOS:
1. Firebase Console → Project Settings → General
2. Scroll to "Your apps"
3. Look for an iOS app (iOS icon)
4. Verify bundle ID matches: `Com.company.AgentChat`
5. If missing, click "Add app" → Select iOS

### Step 3: Check Console Logs

When you run the app, check the console output. You should see:
```
Initializing Firebase for platform: agentchat-f7eb8
Firebase initialized successfully
```

If you see an error during initialization, that's the problem.

### Step 4: Try Sign Up First

If you're trying to **sign in** but haven't created an account yet, try **signing up** first:
1. Click "Don't have an account? Sign Up" on the login screen
2. Enter your email and password
3. This will create the account
4. Then you can sign in

### Common Issues:

1. **"Email/password accounts are not enabled"**
   - Solution: Enable Email/Password in Firebase Console (Step 1 above)

2. **"CONFIGURATION_NOT_FOUND"**
   - Solution: Enable Email/Password authentication (Step 1 above)
   - Also verify your app is registered for the platform you're using

3. **"User not found"**
   - Solution: Sign up first, then sign in

4. **Firebase initialization fails**
   - Check which platform you're running on
   - Verify the config values in `firebase_config.dart` match Firebase Console

### Quick Test:

1. Enable Email/Password in Firebase Console
2. Restart your app
3. Try signing up with a new email
4. If sign up works, then sign in should work too


