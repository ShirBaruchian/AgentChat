# Enable Firebase Anonymous Authentication

## Problem
You're seeing this error:
```
Error signing in anonymously: [firebase_auth/admin-restricted-operation] This operation is restricted to administrators only.
```

This means **Anonymous Authentication is not enabled** in your Firebase Console.

## Solution

### Step 1: Enable Anonymous Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (e.g., `agentchat-f7eb8`)
3. Navigate to **Authentication** → **Sign-in method**
4. Find **Anonymous** in the list of providers
5. Click on **Anonymous**
6. Toggle **Enable** to ON
7. Click **Save**

### Step 2: Verify

After enabling, restart your app. You should see:
```
Signed in anonymously with UID: [some-firebase-uid]
```

Instead of the error message.

## Fallback Solution

The app now has a **fallback** that uses a device ID if Anonymous Auth is not available. This means:
- The app will still work and sync tokens with the backend
- Each device gets a unique ID stored locally
- Token tracking will work even without Firebase Auth

However, **enabling Anonymous Auth is recommended** because:
- Better security
- Consistent user IDs across devices
- Easier to migrate to full accounts later

## Testing

After enabling Anonymous Auth:
1. Restart the app
2. Send a message
3. Check the console - you should see:
   - `✅ UsageService: getUserId() returning Firebase UID: [uid]`
   - `📡 ApiService: Fetching usage status from: http://localhost:8000/api/usage/status/[uid]`
   - Token count should update in the UI

