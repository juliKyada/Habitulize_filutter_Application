# Habitulize - AI-Powered Habit Tracker 🚀

A modern, gamified habit tracking app with AI coaching features built with Flutter.

## ✨ Features

- **🎯 Gamification**: Levels, XP, badges, and streaks to keep you motivated
- **🤖 AI Coach**: Personalized habit suggestions and motivational coaching
- **📊 Progress Tracking**: Visual progress bars and detailed statistics
- **🏆 Achievement System**: 10+ badges to unlock as you build habits
- **💬 AI Chat**: Ask the AI coach anything about building better habits
- **🎨 Modern UI**: Beautiful Material 3 design with smooth animations

## 🛠️ Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure AI Features (Optional)

The app works great without AI configuration using smart fallback suggestions. To enable full AI features:

1. **Get an OpenAI API key:**
   - Visit [OpenAI API Keys](https://platform.openai.com/api-keys)
   - Create a new API key
   - Copy the key

2. **Update the config file:**
   ```dart
   // lib/config/api_config.dart
   static const String openAIApiKey = 'sk-your-actual-api-key-here';
   ```

### 3. Run the App
```bash
flutter run
```

## 🔒 Security & Privacy

- **API Keys**: Stored in separate config file (excluded from git)
- **Local Data**: All habit data stored locally using SharedPreferences
- **No Account Required**: Complete privacy - no sign-up needed
- **Offline First**: Core features work without internet

## 📱 How to Use

### Getting Started
1. **Add Your First Habit**: Tap the "+ Add Habit" button
2. **Choose Categories & Icons**: Customize with emojis and priorities
3. **Complete Daily**: Tap habit icons to mark complete
4. **Earn XP & Badges**: Level up and unlock achievements

### AI Features
1. **Get Suggestions**: Tap the 🤖 AI Coach icon
2. **Answer Questions**: Tell the AI about your lifestyle and goals
3. **Get Personalized Habits**: AI suggests habits perfect for you
4. **Chat with Coach**: Ask questions and get motivation

## 🤖 AI Configuration

The app includes a secure configuration system for API keys:

- **Template File**: `lib/config/api_config.template.dart` (safe to commit)
- **Actual Config**: `lib/config/api_config.dart` (automatically excluded from git)
- **Privacy First**: Your API keys never get committed to version control

## 🎨 Customization

### Habit Options
- **12+ Icons**: Choose from emoji icons
- **7 Categories**: Health, Fitness, Learning, etc.
- **5 Priority Levels**: Low to Critical importance
- **Custom Names**: Name habits however you like

### Gamification Elements
- **Streaks**: Build daily consistency
- **Levels**: Beginner → Legend progression
- **Badges**: 10+ achievements to unlock
- **XP System**: Earn points for completions

## 🛡️ Security Best Practices

1. **Never commit API keys** - They're automatically excluded
2. **Use the template system** - Copy template to create your config
3. **Local storage only** - No data leaves your device
4. **Optional AI** - App works great without any external APIs

---

**Start your habit journey today! 🌟**
