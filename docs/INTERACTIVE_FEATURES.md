# Judge It - Interactive Features Enhancement

Implement interactive and engaging features to make Judge It more fun than just reading Reddit.

## ⚠️ IMPORTANT: Progress Tracking

**After completing each implementation step:**
1. Update this file to mark the step as complete `[x]`
2. Add a note with what was done (files created/modified)
3. Save the file before moving to next step

This allows continuation if session is interrupted. Check the "Implementation Order" section and "Success Criteria" for progress.

---

## Current State
- Flutter app with Firebase/offline data
- Card swiping (NTA/YTA/Skip)
- Result overlay showing agreement percentage
- Top comments displayed
- Onboarding tutorial

## Requirements

### 1. Animated Judge Mascot
- Add a Rive or Lottie animated character that appears during result reveal
- Character shows different reactions:
  - 👍 Happy/celebrating when user agrees with majority (>60%)
  - 🤔 Thinking/surprised when user is in minority (<40%)
  - 😐 Neutral for close calls (40-60%)
- Position mascot on result overlay

### 2. Gamification System
- Implement streak counter (consecutive judgments)
- Add accuracy score tracking (% agreement with majority)
- Create badge system with unlockable achievements:
  - "First Judgment" - Complete first vote
  - "Justice Seeker" - 10 judgments in a row
  - "Fair Judge" - 50 total judgments
  - "Contrarian" - Disagree with majority 10 times
- Store progress in SharedPreferences

### 3. Enhanced Visual Feedback
- Add confetti animation when user matches majority opinion
- Implement haptic feedback on swipe completion
- Add subtle sound effects (optional, toggleable)
- Card entrance/exit animations improved

### 4. Stats Screen
- Create new screen showing user statistics:
  - Total judgments
  - Current streak / Best streak
  - Accuracy percentage
  - Most common vote (NTA vs YTA tendency)
  - Badges earned
- Access from app bar or drawer

### 5. Firebase Realtime Updates
Update Firebase Firestore to support realtime features:

#### Live Vote Counts (Realtime)
- Use Firestore snapshots listener on current story
- Show live vote count updating as others vote
- Animate vote count changes smoothly

#### Trending Stories
- Create `trending` collection in Firestore
- Track stories with most votes in last 24 hours
- Update hourly via Cloud Function (or client-side approximation)

#### Global App Stats (Realtime)
- Create `app_stats` document in Firestore:
  ```json
  {
    "total_judgments": 125000,
    "active_users_today": 342,
    "stories_judged_today": 8500
  }
  ```
- Display on Stats screen with realtime listener
- Increment counters on each vote

#### Firestore Schema Updates
```
firestore/
├── stories/
│   └── {storyId}
│       ├── title, body, yes_votes, no_votes, top_comment (existing)
│       ├── last_voted_at: timestamp     # [NEW] For trending
│       └── votes_today: number          # [NEW] For trending
├── app_stats/                           # [NEW] Collection
│   └── global
│       ├── total_judgments: number
│       ├── active_users_today: number
│       └── last_reset: timestamp
└── trending/                            # [NEW] Collection
    └── {storyId}
        ├── story_ref: reference
        ├── votes_24h: number
        └── updated_at: timestamp
```

#### Security Rules Update
```javascript
match /app_stats/{doc} {
  allow read: if true;
  allow write: if request.auth != null;  // Or use Cloud Functions
}
match /trending/{doc} {
  allow read: if true;
}
```

## Tech Stack
- Flutter with Provider state management
- Rive or Lottie for animations
- confetti_widget package for celebration effects
- vibration package for haptics
- SharedPreferences for local storage
- Firebase Firestore (existing)

## File Structure
```
lib/
├── models/
│   └── user_stats.dart          # [NEW] Stats model
├── providers/
│   └── stats_provider.dart      # [NEW] Stats state management
├── screens/
│   └── stats_screen.dart        # [NEW] Stats display screen
├── widgets/
│   ├── judge_mascot.dart        # [NEW] Animated mascot widget
│   ├── confetti_overlay.dart    # [NEW] Celebration animation
│   └── badge_card.dart          # [NEW] Badge display widget
├── services/
│   └── stats_service.dart       # [NEW] Stats persistence
└── assets/
    └── animations/
        └── judge_mascot.riv     # [NEW] Rive animation file
```

## Success Criteria
- [ ] Animated mascot appears on result overlay with appropriate reaction
- [ ] Streak counter visible and updates correctly
- [ ] At least 4 badges implemented and unlockable
- [ ] Confetti appears when matching majority
- [ ] Stats screen accessible and displays all user data
- [ ] All data persists between app sessions
- [ ] Live vote counts update in realtime on result overlay
- [ ] Global app stats display with realtime listener
- [ ] Firestore schema updated with new collections
- [ ] No linter errors (`flutter analyze` passes)
- [ ] App runs without crashes on Android emulator

## Implementation Order
*(Mark each step `[x]` when complete, add notes)*

- [x] 1. Create UserStats model and StatsService
- [x] 2. Implement StatsProvider with persistence
- [x] 3. Add streak/accuracy tracking to SwipeProvider
- [x] 4. Create Stats screen UI
- [x] 5. Implement badge system
- [x] 6. Add confetti animation on result
- [x] 7. Integrate mascot animation (Rive/Lottie)
- [x] 8. Add haptic feedback
- [x] 9. Update Firestore schema with app_stats and trending collections
- [x] 10. Implement realtime vote count listener on result overlay
- [x] 11. Add global stats realtime display on Stats screen
- [x] 12. Update seeding script to initialize app_stats document
- [x] 13. Final polish and testing

## Progress Notes
*(Add notes here as you complete each step)*

### Step 1: UserStats model and StatsService
- Created `lib/models/user_stats.dart` with:
  - `Badge` class with 6 badge types (FirstJudgment, JusticeSeeker, FairJudge, Contrarian, PerfectWeek, Centurion)
  - `UserStats` class tracking: totalJudgments, streaks, votes, accuracy, badges
  - JSON serialization for SharedPreferences persistence
- Created `lib/services/stats_service.dart` for SharedPreferences persistence

### Step 2: StatsProvider with persistence
- Created `lib/providers/stats_provider.dart` with:
  - Full state management for UserStats
  - Badge progress tracking
  - Integration with StatsService for persistence
- Updated `lib/main.dart` to include StatsProvider in widget tree

### Step 3: Streak/accuracy tracking in SwipeProvider
- Modified `lib/providers/swipe_provider.dart`:
  - Added `agreedWithMajority` tracking
  - Added `newlyUnlockedBadges` state
  - Added `setNewlyUnlockedBadges()` method
- Modified `lib/screens/swipe_screen.dart`:
  - Added stats integration in `_handleVote()`
  - Added streak indicator in app bar
  - Added stats button to navigate to StatsScreen

### Step 4 & 5: Stats screen UI and Badge system
- Created `lib/screens/stats_screen.dart` with:
  - Main stats cards (total judgments, current streak)
  - Voting tendency bar with NTA/YTA breakdown
  - Accuracy percentage display
  - Additional stats (best streak, agreements, contrarian count)
- Created `lib/widgets/badge_card.dart` with:
  - `BadgeCard` widget showing progress/earned state
  - `BadgeUnlockCelebration` widget for unlock animation
- Badge grid display with progress indicators

### Step 6 & 7: Confetti and Mascot animations
- Created `lib/widgets/confetti_overlay.dart`:
  - Uses confetti_widget package
  - Multiple confetti emitters (top, left, right)
  - Triggers when user agrees with majority
- Created `lib/widgets/judge_mascot.dart`:
  - Emoji-based animated mascot (pure Flutter animations)
  - Three reactions: happy (🎉), neutral (🤔), surprised (😮)
  - Bounce and scale animations
  - Messages based on agreement level
- Updated `lib/widgets/result_overlay.dart`:
  - Integrated ConfettiOverlay wrapper
  - Added JudgeMascot widget
  - Added agreedWithMajority parameter

### Step 8: Haptic feedback
- Created `lib/services/haptic_service.dart`:
  - Uses Flutter's built-in HapticFeedback (no external package needed)
  - lightImpact, mediumImpact, heavyImpact methods
  - successFeedback pattern for majority agreement
  - badgeUnlockFeedback celebration pattern
- Integrated into SwipeProvider:
  - Haptic on swipe completion
  - Extra feedback on badge unlock

### Step 9: Firestore schema updates
- Updated `lib/services/firestore_service.dart`:
  - Added `GlobalAppStats` class for app-wide statistics
  - Added `app_stats` collection constants
  - Updated `incrementVote()` to also update `last_voted_at` and `votes_today` fields
  - Added `_incrementGlobalStats()` to update global counters
  - Added `watchStory()` for realtime story vote updates
  - Added `watchGlobalStats()` for realtime global stats stream
  - Added `fetchGlobalStats()` for one-time fetch

### Step 10: Realtime vote count listener on result overlay
- Updated `lib/widgets/result_overlay.dart`:
  - Converted to StatefulWidget for state management
  - Added StreamBuilder integration with `watchStory()`
  - Added storyId parameter for realtime updates
  - Shows total vote count when available
  - Live percentage updates as others vote
- Updated `lib/screens/swipe_screen.dart`:
  - Passes storyId to ResultOverlay

### Step 11: Global stats realtime display on Stats screen
- Updated `lib/screens/stats_screen.dart`:
  - Converted to StatefulWidget
  - Added Community section with realtime StreamBuilder
  - Shows total judgments, today's judgments, active users
  - Live indicator when connected to Firestore
  - Number formatting (K, M suffixes)
  - Added `_GlobalStatItem` widget for display

### Step 12: Update seeding script to initialize app_stats
- Updated `scripts/seed_firestore.py`:
  - Added APP_STATS_COLLECTION and GLOBAL_STATS_DOC constants
  - Added `initialize_app_stats()` function
  - Creates app_stats/global document with:
    - total_judgments (based on seeded vote counts)
    - active_users_today (random 50-200)
    - stories_judged_today (random 500-2000)
    - last_reset timestamp
  - Called automatically after story upload

### Step 13: Final polish and testing
- Fixed package name: `confetti` (not `confetti_widget`)
- Renamed `Badge` class to `AppBadge` to avoid conflict with Flutter's built-in Badge widget
- Fixed syntax/indentation issues in result_overlay.dart
- Ran `flutter analyze` - No issues found!

---

## Iteration 2 Updates (Ralph Loop)

### Streak Logic Improvements
- Clarified streak tracking: counts consecutive DAYS of activity (not individual judgments)
- First judgment ever = streak starts at 1
- Same day additional judgments = streak stays the same (already counted today)
- Next consecutive day = streak increments by 1
- Gap of 2+ days = streak resets to 1
- Example: Day 1 (judge 5x) -> streak=1, Day 2 (judge 3x) -> streak=2

### Expanded Badge System (11 total badges)
**Beginner badges:**
1. First Judgment (1 vote) ⚖️
2. Getting Started (10 judgments) 🌟

**Volume badges:**
3. Fair Judge (50 judgments) 👨‍⚖️
4. Centurion (100 judgments) 🏆
5. Veteran Judge (500 judgments) 👑

**Streak badges:**
6. Justice Seeker (3 day streak) 🔥
7. Perfect Week (7 day streak) 📅
8. Monthly Master (30 day streak) 📆

**Special badges:**
9. Contrarian (disagree 10 times) 🎭
10. Unanimous (agree 25 times) 🤝
11. Balanced Judge (20 NTA + 20 YTA) ⚖️

### Global Stats Implementation Clarification
- Uses Firestore's built-in real-time listeners (via `.snapshots()`)
- NOT raw WebSocket - Firestore handles connection management internally
- Automatic reconnection and offline persistence
- All listening clients receive updates when document changes

### App Name for Release
- App display name: "Judge It"
- Updated: `pubspec.yaml` (description)
- Updated: `android/app/src/main/AndroidManifest.xml` (android:label)
- Updated: `ios/Runner/Info.plist` (CFBundleName, CFBundleDisplayName)

---

## Summary of Files Created/Modified

### New Files Created:
1. `lib/models/user_stats.dart` - UserStats model and AppBadge class (11 badges)
2. `lib/services/stats_service.dart` - Stats persistence service
3. `lib/services/haptic_service.dart` - Haptic feedback service
4. `lib/providers/stats_provider.dart` - Stats state management
5. `lib/screens/stats_screen.dart` - Stats screen UI
6. `lib/widgets/badge_card.dart` - Badge display widgets
7. `lib/widgets/confetti_overlay.dart` - Confetti animation
8. `lib/widgets/judge_mascot.dart` - Mascot animation widget

### Modified Files:
1. `pubspec.yaml` - Added confetti, lottie packages; updated description
2. `lib/main.dart` - Added StatsProvider to widget tree
3. `lib/providers/swipe_provider.dart` - Integrated stats tracking, haptics
4. `lib/screens/swipe_screen.dart` - Stats button, streak indicator
5. `lib/widgets/result_overlay.dart` - Confetti, mascot, realtime updates
6. `lib/services/firestore_service.dart` - Realtime listeners, app_stats
7. `scripts/seed_firestore.py` - Initialize app_stats collection
8. `android/app/src/main/AndroidManifest.xml` - App name "Judge It"
9. `ios/Runner/Info.plist` - App name "Judge It"

---

All tasks completed:
- [x] Streak logic rethought and documented
- [x] Added 5 new badge types (11 total)
- [x] Global stats implementation reviewed and documented (Firestore realtime, not raw WebSocket)
- [x] App name changed to "Judge It" for release
- [x] flutter analyze passes with no issues

---

## Iteration 3: Avatars & Music (NEW)

### 6. Animated Boy/Girl Avatars
Replace emoji-based mascot with animated character avatars:

#### Avatar Selection
- Add user preference for avatar type in settings:
  - Boy avatar (animated)
  - Girl avatar (animated)
  - Classic (emoji - current)
- Store preference in SharedPreferences
- Show avatar selection on first launch (after onboarding)

#### Avatar Animations
- Use Rive or Lottie animations for smooth character animations
- Reactions same as current mascot:
  - Happy/celebrating when user agrees with majority (>60%)
  - Thinking/surprised when user is in minority (<40%)
  - Neutral for close calls (40-60%)
- Avatar appears in:
  - Result overlay (main reaction)
  - Stats screen header
  - Badge unlock celebration

#### Avatar Files Needed
```
assets/
├── animations/
│   ├── avatar_boy_happy.json     # [NEW] Lottie animation
│   ├── avatar_boy_sad.json       # [NEW]
│   ├── avatar_boy_neutral.json   # [NEW]
│   ├── avatar_girl_happy.json    # [NEW]
│   ├── avatar_girl_sad.json      # [NEW]
│   └── avatar_girl_neutral.json  # [NEW]
```

### 7. Background Music & Sound Effects
Add ambient music to make app more engaging:

#### Music System
- Background looping music during app usage
- Music plays on launch (if enabled)
- Fade in/out on app pause/resume

#### Music Toggle (IMPORTANT)
- Settings toggle: "Background Music" ON/OFF
- Quick toggle button in app bar (speaker icon 🔊/🔇)
- Default: OFF (don't annoy new users)
- Remember preference in SharedPreferences

#### Sound Effects (separate from music)
- Swipe sounds (subtle whoosh)
- Vote confirmation sounds (ding for NTA, buzz for YTA)
- Badge unlock celebration sound
- Toggle in settings: "Sound Effects" ON/OFF

#### Audio Files Needed
```
assets/
├── audio/
│   ├── background_music.mp3      # [NEW] Chill looping music
│   ├── swipe_whoosh.mp3          # [NEW]
│   ├── vote_nta.mp3              # [NEW]
│   ├── vote_yta.mp3              # [NEW]
│   └── badge_unlock.mp3          # [NEW]
```

#### Audio Packages
- `audioplayers` - For music and sound effects
- `audio_session` - For proper audio focus handling

### New Files for Iteration 3
```
lib/
├── providers/
│   └── settings_provider.dart    # [NEW] App settings state
├── services/
│   └── audio_service.dart        # [NEW] Music & sound control
├── screens/
│   └── settings_screen.dart      # [NEW] Settings UI
├── widgets/
│   └── avatar_widget.dart        # [NEW] Animated avatar component
```

---

## Iteration 3 Implementation Order
*(Mark each step `[x]` when complete)*

- [x] 14. Fix badge description truncation (maxLines: 1 → 2)
- [x] 15. Create SettingsProvider for app preferences
- [x] 16. Create AudioService for music/sound management
- [x] 17. Add audioplayers package and audio assets
- [x] 18. Implement music toggle in app bar
- [x] 19. Create SettingsScreen with audio toggles
- [x] 20. Download/create Lottie avatar animations
- [x] 21. Create AvatarWidget with Lottie integration
- [x] 22. Add avatar selection in settings/onboarding
- [x] 23. Replace emoji mascot with animated avatar
- [x] 24. Add sound effects for swipe/vote/unlock
- [x] 25. Final testing and polish

## Iteration 3 Success Criteria
- [x] Badge descriptions fully visible (no "...")
- [x] Animated boy/girl avatars available and selectable
- [x] Avatar reacts appropriately on result overlay
- [x] Background music plays and loops
- [x] Music can be toggled on/off from app bar
- [x] Sound effects play on swipe, vote, badge unlock
- [x] All audio preferences persist between sessions
- [x] Settings screen accessible with all audio options
- [x] No linter errors (`flutter analyze` passes)

## Iteration 3 Progress Notes
*(Add notes as steps complete)*

### Step 14: Badge description fix ✅
- Updated `lib/widgets/badge_card.dart`
- Changed `maxLines: 1` to `maxLines: 2` for description text

### Step 15: SettingsProvider ✅
- Created `lib/providers/settings_provider.dart`
- Manages: musicEnabled, soundEffectsEnabled, avatarType (classic/boy/girl)
- Persists to SharedPreferences

### Step 16: AudioService ✅
- Created `lib/services/audio_service.dart`
- Singleton pattern for music/SFX management
- Methods: playMusic, stopMusic, pauseMusic, resumeMusic
- Sound effects: swipe, NTA vote, YTA vote, badge unlock

### Step 17: Package & Assets ✅
- Added `audioplayers: ^6.1.0` to pubspec.yaml
- Created `assets/audio/` directory
- Registered audio assets in pubspec.yaml

### Step 18: Music Toggle in App Bar ✅
- Updated `lib/screens/swipe_screen.dart`
- Added music toggle button (🔊/🔇) next to stats button
- Integrates with SettingsProvider and AudioService

---

Output <promise>COMPLETE</promise> when all Iteration 3 tasks are done.
