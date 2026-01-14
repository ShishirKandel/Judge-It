"""
Firestore Seeding Script for Judge It App
==========================================
Seeds the 'stories' collection with TOP-SCORED stories from Reddit.
Stories are sorted by score and the top N are uploaded.

Usage:
  python seed_firestore.py                    # Normal run (3500 top stories)
  python seed_firestore.py --dry-run          # Preview without uploading
  python seed_firestore.py --top 3000         # Upload top 3000 stories
  python seed_firestore.py --clear            # Clear existing stories first

Requirements:
  - pip install -r requirements.txt
  - Place your Firebase service account key as 'serviceAccountKey.json' in this folder
"""

import argparse
import random
import os
import sys

# Configuration
SERVICE_ACCOUNT_PATH = os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json')
COLLECTION_NAME = 'stories'
APP_STATS_COLLECTION = 'app_stats'
GLOBAL_STATS_DOC = 'global'
DATASET_NAME = "MattBoraske/reddit-AITA-submissions-and-comments-multiclass"

# Default: top N stories by score
DEFAULT_TOP_COUNT = 3500


def generate_votes_from_score(score: int) -> tuple[int, int]:
    """Generate realistic vote counts based on Reddit submission score."""
    if score > 50000:
        if random.random() > 0.3:
            yes_votes = random.randint(500, 900)
            no_votes = random.randint(20, 80)
        else:
            yes_votes = random.randint(20, 80)
            no_votes = random.randint(500, 900)
    elif score > 20000:
        if random.random() > 0.4:
            yes_votes = random.randint(400, 700)
            no_votes = random.randint(30, 100)
        else:
            yes_votes = random.randint(30, 100)
            no_votes = random.randint(400, 700)
    else:
        ratio = random.random()
        if ratio > 0.6:
            yes_votes = random.randint(300, 600)
            no_votes = random.randint(40, 120)
        elif ratio > 0.3:
            yes_votes = random.randint(40, 120)
            no_votes = random.randint(300, 600)
        else:
            base = random.randint(150, 250)
            yes_votes = base + random.randint(-30, 30)
            no_votes = base + random.randint(-30, 30)
    
    return max(10, yes_votes), max(10, no_votes)


def load_from_huggingface(top_count: int = DEFAULT_TOP_COUNT) -> list[dict]:
    """
    Load TOP stories from HuggingFace dataset sorted by score.
    
    Args:
        top_count: Number of top-scored stories to load
    
    Returns:
        List of story dictionaries ready for Firestore
    """
    try:
        from datasets import load_dataset
    except ImportError:
        print("Error: 'datasets' library not installed.")
        print("Run: pip install datasets")
        sys.exit(1)
    
    print(f"Loading dataset from HuggingFace: {DATASET_NAME}")
    print("This may take a moment on first run (downloading ~271MB)...")
    
    dataset = load_dataset(DATASET_NAME, split="train")
    
    print(f"Dataset loaded: {len(dataset)} total rows")
    
    # Convert to list and sort by score
    print("Sorting by score (highest first)...")
    all_stories = []
    for row in dataset:
        score = row.get('submission_score', 0) or 0
        title = row.get('submission_title', '') or ''
        text = row.get('submission_text', '') or ''
        top_comment = row.get('top_comment_1', '') or ''
        
        if not title.strip() or not text.strip():
            continue
        if len(text) < 100:
            continue
        
        all_stories.append({
            'score': score,
            'title': title.strip(),
            'body': text.strip(),
            'top_comment': top_comment.strip() if top_comment else None,
        })
    
    # Sort by score descending
    all_stories.sort(key=lambda x: x['score'], reverse=True)
    
    print(f"Valid stories: {len(all_stories)}")
    print(f"Score range: {all_stories[0]['score']} to {all_stories[-1]['score']}")
    
    # Take top N
    top_stories = all_stories[:top_count]
    print(f"Selected top {len(top_stories)} stories (min score: {top_stories[-1]['score']})")
    
    # Add votes
    stories = []
    for row in top_stories:
        yes_votes, no_votes = generate_votes_from_score(row['score'])
        
        story = {
            'title': row['title'],
            'body': row['body'],
            'yes_votes': yes_votes,
            'no_votes': no_votes,
        }
        
        # Add top comment if available
        if row.get('top_comment'):
            story['top_comment'] = row['top_comment']
        
        stories.append(story)
    
    return stories


def initialize_app_stats(db, total_votes: int):
    """Initialize or update the global app stats document."""
    from datetime import datetime

    print("\nInitializing app_stats collection...")

    stats_ref = db.collection(APP_STATS_COLLECTION).document(GLOBAL_STATS_DOC)

    # Calculate initial total judgments based on seeded vote counts
    initial_stats = {
        'total_judgments': total_votes,
        'active_users_today': random.randint(50, 200),
        'stories_judged_today': random.randint(500, 2000),
        'last_reset': datetime.utcnow(),
    }

    stats_ref.set(initial_stats)
    print(f"✅ Initialized app_stats/global with:")
    print(f"   total_judgments: {initial_stats['total_judgments']}")
    print(f"   active_users_today: {initial_stats['active_users_today']}")
    print(f"   stories_judged_today: {initial_stats['stories_judged_today']}")


def clear_collection(db):
    """Delete all documents in the stories collection."""
    print(f"Clearing existing '{COLLECTION_NAME}' collection...")
    
    docs = db.collection(COLLECTION_NAME).stream()
    deleted = 0
    batch_size = 500
    batch = db.batch()
    
    for doc in docs:
        batch.delete(doc.reference)
        deleted += 1
        
        if deleted % batch_size == 0:
            batch.commit()
            batch = db.batch()
            print(f"  Deleted {deleted} documents...")
    
    if deleted % batch_size != 0:
        batch.commit()
    
    print(f"✅ Deleted {deleted} documents")
    return deleted


def upload_to_firestore(stories: list[dict], dry_run: bool = False, clear: bool = False):
    """Upload stories to Firestore."""
    if dry_run:
        print("\n=== DRY RUN MODE ===")
        print(f"Would upload {len(stories)} stories to '{COLLECTION_NAME}' collection\n")
        
        print("Sample stories (first 3):")
        for i, story in enumerate(stories[:3]):
            print(f"\n--- Story {i+1} ---")
            title_preview = story['title'][:80] + "..." if len(story['title']) > 80 else story['title']
            body_preview = story['body'][:150] + "..." if len(story['body']) > 150 else story['body']
            print(f"Title: {title_preview}")
            print(f"Body: {body_preview}")
            print(f"Yes Votes: {story['yes_votes']}")
            print(f"No Votes: {story['no_votes']}")
        return
    
    # Initialize Firebase
    if not os.path.exists(SERVICE_ACCOUNT_PATH):
        print(f"Error: Service account key not found at {SERVICE_ACCOUNT_PATH}")
        print("Download it from Firebase Console -> Project Settings -> Service Accounts")
        sys.exit(1)
    
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore
    except ImportError:
        print("Error: 'firebase-admin' library not installed.")
        print("Run: pip install firebase-admin")
        sys.exit(1)
    
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    
    # Clear existing data if requested
    if clear:
        clear_collection(db)
    
    collection_ref = db.collection(COLLECTION_NAME)
    
    print(f"\nUploading {len(stories)} stories to Firestore...")
    
    # Batch write (max 500 per batch)
    batch_size = 500
    for i in range(0, len(stories), batch_size):
        batch = db.batch()
        batch_stories = stories[i:i + batch_size]
        
        for story in batch_stories:
            doc_ref = collection_ref.document()
            story['id'] = doc_ref.id
            batch.set(doc_ref, story)
        
        batch.commit()
        print(f"  Uploaded batch {i // batch_size + 1}/{(len(stories) // batch_size) + 1} ({len(batch_stories)} stories)")

    print(f"\n✅ Successfully uploaded {len(stories)} stories to Firestore!")

    # Calculate total votes for app_stats initialization
    total_votes = sum(s['yes_votes'] + s['no_votes'] for s in stories)
    initialize_app_stats(db, total_votes)


def main():
    parser = argparse.ArgumentParser(description='Seed Firestore with top-scored AITA stories')
    parser.add_argument('--dry-run', action='store_true', 
                        help='Preview data without uploading')
    parser.add_argument('--top', type=int, default=DEFAULT_TOP_COUNT,
                        help=f'Number of top stories to upload (default: {DEFAULT_TOP_COUNT})')
    parser.add_argument('--clear', action='store_true',
                        help='Clear existing stories before uploading')
    
    args = parser.parse_args()
    
    print("=" * 50)
    print("Judge It - Firestore Seeding Script (Top Scored)")
    print("=" * 50)
    print(f"Source: HuggingFace - {DATASET_NAME}")
    print(f"Top stories: {args.top}")
    print("=" * 50)
    
    # Load from HuggingFace
    stories = load_from_huggingface(args.top)
    print(f"\nProcessed {len(stories)} top stories")
    
    # Calculate vote distribution stats
    nta_count = sum(1 for s in stories if s['yes_votes'] > s['no_votes'] * 2)
    yta_count = sum(1 for s in stories if s['no_votes'] > s['yes_votes'] * 2)
    esh_count = len(stories) - nta_count - yta_count
    
    print(f"\nVote Distribution:")
    print(f"  NTA (clear majority): {nta_count} ({nta_count/len(stories)*100:.1f}%)")
    print(f"  YTA (clear majority): {yta_count} ({yta_count/len(stories)*100:.1f}%)")
    print(f"  ESH/Split: {esh_count} ({esh_count/len(stories)*100:.1f}%)")
    
    # Upload to Firestore
    upload_to_firestore(stories, dry_run=args.dry_run, clear=args.clear)


if __name__ == '__main__':
    main()
