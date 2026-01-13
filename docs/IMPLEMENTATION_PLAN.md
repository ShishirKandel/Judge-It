# Judge It MVP - Implementation Plan

Build a social voting app where users swipe left/right on stories to vote, with pre-seeded realistic vote data to solve the "cold start" problem.

## Setup Required

> **CSV File Location**: The script expects `aita_cleaned.csv` in `data/` folder.

> **Firebase Configuration**: You'll need to:
> 1. Create a Firebase project in the Firebase Console
> 2. Enable Firestore Database
> 3. Download configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS)
> 4. Provide a Firebase service account key (JSON) for the Python script as `scripts/serviceAccountKey.json`

---

## Project Structure

```
judge_it/
├── scripts/
│   ├── seed_firestore.py      # Python script to seed Firestore
│   └── requirements.txt       # Python dependencies
├── data/
│   └── aita_cleaned.csv       # CSV with columns: title, text, verdict
└── lib/
    ├── main.dart              # Firebase init + dark theme
    ├── models/
    │   └── story.dart         # Story data model
    ├── providers/
    │   └── swipe_provider.dart # State management (Provider)
    ├── services/
    │   ├── firestore_service.dart  # Firestore operations
    │   └── ad_service.dart    # Mock ad service
    ├── screens/
    │   └── swipe_screen.dart  # Main swipe interface
    └── widgets/
        ├── story_card.dart    # Premium card design
        └── result_overlay.dart # Vote result feedback
```

---

## Part 1: Data Seeding Script (Python)

### seed_firestore.py

Python script to seed Firestore with 1,000 dummy stories:

```python
# Logic overview:
# 1. Read CSV file (title, text, verdict)
# 2. Generate realistic votes based on verdict:
#    - NTA: yes_votes=300-800, no_votes=10-50
#    - YTA: yes_votes=10-50, no_votes=300-800  
#    - ESH: balanced votes (~200 each with slight variance)
# 3. Upload to Firestore 'stories' collection
```

**Usage**:
```bash
cd scripts
pip install -r requirements.txt
python seed_firestore.py --dry-run  # Preview without uploading
python seed_firestore.py            # Upload to Firestore
```

---

## Part 2: Flutter Configuration

### Dependencies (pubspec.yaml)

- `firebase_core` - Firebase initialization
- `cloud_firestore` - Firestore database
- `appinio_swiper` - Card swipe widget
- `provider` - State management

---

## Part 3: Flutter Data Layer

### story.dart
Data model with Firestore serialization and vote percentage calculations.

### firestore_service.dart
- `fetchStories(int limit, DocumentSnapshot? lastDoc)` - Paginated fetch
- `incrementVote(String storyId, bool isYes)` - Update vote count

### ad_service.dart
Mock ad service - prints "Ad Shown" to console (replace with AdMob later).

---

## Part 4: Flutter UI Layer

### story_card.dart
Premium glassmorphism card with:
- Title (bold)
- Body text (scrollable)
- Swipe direction indicators (green right, red left)

### result_overlay.dart
Post-swipe overlay showing:
- User's choice (NTA/YTA with color)
- Percentage agreement ("78% agreed with you")

### swipe_screen.dart
Main screen with:
- `AppinioSwiper` for card swiping
- Pre-fetch 5 stories for smooth scrolling
- Load more when 2 cards remaining
- Global swipe counter
- Ad trigger: every 7 swipes

---

## Verification

### Automated Tests

1. **Flutter Build Test**:
   ```bash
   flutter pub get
   flutter analyze
   flutter test
   ```

2. **Python Script Test**:
   ```bash
   cd scripts
   python seed_firestore.py --dry-run
   ```

### Manual Verification

1. **Data Seeding**:
   - Run `python seed_firestore.py` with valid credentials
   - Check Firebase Console → Firestore → `stories` collection
   - Verify documents with correct vote distributions

2. **App Functionality**:
   - Launch app: `flutter run`
   - Verify stories load (cards appear)
   - Swipe right → Green "NTA" indicator → Result shows percentage
   - Swipe left → Red "YTA" indicator → Result shows percentage
   - After 7 swipes → Console shows "Ad Shown"
   - Verify infinite scroll loads new stories
