# Judge It MVP - Task Breakdown

## Part 1: Data Pipeline (Python Seeding Script)
- [x] Create Python script `scripts/seed_firestore.py`
- [x] Implement CSV reading logic for `aita_cleaned.csv`
- [x] Implement vote generation logic based on verdict
- [x] Implement Firestore upload functionality

## Part 2: Flutter App Setup
- [x] Add required dependencies (firebase_core, cloud_firestore, appinio_swiper, provider)
- [ ] Configure Firebase for all platforms (user must add config files)
- [x] Create data models

## Part 3: Flutter Services
- [x] Create `Story` model class
- [x] Create `FirestoreService` for story fetching
- [x] Create `AdService` mock for ad logic

## Part 4: Flutter UI
- [x] Create swipe card widget (`StoryCard`)
- [x] Create result overlay widget (`ResultOverlay`)
- [x] Implement main swipe screen with infinite scrolling
- [x] Implement swipe counter and ad trigger logic

## Part 5: Verification
- [x] Test Flutter build and analyze
- [ ] User to configure Firebase and test with real data

---

## Pending User Actions

1. **Add Firebase configuration files**
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

2. **Add data files**
   - `data/aita_cleaned.csv` (columns: title, text, verdict)
   - `scripts/serviceAccountKey.json` (Firebase service account)

3. **Seed Firestore**
   ```bash
   cd scripts
   pip install -r requirements.txt
   python seed_firestore.py
   ```

4. **Run the app**
   ```bash
   flutter run
   ```
