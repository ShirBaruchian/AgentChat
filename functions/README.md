# Serverless Functions

Firebase Cloud Functions for serverless backend operations.

## Setup

1. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase:**
   ```bash
   firebase login
   ```

3. **Initialize Firebase:**
   ```bash
   firebase init functions
   ```

4. **Install dependencies:**
   ```bash
   cd functions
   npm install
   ```

## Functions

- `verifySubscription` - Verify App Store/Play Store receipts
- `processMessage` - Process chat messages via Gemini API
- `updateUsage` - Update user message usage counters
- `sendNotification` - Send push notifications

## Deployment

```bash
firebase deploy --only functions
```

