# 🧠 MindCare Mental Health App

> **A comprehensive Flutter mental health platform with AI-powered therapy, mood tracking, and community support**

[![Flutter](https://img.shields.io/badge/Flutter-3.27.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.7.0-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-orange.svg)](https://firebase.google.com/)

## 📱 Overview

MindCare is a modern mental health application designed to provide accessible, evidence-based therapeutic support through AI-powered conversations, comprehensive mood tracking, and community features. Built with Flutter and Dart, it offers a seamless cross-platform experience while maintaining the highest standards of privacy and security.

### ✨ Key Features

- **🤖 AI Therapy Companion** - Evidence-based therapeutic conversations using CBT, DBT, and mindfulness techniques
- **📊 Mood Tracking** - Visual mood logging with trend analysis and insights
- **📝 Smart Journaling** - AI-enhanced journal entries with sentiment analysis
- **👥 Community Support** - Peer support and shared experiences
- **📅 Therapy Sessions** - Professional therapist booking and management
- **🔒 Privacy First** - Comprehensive privacy controls and data consent management
- **🚨 Crisis Detection** - Real-time crisis intervention with emergency resources
- **📚 Comprehensive Learning Center** - Evidence-based mental health education with interactive tools
- **🛡️ Private Therapy Journal** - Secure, encrypted personal journaling with AI insights
- **🧠 Predictive Wellness Dashboard** - AI-powered mental health analytics and personalized recommendations

## 🎯 Target Audience

- Individuals seeking accessible mental health support
- People looking to track and understand their mood patterns
- Users wanting to supplement professional therapy with AI guidance
- Community members seeking peer support and shared experiences
- Mental health professionals seeking client progress tracking tools
- Organizations implementing employee wellness programs

## 🌟 **Advanced Features Overview**

### 🧠 **Predictive Wellness Dashboard**
The centerpiece of MindCare's innovation - an AI-powered dashboard that transforms mental health data into actionable insights:

**Core Capabilities:**
- **Wellness Score Algorithm**: Sophisticated 0-100 scoring system analyzing mood patterns, journal sentiment, consistency, and risk factors
- **Multi-Metric Trend Analysis**: Tracks mood, energy, sleep quality, anxiety levels, and overall wellness with confidence intervals
- **Predictive Modeling**: 3-5 day mood forecasting, crisis risk assessment, and therapy readiness evaluation
- **Pattern Recognition**: Identifies weekly mood patterns, recurring journal themes, and behavioral correlations
- **Smart Alerts**: Early warning system for declining mental health with escalation protocols

**User Experience:**
- Compact home screen widget showing key metrics and urgent alerts
- One-tap expansion to detailed analytics with interactive charts
- Personalized recommendations based on individual patterns
- Crisis intervention with immediate access to emergency resources

### 📚 **Comprehensive Learning Center**
Evidence-based mental health education platform with interactive learning tools:

**Content Categories:**
- **Mental Health Conditions**: In-depth guides on anxiety, depression, PTSD, bipolar disorder, and more
- **Therapeutic Techniques**: Step-by-step CBT, DBT, mindfulness, and ACT skill-building modules
- **Coping Strategies**: Evidence-based techniques for stress management and emotional regulation
- **Crisis Intervention**: Safety planning, emergency resources, and immediate help guides
- **Interactive Assessments**: Validated screening tools (GAD-7, PHQ-9) with automated scoring
- **Guided Exercises**: Audio-guided breathing, meditation, and progressive relaxation sessions

**Smart Features:**
- AI-powered content recommendations based on user patterns
- Progress tracking for completed exercises and assessments
- Difficulty-based content progression from beginner to advanced
- Crisis resource integration with prominent emergency contact access

### 🛡️ **Private Therapy Journal**
Military-grade encrypted journaling system with therapeutic intelligence:

**Security & Privacy:**
- End-to-end encryption using device-level security
- Local storage with optional cloud backup (encrypted)
- Granular privacy controls (private vs. therapist-shared entries)
- HIPAA-compliant data handling and export capabilities

**Therapeutic Features:**
- **Mood Integration**: Seamless connection with daily mood tracking
- **Thought Pattern Analysis**: Identify and challenge cognitive distortions with CBT techniques
- **Gratitude Practice**: Structured gratitude journaling with guided prompts
- **Session Notes**: Track therapy appointments, insights, homework, and progress
- **Medication Tracking**: Log medication effects, side effects, and effectiveness ratings

**AI-Powered Insights:**
- Real-time sentiment analysis with emotional tone detection
- Pattern recognition for recurring themes and triggers
- Risk assessment with early warning for crisis situations
- Progress visualization showing emotional growth over time
- Automated recommendations for coping strategies and interventions

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** (3.27.0 or higher)
- **Dart SDK** (3.7.0 or higher)
- **Android Studio** or **Xcode** (for device testing)
- **Firebase Account** (for backend services)
- **Google AI Studio Account** (for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/claude-code-mindcare-mental-health-app.git
   cd claude-code-mindcare-mental-health-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment setup**
   ```bash
   cp .env.example .env
   ```
   
   Configure your `.env` file:
   ```env
   FIREBASE_PROJECT_ID=your_firebase_project_id
   FIREBASE_API_KEY=your_firebase_api_key
   FIREBASE_APP_ID=your_firebase_app_id
   GEMINI_API_KEY=your_gemini_api_key
   ```

4. **Firebase setup** (See [Firebase Setup](#firebase-setup) section)

5. **Start the development server**
   ```bash
   flutter run
   ```

6. **Run on device/emulator**
   - For iOS: `flutter run -d ios`
   - For Android: `flutter run -d android`
   - For web: `flutter run -d web`

## 🏗️ Architecture

### Tech Stack

**Frontend**
- **Flutter 3.27.0** - Cross-platform mobile framework
- **Dart 3.7.0** - Programming language optimized for mobile development
- **Material Design 3** - Modern design system
- **Provider/Riverpod** - State management solution

**Backend & Services**
- **Firebase** - Firestore database, authentication, cloud functions
- **Google Generative AI** - AI-powered therapeutic conversations
- **SharedPreferences** - Local data persistence

**State Management**
- **Provider/Riverpod** - Reactive state management
- **HTTP/Dio** - API communication and caching

**UI & Design**
- **Material Design 3** - Consistent design language
- **Custom Widgets** - Reusable UI components
- **Animations** - Smooth transitions and micro-interactions

### Project Structure

```
├── lib/                          # Main application code
│   ├── screens/                  # Application screens
│   │   ├── home/                 # Home/Dashboard with Wellness Widget
│   │   │   └── home_screen.dart
│   │   ├── ai_chat/              # AI Therapy Interface
│   │   │   └── ai_chat_screen.dart
│   │   ├── community/            # Community Features  
│   │   │   └── community_screen.dart
│   │   ├── learning/             # Comprehensive Learning Center
│   │   │   └── learning_screen.dart
│   │   ├── profile/              # User Profile with Therapy Journal
│   │   │   └── profile_screen.dart
│   │   ├── therapy/              # Professional Therapy
│   │   │   └── therapy_screen.dart
│   │   └── auth/                 # Authentication screens
│   │       ├── sign_in_screen.dart
│   │       ├── sign_up_screen.dart
│   │       └── forgot_password_screen.dart
│   ├── widgets/                  # Reusable UI components
│   │   ├── ai_chat_interface.dart      # Main AI chat component
│   │   ├── ai_chat_message.dart        # Chat message display
│   │   ├── auth_guard.dart             # Authentication protection
│   │   ├── mood_picker.dart            # Visual mood selection
│   │   ├── mood_entry_card.dart        # Mood entry display
│   │   ├── wellness_dashboard.dart     # Predictive wellness dashboard
│   │   ├── therapy_journal.dart        # Private encrypted journal
│   │   └── ...                         # Other components
│   ├── providers/                # State management providers
│   │   ├── auth_provider.dart          # Authentication state
│   │   ├── mood_provider.dart          # Mood tracking state
│   │   ├── ai_therapy_provider.dart    # AI therapy sessions
│   │   ├── therapy_journal_provider.dart # Secure journal management
│   │   ├── wellness_dashboard_provider.dart # Wellness analytics
│   │   └── ...                         # Other providers
│   ├── services/                 # External service integrations
│   │   ├── firebase_service.dart       # Firebase client
│   │   └── ai_therapy_service.dart     # AI service logic
│   ├── models/                   # Data models
│   │   └── index.dart                  # Enhanced models for new features
│   ├── constants/                # App constants
│   │   └── colors.dart                 # Design system colors
│   ├── utils/                    # Utility functions
│   │   └── helpers.dart                # Common helper functions
│   └── main.dart                 # App entry point
├── assets/                       # Static assets
│   ├── images/                   # App icons and images
│   └── data/                     # Sample data for testing
│       ├── mock_data.dart              # Development data
│       └── learning_resources.dart     # Comprehensive mental health resources
├── test/                         # Test files
├── android/                      # Android-specific configuration
├── ios/                          # iOS-specific configuration
└── web/                          # Web-specific configuration
```

## 🔥 Firebase Setup

### Firebase Configuration

1. **Create a Firebase project** at [console.firebase.google.com](https://console.firebase.google.com)

2. **Add your app** (Android/iOS/Web) and download configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)

3. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

4. **Initialize Firebase in your project**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

5. **Set up Firestore database**
   ```javascript
   // Firestore rules
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // User profiles collection
       match /user_profiles/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Mood entries collection
       match /mood_entries/{entryId} {
         allow read, write: if request.auth != null && 
           request.auth.uid == resource.data.user_id;
       }
       
       // Therapy journal entries (encrypted)
       match /therapy_journal/{entryId} {
         allow read, write: if request.auth != null && 
           request.auth.uid == resource.data.user_id;
       }
       
       // Other collections with appropriate security rules
     }
   }
   ```

6. **Set up Firebase Authentication**
   - Enable Email/Password authentication
   - Configure OAuth providers (Google, Apple) as needed
   - Set up security rules and user management

### Firestore Data Structure

```javascript
// User profiles document
{
  "email": "user@example.com",
  "full_name": "John Doe",
  "date_of_birth": "1990-01-01",
  "phone_number": "+1234567890",
  "emergency_contact": {
    "name": "Jane Doe",
    "phone": "+1234567891"
  },
  "timezone": "America/New_York",
  "avatar_url": "https://...",
  
  // Privacy and consent settings
  "privacy_settings": {
    "data_sharing_consent": false,
    "analytics_consent": false,
    "marketing_consent": false,
    "research_participation_consent": false,
    "profile_visibility": "private",
    "mood_data_sharing": false,
    "session_data_sharing": false
  },
  
  // Security settings
  "security_settings": {
    "two_factor_enabled": false,
    "login_notifications": true,
    "session_timeout_minutes": 30
  },
  
  // Timestamps
  "created_at": "2025-01-01T00:00:00Z",
  "updated_at": "2025-01-01T00:00:00Z",
  "last_login": "2025-01-01T00:00:00Z"
}
```

### Local Development

For local development with Firebase emulators:
```bash
# Install and start Firebase emulators
firebase init emulators
firebase emulators:start
```

## 🤖 AI Integration Setup

### Google Gemini API

1. **Get API Key**
   - Visit [Google AI Studio](https://ai.google.dev/)
   - Create a project and generate an API key
   - Add key to `.env` as `GEMINI_API_KEY`

2. **Therapeutic Frameworks**
   The AI system implements evidence-based therapeutic approaches:
   - **Cognitive Behavioral Therapy (CBT)** - Thought challenging and reframing
   - **Dialectical Behavior Therapy (DBT)** - Distress tolerance and emotional regulation
   - **Mindfulness-Based Interventions** - Breathing exercises and grounding techniques
   - **Acceptance and Commitment Therapy (ACT)** - Values-based guidance

3. **Crisis Detection**
   Real-time monitoring for crisis keywords with automatic escalation to emergency resources.

For detailed AI setup instructions, see [README-AI-SETUP.md](./README-AI-SETUP.md).

## 🏗️ Advanced Features Architecture

### Predictive Wellness Dashboard Implementation

The wellness dashboard uses a sophisticated AI engine to analyze user data and provide actionable insights:

**Data Sources:**
- Mood entry patterns and trends
- Journal sentiment analysis
- Therapy session progress
- User engagement metrics
- Crisis detection indicators

**Machine Learning Pipeline:**
```dart
// Core wellness score calculation
double calculateWellnessScore(
  List<MoodEntry> moodEntries, 
  List<TherapyJournalEntry> journalEntries
) {
  // Multi-factor analysis including:
  // - Recent mood trends (weighted by recency)
  // - Journal sentiment analysis
  // - Consistency and engagement metrics
  // - Risk factor assessment
  // Returns 0-100 wellness score
}
```

**Real-time Analytics:**
- Trend prediction using moving averages and pattern recognition
- Crisis risk assessment with keyword analysis and sentiment scoring
- Personalized recommendation engine based on historical effectiveness
- Alert system with escalating intervention protocols

### Private Therapy Journal Security

**Encryption Architecture:**
```dart
// Client-side encryption before storage
Map<String, dynamic> encryptedEntry = {
  'content': encrypt(entry.content, userKey),
  'metadata': entry.metadata, // Non-sensitive data
  'hash': generateHash(entry.content) // For search indexing
};
```

**Key Features:**
- **Zero-Knowledge Design** - App never has access to unencrypted content
- **Local-First Storage** - Primary storage on device with optional encrypted backup
- **Selective Sharing** - Users can choose to share specific insights with therapists
- **AI Analysis** - Sentiment and pattern analysis without compromising privacy

### Comprehensive Learning System

**Content Management:**
```dart
// Structured learning resource system
class LearningResource {
  final String category; // 'conditions', 'coping', 'mindfulness', 'crisis', 'therapy'
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final List<String> therapeuticApproaches;
  final bool interactive;
  final LearningContent content;
}

class LearningContent {
  final List<ResourceSection> sections;
  final List<GuidedExercise> exercises;
  final List<MentalHealthAssessment> assessments;
}
```

**Interactive Features:**
- Self-assessment tools with clinical validity
- Guided exercises with progress tracking
- Adaptive content recommendations based on user needs
- Crisis intervention resources with immediate access

### Advanced State Management

**Provider Architecture:**
```dart
// Wellness dashboard provider
class WellnessDashboardProvider extends ChangeNotifier {
  WellnessDashboard? _dashboard;
  List<WellnessInsight> _insights = [];
  List<PersonalizedRecommendation> _recommendations = [];
  
  Future<void> updateDashboard() async {
    final newDashboard = await generateDashboard(_userData);
    _dashboard = newDashboard;
    notifyListeners();
  }
}
```

**Data Flow:**
1. **Collection** - Mood entries, journal content, user interactions
2. **Processing** - AI analysis, pattern recognition, risk assessment
3. **Synthesis** - Wellness score calculation, trend analysis, recommendations
4. **Presentation** - Dashboard widgets, detailed analytics, actionable insights

## 🧪 Development Workflow

### Code Quality Standards

- **Dart** - Strong type checking enabled
- **Linting** - Code analysis and formatting with `dart analyze`
- **Widget Architecture** - StatefulWidget and StatelessWidget patterns
- **State Management** - Provider/Riverpod for state management

### Development Commands

```bash
# Start development server
flutter run

# Start with hot reload
flutter run --hot

# Start with debug mode
flutter run --debug

# Type checking and analysis
dart analyze

# Run tests
flutter test

# Format code
dart format .
```

### Testing Strategy

- **Unit Tests** - Widget and logic testing
- **Integration Tests** - Firebase and API interactions
- **Widget Tests** - UI component testing
- **Accessibility Tests** - Screen reader and navigation testing

### Git Workflow

1. Create feature branch from `main`
2. Make changes with descriptive commits
3. Test thoroughly on multiple devices
4. Create pull request with detailed description
5. Code review and approval required
6. Merge to `main` and deploy

## 🔒 Security & Privacy

### Data Protection

- **Local-First Architecture** - Sensitive data stored locally when possible
- **Encryption** - Data encrypted in transit and at rest
- **Minimal Data Collection** - Only collect necessary information
- **User Consent** - Granular privacy controls
- **Right to Deletion** - Complete data removal on request

### Authentication & Authorization

- **Firebase Auth** - Industry-standard authentication
- **Firestore Security Rules** - Database-level access control
- **Session Management** - Secure session handling
- **Two-Factor Authentication** - Optional 2FA support

### Compliance Considerations

- **HIPAA Readiness** - Designed with healthcare compliance in mind
- **GDPR Compliant** - Privacy by design principles
- **Data Retention** - Configurable retention policies
- **Audit Logging** - Comprehensive activity tracking

## 📱 Features Deep Dive

### AI Therapy Companion

**Capabilities:**
- Evidence-based therapeutic conversations
- Mood pattern analysis and insights
- Crisis detection and intervention
- Personalized coping strategies
- Resource recommendations

**Safety Features:**
- Crisis keyword monitoring
- Emergency contact integration
- Professional therapy referrals
- Harm reduction protocols

### Predictive Wellness Dashboard 🧠

**Advanced Analytics:**
- **AI-Powered Wellness Score** - Comprehensive mental health assessment (0-100 scale)
- **Trend Analysis** - Multi-metric tracking (mood, energy, sleep, anxiety, overall wellness)
- **Predictive Insights** - Mood forecasting, crisis risk assessment, therapy readiness
- **Pattern Recognition** - Identifies recurring themes and behavioral patterns
- **Personalized Recommendations** - Evidence-based coping strategies and interventions

**Smart Monitoring:**
- **Early Warning System** - Detects declining mental health patterns
- **Crisis Alerts** - Immediate notifications for high-risk situations
- **Milestone Celebrations** - Recognizes progress and achievements
- **Correlation Analysis** - Links mood patterns with journal sentiment and activities

**Real-time Dashboard Widget:**
- Compact home screen widget showing wellness score and key trends
- One-tap access to detailed analytics and recommendations
- Critical alert notifications for immediate attention
- Quick insights into mental health patterns

### Comprehensive Learning Center 📚

**Educational Resources:**
- **Mental Health Conditions** - In-depth articles on anxiety, depression, PTSD, and more
- **Therapeutic Techniques** - CBT, DBT, mindfulness, and ACT skill-building guides
- **Coping Strategies** - Evidence-based techniques for stress and emotional management
- **Crisis Support Information** - Immediate help resources and safety planning guides

**Interactive Tools:**
- **Self-Assessment Tools** - GAD-7, PHQ-9, and other validated screening instruments
- **Guided Exercises** - Audio-guided breathing, meditation, and relaxation techniques
- **Progress Tracking** - Completion tracking for exercises and learning modules

**Content Organization:**
- **Smart Search** - AI-powered content discovery based on user needs
- **Category Filtering** - Browse by condition, technique, or difficulty level
- **Personalized Recommendations** - Content suggested based on user patterns and progress

### Private Therapy Journal 🛡️

**Secure Journaling:**
- **End-to-End Encryption** - All entries stored securely on device with encryption
- **Privacy Controls** - Choose between private or shared (with therapist) entries
- **Mood Integration** - Link journal entries with daily mood tracking

**Enhanced Features:**
- **Thought Pattern Tracking** - Identify and challenge cognitive distortions
- **Gratitude Practice** - Built-in gratitude journaling with guided prompts
- **Session Notes** - Track therapy sessions, insights, and homework
- **Medication Tracking** - Log medication effects and side effects

**AI-Powered Insights:**
- **Sentiment Analysis** - Automated emotional tone detection
- **Pattern Recognition** - Identifies recurring themes and triggers
- **Risk Assessment** - Early warning system for crisis situations
- **Progress Tracking** - Visualize emotional growth over time

**Export & Sharing:**
- **Data Export** - Export entries for healthcare providers (with user consent)
- **Progress Reports** - Generate summaries for therapy sessions
- **Privacy Protection** - Remove sensitive AI insights from exports

### Mood Tracking System

**Features:**
- Daily mood logging with visual picker
- Trend analysis and pattern recognition
- Correlation with journal entries
- Shareable insights (with consent)
- Export capabilities for healthcare providers

### Community Platform

**Features:**
- Anonymous peer support groups
- Moderated discussion forums
- Shared experience stories
- Resource sharing
- Crisis support network

### Professional Integration

**Features:**
- Therapist directory and booking
- Session management and reminders
- Progress sharing with providers
- Treatment plan tracking
- Insurance integration (future)

## 🚀 Deployment

### Production Checklist

- [ ] **Environment Variables** - All production keys configured
- [ ] **Firebase Configuration** - Complete setup deployed
- [ ] **API Keys** - Production API keys with proper limits
- [ ] **App Store Compliance** - Health app guidelines met
- [ ] **Privacy Policy** - Comprehensive privacy documentation
- [ ] **Terms of Service** - Legal compliance verified
- [ ] **Security Audit** - Third-party security review
- [ ] **Performance Testing** - Load testing completed
- [ ] **Backup Strategy** - Data backup and recovery plan

### Build Commands

```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Build for web
flutter build web --release
```

### App Store Guidelines

- Follow platform-specific health app guidelines
- Include appropriate disclaimers about professional medical advice
- Implement content moderation for community features
- Provide clear emergency contact information

## 🤝 Contributing

We welcome contributions from the community! Please read our contributing guidelines before submitting pull requests.

### Development Setup

1. Fork the repository
2. Clone your fork locally
3. Install dependencies: `flutter pub get`
4. Set up environment variables
5. Create a feature branch
6. Make your changes
7. Test thoroughly
8. Submit a pull request

### Code Style

- Use Dart for all new code
- Follow existing widget patterns
- Add proper error handling
- Include accessibility features
- Write descriptive commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support & Resources

### Getting Help

- **Documentation** - Check this README and related docs
- **Issues** - Create GitHub issues for bugs or feature requests
- **Discussions** - Use GitHub Discussions for questions
- **Email** - Contact the development team

### Useful Links

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Documentation](https://dart.dev/guides)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Mental Health Resources](https://www.nami.org/help)

### Crisis Resources

If you or someone you know is in crisis:
- **National Suicide Prevention Lifeline**: 988
- **Crisis Text Line**: Text HOME to 741741
- **International Association for Suicide Prevention**: https://www.iasp.info/resources/Crisis_Centres/

---

**⚠️ Important Disclaimer**: This app is designed to supplement, not replace, professional mental health treatment. Always consult with qualified healthcare providers for serious mental health concerns. In case of emergency, contact local emergency services immediately.

---

<div align="center">
  <p><strong>Built with ❤️ for mental health awareness and support</strong></p>
  <p>Created by Claude Code • 2025</p>
</div>