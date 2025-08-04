# Firebase Setup Guide for MindCare

## The Current Issue

The authentication is failing because Firebase is not properly configured. The app is trying to connect to placeholder Firebase values instead of a real Firebase project.

## Solution: Set up Firebase Project

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Name it "MindCare" (or your preferred name)
4. Enable Google Analytics (optional)
5. Wait for project creation

### Step 2: Enable Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password** provider
3. Optionally enable **Anonymous** authentication for testing

### Step 3: Configure Android App

1. Go to **Project Settings** (gear icon) → **General**
2. Click **Add app** → **Android**
3. Enter package name: `com.example.mindcare`
4. Download `google-services.json`
5. Replace the existing file at `android/app/google-services.json`

### Step 4: Update Environment Variables

1. In Firebase Console, go to **Project Settings** → **General**
2. Scroll down to "Your apps" section
3. Click on your Android app
4. Copy the configuration values
5. Update `.env` file with real values:

```env
# Firebase Configuration - REPLACE WITH YOUR ACTUAL VALUES
FIREBASE_PROJECT_ID=your-actual-project-id
FIREBASE_API_KEY=your-actual-api-key
FIREBASE_APP_ID=your-actual-app-id
FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id
FIREBASE_MEASUREMENT_ID=your-measurement-id

# AI Integration - GET FROM GOOGLE AI STUDIO
GEMINI_API_KEY=your-actual-gemini-api-key

# Security - GENERATE A SECURE 32-CHARACTER KEY
ENCRYPTION_KEY=generate_secure_32_character_key_here
```

### Step 5: Set up Firestore Database

1. Go to **Firestore Database** → **Create database**
2. Choose **Start in test mode** (for development)
3. Select a location close to your users

### Step 6: Configure Security Rules

Update Firestore rules in `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /user_profiles/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chat messages - users can only access their own
    match /chat_messages/{messageId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.user_id;
    }
    
    // Therapy journal entries - users can only access their own
    match /therapy_journal_entries/{entryId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.user_id;
    }
  }
}
```

### Step 7: Restart the App

```bash
flutter run -d emulator-5554
```

## Alternative: Use Firebase Local Emulator Suite

For development and testing without creating a real Firebase project:

```bash
firebase init emulators
firebase emulators:start
```

Then update your app to connect to local emulators.

## Troubleshooting

### Common Issues:

1. **"Authentication failed"** - Usually means Firebase config is incorrect
2. **"Network error"** - Check internet connection and API keys
3. **"Operation not allowed"** - Enable Email/Password in Firebase Console

### Debug Steps:

1. Check Flutter logs: `flutter logs`
2. Verify `.env` file has real values (not placeholders)
3. Ensure `google-services.json` matches your Firebase project
4. Check Firebase Console for authentication attempts

## Security Notes

- Never commit real API keys to version control
- Use different Firebase projects for development/production
- Enable App Check for production apps
- Regularly rotate API keys
- Set up proper Firestore security rules

## Next Steps After Setup

1. Test account creation and sign-in
2. Set up Gemini AI API key for therapy features
3. Configure push notifications
4. Set up proper error monitoring
5. Deploy to production with secure environment variables