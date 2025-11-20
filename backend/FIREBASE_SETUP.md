# Firebase Credentials Setup Guide

## Option 1: Using Service Account Credentials (Recommended)

### Step 1: Get Firebase Service Account Credentials

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Go to **Project Settings** (gear icon) → **Service Accounts** tab
4. Click **Generate New Private Key**
5. Save the downloaded JSON file (e.g., `firebase-credentials.json`)

### Step 2: Place the Credentials File

Place the downloaded JSON file in your backend directory:

```bash
cd backend
# Place firebase-credentials.json here
```

### Step 3: Update .env File

Create a `.env` file in the `backend` directory:

```bash
cd backend
cp .env.example .env
```

Then edit `.env` and set:

```env
FIREBASE_CREDENTIALS_PATH=./firebase-credentials.json
FIREBASE_PROJECT_ID=your-actual-project-id
```

**Important:** Add `firebase-credentials.json` to `.gitignore` to avoid committing credentials!

---

## Option 2: Using Google Cloud SDK (Current Setup)

If you're already authenticated with `gcloud`, you can use your default credentials:

### Step 1: Set Project ID

Set the `GOOGLE_CLOUD_PROJECT` environment variable:

```bash
export GOOGLE_CLOUD_PROJECT=your-firebase-project-id
```

Or add it to your `.env` file:

```env
GOOGLE_CLOUD_PROJECT=your-firebase-project-id
```

### Step 2: Ensure You're Authenticated

```bash
gcloud auth application-default login
```

This will use your personal Google account credentials.

---

## Option 3: Quick Fix for Development (Suppress Warnings)

If you just want to suppress the warnings without fully configuring Firebase, you can:

### Set GOOGLE_CLOUD_PROJECT Environment Variable

```bash
export GOOGLE_CLOUD_PROJECT=your-project-id
```

Or add to your shell profile (`~/.zshrc` or `~/.bash_profile`):

```bash
export GOOGLE_CLOUD_PROJECT=your-project-id
```

Then restart your terminal or run:
```bash
source ~/.zshrc  # or source ~/.bash_profile
```

---

## Finding Your Firebase Project ID

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (gear icon) → **General** tab
4. Your **Project ID** is shown at the top

---

## Verify Setup

After setting up credentials, restart your backend server:

```bash
cd backend
python main.py
```

You should see:
- No Firestore errors
- No "Project ID is required" errors
- Messages being saved to Firestore (check Firebase Console → Firestore Database)

---

## Security Notes

⚠️ **Never commit credentials to git!**

Make sure your `.gitignore` includes:
```
.env
firebase-credentials.json
*.json
!package.json
```

---

## Troubleshooting

### "Project ID is required"
- Set `GOOGLE_CLOUD_PROJECT` environment variable, OR
- Set `FIREBASE_PROJECT_ID` in `.env` file, OR
- Include project ID in service account credentials

### "Credentials file not found"
- Check the path in `FIREBASE_CREDENTIALS_PATH`
- Use absolute path if relative path doesn't work
- Ensure the file exists and is readable

### "Invalid credentials"
- Regenerate the service account key
- Ensure you're using the correct project's credentials
- Check that the credentials file is valid JSON


