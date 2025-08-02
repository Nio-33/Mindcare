# 🧠 MindCare - AI-Powered Mental Wellness App

<div align="center">

![MindCare Logo](https://img.shields.io/badge/MindCare-Mental%20Wellness-blue?style=for-the-badge&logo=psychology&logoColor=white)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

*Your personal AI companion for mental wellness and emotional support*

</div>

## 📱 Overview

MindCare is a comprehensive Flutter-based mental health application that combines AI-powered therapy, mood tracking, and community support to provide users with a holistic approach to mental wellness. Built with privacy and security at its core, MindCare offers personalized mental health support while maintaining HIPAA-compliant data protection.

## ✨ Features

### 🤖 AI Therapy Assistant
- **Intelligent Conversations**: Powered by Google's Gemini AI for empathetic, context-aware therapy sessions
- **Crisis Detection**: Advanced algorithms to identify and respond to mental health emergencies
- **Personalized Interventions**: Tailored therapeutic techniques based on user patterns and preferences
- **24/7 Availability**: Round-the-clock emotional support and guidance

### 📊 Mood & Wellness Tracking
- **Daily Mood Logging**: Simple, intuitive mood tracking with visual analytics
- **Wellness Score**: Comprehensive mental health scoring algorithm
- **Trend Analysis**: Long-term mood pattern visualization and insights
- **Predictive Analytics**: Early warning system for potential mental health episodes

### 📚 Learning Center
- **Evidence-Based Content**: Curated educational resources on mental health topics
- **Interactive Modules**: Engaging learning paths for different mental health conditions
- **Skill Building**: Practical exercises for stress management, mindfulness, and emotional regulation
- **Progress Tracking**: Monitor learning achievements and skill development

### 👥 Community Support
- **Anonymous Support Groups**: Safe spaces for peer support and shared experiences
- **Moderated Discussions**: Professional oversight to ensure healthy interactions
- **Resource Sharing**: Community-driven mental health tips and coping strategies
- **Crisis Support Network**: Peer-to-peer emergency support system

### 📝 Digital Journaling
- **Smart Journal**: AI-assisted journaling with prompts and insights
- **Thought Pattern Analysis**: Identify cognitive patterns and triggers
- **Gratitude Tracking**: Daily gratitude exercises for positive mental reinforcement
- **Medication Logs**: Track medication adherence and side effects

### 🔒 Privacy & Security
- **End-to-End Encryption**: All sensitive data encrypted with AES-256
- **HIPAA Compliance**: Meets healthcare privacy and security standards
- **Local Data Storage**: Critical data stored locally for enhanced privacy
- **Anonymous Analytics**: User insights without personal identification

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.24.0 or higher)
- Dart SDK (3.8.1 or higher)
- Android Studio / Xcode
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Nio-33/Mindcare.git
   cd Mindcare
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your Firebase and API keys
   ```

4. **Configure Firebase**
   - Add your `google-services.json` to `android/app/`
   - Add your `GoogleService-Info.plist` to `ios/Runner/`

5. **Run the application**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

### Technology Stack
- **Frontend**: Flutter 3.24+ with Material Design 3
- **State Management**: Provider pattern
- **Backend**: Firebase (Firestore, Auth, Storage)
- **AI Integration**: Google Generative AI (Gemini)
- **Analytics**: Custom wellness metrics and mood analytics
- **Security**: Flutter Secure Storage, Crypto, Encrypt

### Project Structure
```
lib/
├── app.dart                    # Main app configuration
├── main.dart                   # Application entry point
├── constants/                  # App-wide constants and themes
├── models/                     # Data models and schemas
├── providers/                  # State management providers
├── screens/                    # UI screens and pages
├── services/                   # Business logic and API services
├── utils/                      # Utility functions and helpers
└── widgets/                    # Reusable UI components
```

### Key Components

#### State Management
- **AuthProvider**: User authentication and session management
- **WellnessDashboardProvider**: Mood tracking and analytics
- **AITherapyProvider**: AI chat sessions and conversation history
- **CommunityProvider**: Social features and support groups
- **LearningProvider**: Educational content and progress tracking

#### Security Features
- **Encryption Service**: AES-256 encryption for sensitive data
- **Crisis Detection**: AI-powered mental health emergency detection
- **Privacy Controls**: Granular privacy settings and data management

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id

# AI Integration
GEMINI_API_KEY=your_gemini_api_key

# Security
ENCRYPTION_KEY=your_32_character_encryption_key
```

### Firebase Rules
The project includes pre-configured Firestore security rules in `firestore.rules` that ensure:
- User data isolation
- HIPAA-compliant access controls
- Real-time security validation

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart
```

### Code Quality
```bash
# Static analysis
flutter analyze

# Format code
flutter format .

# Check dependencies
flutter pub deps
```

## 📊 Mental Health Features

### Crisis Intervention
- **Emergency Contacts**: Quick access to crisis hotlines
- **Suicide Prevention**: Integration with National Suicide Prevention Lifeline
- **Professional Referrals**: Connect users with licensed mental health professionals
- **Emergency Protocols**: Automated crisis response procedures

### Therapeutic Techniques
- **Cognitive Behavioral Therapy (CBT)**: Structured CBT exercises and thought challenges
- **Mindfulness & Meditation**: Guided meditation sessions and mindfulness practices
- **Dialectical Behavior Therapy (DBT)**: Emotion regulation and distress tolerance skills
- **Acceptance & Commitment Therapy (ACT)**: Values-based living and psychological flexibility

### Evidence-Based Interventions
- **Mood Regulation**: Scientifically-proven techniques for emotional balance
- **Anxiety Management**: Practical tools for anxiety reduction and coping
- **Depression Support**: Evidence-based interventions for depressive symptoms
- **Trauma Recovery**: Trauma-informed care and healing resources

## 🤝 Contributing

We welcome contributions from the mental health and developer communities!

### Development Guidelines
1. **Code Style**: Follow Dart/Flutter style guidelines
2. **Mental Health Ethics**: Ensure all contributions align with mental health best practices
3. **Privacy First**: Maintain strict privacy and security standards
4. **Evidence-Based**: Features should be grounded in psychological research

### Contribution Process
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Medical Disclaimer

**Important**: MindCare is designed to supplement, not replace, professional mental health treatment. This app is not intended to diagnose, treat, cure, or prevent any mental health condition. Always consult with qualified healthcare professionals for serious mental health concerns.

### Emergency Resources
- **National Suicide Prevention Lifeline**: 988
- **Crisis Text Line**: Text HOME to 741741
- **Emergency Services**: 911

## 🔗 Links

- **Documentation**: [Wiki](https://github.com/Nio-33/Mindcare/wiki)
- **Issue Tracking**: [GitHub Issues](https://github.com/Nio-33/Mindcare/issues)
- **Security Policy**: [SECURITY.md](SECURITY.md)

## 🙏 Acknowledgments

- **Google AI**: For providing the Gemini AI platform
- **Firebase Team**: For robust backend infrastructure
- **Flutter Community**: For continuous framework improvements
- **Mental Health Professionals**: For guidance on therapeutic approaches
- **Open Source Contributors**: For making this project possible

---

<div align="center">

**Made with ❤️ for mental wellness**

*If you're struggling with mental health, remember: you're not alone, and help is available.*

[![Support](https://img.shields.io/badge/Support-Available-green?style=for-the-badge)](https://github.com/Nio-33/Mindcare/issues)

</div>