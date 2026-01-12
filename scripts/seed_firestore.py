"""
Firestore Seeding Script for Judge It App
==========================================
Seeds the 'stories' collection with realistic vote data based on verdict.

Usage:
  python seed_firestore.py                    # Normal run
  python seed_firestore.py --dry-run          # Preview without uploading
  python seed_firestore.py --limit 100        # Upload only first 100 stories

Requirements:
  - pip install firebase-admin pandas
  - Place your Firebase service account key as 'serviceAccountKey.json' in this folder
  - Place 'aita_cleaned.csv' in the 'data' folder (parent directory)
"""

import argparse
import random
import os
import sys
import pandas as pd
import firebase_admin
from firebase_admin import credentials, firestore

# Configuration
CSV_PATH = os.path.join(os.path.dirname(__file__), '..', 'data', 'aita_cleaned.csv')
SERVICE_ACCOUNT_PATH = os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json')
COLLECTION_NAME = 'stories'


def generate_votes(verdict: str) -> tuple[int, int]:
    """
    Generate realistic vote counts based on the verdict.
    
    Args:
        verdict: 'NTA', 'YTA', or 'ESH'
    
    Returns:
        Tuple of (yes_votes, no_votes)
    """
    verdict = verdict.upper().strip()
    
    if verdict == 'NTA':
        # Not the Asshole: High yes votes, low no votes
        yes_votes = random.randint(300, 800)
        no_votes = random.randint(10, 50)
    elif verdict == 'YTA':
        # You're the Asshole: Low yes votes, high no votes
        yes_votes = random.randint(10, 50)
        no_votes = random.randint(300, 800)
    elif verdict == 'ESH':
        # Everyone Sucks Here: Roughly equal votes
        base = random.randint(180, 220)
        yes_votes = base + random.randint(-20, 20)
        no_votes = base + random.randint(-20, 20)
    else:
        # Unknown verdict: default to balanced
        print(f"Warning: Unknown verdict '{verdict}', using balanced votes")
        yes_votes = random.randint(100, 300)
        no_votes = random.randint(100, 300)
    
    return yes_votes, no_votes


def read_csv(csv_path: str, limit: int = None) -> list[dict]:
    """
    Read stories from CSV and generate vote data.
    
    Args:
        csv_path: Path to the CSV file
        limit: Optional limit on number of stories to process
    
    Returns:
        List of story dictionaries ready for Firestore
    """
    if not os.path.exists(csv_path):
        print(f"Error: CSV file not found at {csv_path}")
        print("Please place 'aita_cleaned.csv' in the 'data' folder.")
        sys.exit(1)
    
    df = pd.read_csv(csv_path)
    
    # Validate required columns
    required_columns = ['title', 'text', 'verdict']
    missing = [col for col in required_columns if col not in df.columns]
    if missing:
        print(f"Error: Missing required columns: {missing}")
        print(f"Found columns: {list(df.columns)}")
        sys.exit(1)
    
    if limit:
        df = df.head(limit)
    
    stories = []
    for idx, row in df.iterrows():
        yes_votes, no_votes = generate_votes(row['verdict'])
        
        story = {
            'title': str(row['title']),
            'body': str(row['text']),
            'yes_votes': yes_votes,
            'no_votes': no_votes,
        }
        stories.append(story)
    
    return stories


def upload_to_firestore(stories: list[dict], dry_run: bool = False):
    """
    Upload stories to Firestore.
    
    Args:
        stories: List of story dictionaries
        dry_run: If True, print samples instead of uploading
    """
    if dry_run:
        print("\n=== DRY RUN MODE ===")
        print(f"Would upload {len(stories)} stories to '{COLLECTION_NAME}' collection\n")
        
        # Show sample stories
        print("Sample stories (first 3):")
        for i, story in enumerate(stories[:3]):
            print(f"\n--- Story {i+1} ---")
            print(f"Title: {story['title'][:60]}...")
            print(f"Body: {story['body'][:100]}...")
            print(f"Yes Votes: {story['yes_votes']}")
            print(f"No Votes: {story['no_votes']}")
            total = story['yes_votes'] + story['no_votes']
            pct = (story['yes_votes'] / total) * 100 if total > 0 else 0
            print(f"NTA Percentage: {pct:.1f}%")
        return
    
    # Initialize Firebase
    if not os.path.exists(SERVICE_ACCOUNT_PATH):
        print(f"Error: Service account key not found at {SERVICE_ACCOUNT_PATH}")
        print("Download it from Firebase Console -> Project Settings -> Service Accounts")
        sys.exit(1)
    
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    
    collection_ref = db.collection(COLLECTION_NAME)
    
    print(f"Uploading {len(stories)} stories to Firestore...")
    
    # Batch write for efficiency (max 500 per batch)
    batch_size = 500
    for i in range(0, len(stories), batch_size):
        batch = db.batch()
        batch_stories = stories[i:i + batch_size]
        
        for story in batch_stories:
            doc_ref = collection_ref.document()  # Auto-generate ID
            story['id'] = doc_ref.id  # Store the ID in the document
            batch.set(doc_ref, story)
        
        batch.commit()
        print(f"  Uploaded batch {i // batch_size + 1} ({len(batch_stories)} stories)")
    
    print(f"\n✅ Successfully uploaded {len(stories)} stories to Firestore!")


def main():
    parser = argparse.ArgumentParser(description='Seed Firestore with stories')
    parser.add_argument('--dry-run', action='store_true', 
                        help='Preview data without uploading')
    parser.add_argument('--limit', type=int, default=None,
                        help='Limit number of stories to upload')
    parser.add_argument('--csv', type=str, default=CSV_PATH,
                        help='Path to CSV file')
    
    args = parser.parse_args()
    
    print("Judge It - Firestore Seeding Script")
    print("=" * 40)
    
    # Read and process CSV
    print(f"\nReading CSV from: {args.csv}")
    stories = read_csv(args.csv, args.limit)
    print(f"Processed {len(stories)} stories")
    
    # Calculate verdict distribution
    verdicts = {'NTA': 0, 'YTA': 0, 'ESH': 0, 'OTHER': 0}
    for story in stories:
        yes = story['yes_votes']
        no = story['no_votes']
        if yes > no * 3:
            verdicts['NTA'] += 1
        elif no > yes * 3:
            verdicts['YTA'] += 1
        else:
            verdicts['ESH'] += 1
    
    print(f"\nVerdict Distribution (by vote ratio):")
    for v, count in verdicts.items():
        if count > 0:
            print(f"  {v}: {count} ({count/len(stories)*100:.1f}%)")
    
    # Upload to Firestore
    upload_to_firestore(stories, dry_run=args.dry_run)


if __name__ == '__main__':
    main()
