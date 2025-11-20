# Enable Firebase Email/Password Authentication

## The Problem
You're getting `CONFIGURATION_NOT_FOUND` error because Email/Password authentication is not enabled in your Firebase project.

## Solution: Enable Email/Password Authentication

### Step-by-Step Instructions:

1. **Go to Firebase Console**
   - Open: https://console.firebase.google.com/
   - Make sure you're logged in with the correct Google account

2. **Select Your Project**
   - Click on **agentchat-f7eb8** project

3. **Navigate to Authentication**
   - Click **Authentication** in the left sidebar
   - If you see a "Get Started" button, click it first

4. **Enable Email/Password**
   - Click on the **Sign-in method** tab (at the top)
   - You'll see a list of sign-in providers
   - Find **Email/Password** in the list
   - Click on **Email/Password**

5. **Enable the Provider**
   - Toggle **Enable** to ON (it should turn blue/green)
   - Leave "Email link (passwordless sign-in)" as OFF for now (unless you want it)
   - Click **Save** at the bottom

6. **Verify It's Enabled**
   - You should see Email/Password with a green checkmark or "Enabled" status
   - The status should show as "Enabled" in the list

## Alternative: Enable via API

If the UI doesn't work, you can also enable it via the Firebase REST API or Firebase CLI, but the UI method above is the easiest.

## After Enabling

1. **Wait a few seconds** for the changes to propagate
2. **Restart your Flutter app** (hot reload might not be enough)
3. **Try signing up first** (create a new account)
4. **Then try signing in**

## Verify It's Working

After enabling, try this in your app:
1. Click "Sign Up" (not Sign In)
2. Enter an email and password
3. If sign up works, authentication is enabled!

## Still Not Working?

If you still get the error after enabling:

1. **Check API Status**
   - Go to: https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com
   - Make sure the Identity Toolkit API is enabled for your project

2. **Check Project Permissions**
   - Make sure you have "Editor" or "Owner" permissions on the Firebase project
   - If you only have "Viewer" permissions, you can't enable authentication

3. **Try a Different Browser**
   - Sometimes browser cache can cause issues
   - Try in an incognito/private window

4. **Check Firebase Console Status**
   - Make sure Firebase Console shows Email/Password as "Enabled"
   - If it shows "Disabled", click on it and enable it again

## Quick Test Command

You can test if it's enabled by trying to create a user via curl:

```bash
curl 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCmXOfPpGqTbu7XM8OIqtZN99upZjlOabg' \
  -H 'content-type: application/json' \
  --data-raw '{"returnSecureToken":true,"email":"test@example.com","password":"test123456","clientType":"CLIENT_TYPE_WEB"}'
```

If you get a successful response with an `idToken`, authentication is enabled!
If you get `CONFIGURATION_NOT_FOUND`, it's still not enabled.


