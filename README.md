# Judge It

A social voting app where users swipe left/right on stories to vote. Built with Flutter and Firebase.

## Features

- 📱 **Swipe Interface** - Tinder-style card swiping
  - Swipe Right = "Not the A**hole" (NTA)
  - Swipe Left = "You're the A**hole" (YTA)
- 📊 **Instant Feedback** - See vote percentages after each swipe
- 🔄 **Infinite Scroll** - Pre-fetches 5 stories for smooth scrolling
- 💰 **Ad Ready** - Mock ad service triggers every 7 swipes
- 🌙 **Premium Dark Theme** - Modern glassmorphism UI

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase Firestore
- **State Management**: Provider
- **Scripting**: Python (data seeding)

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Firebase project with Firestore enabled
- Python 3.x (for data seeding)

### 1. Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Firestore Database
3. Add your Firebase config files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 2. Seed Database

```bash
cd scripts
pip install -r requirements.txt

# Place your CSV file
# data/aita_cleaned.csv (columns: title, text, verdict)

# Place your service account key
# scripts/serviceAccountKey.json

# Dry run (preview)
python seed_firestore.py --dry-run

# Seed Firestore
python seed_firestore.py
```

### 3. Run the App

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── story.dart               # Story data model
├── providers/
│   └── swipe_provider.dart      # State management
├── services/
│   ├── firestore_service.dart   # Database operations
│   └── ad_service.dart          # Ad integration (mock)
├── screens/
│   └── swipe_screen.dart        # Main swipe screen
└── widgets/
    ├── story_card.dart          # Card UI
    └── result_overlay.dart      # Result display
```

## Documentation

- [Implementation Plan](docs/IMPLEMENTATION_PLAN.md)
- [Task Breakdown](docs/TASKS.md)

## Vote Generation Logic

Stories are seeded with realistic vote distributions based on verdict:

| Verdict | Yes Votes | No Votes |
|---------|-----------|----------|
| NTA     | 300-800   | 10-50    |
| YTA     | 10-50     | 300-800  |
| ESH     | ~200      | ~200     |

## License

MIT
