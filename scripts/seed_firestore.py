"""
Firestore Seeding Script for Judge It App
==========================================
Seeds the 'stories' collection with realistic vote data.
Downloads data directly from HuggingFace dataset.

Usage:
  python seed_firestore.py                    # Normal run (1000 stories)
  python seed_firestore.py --dry-run          # Preview without uploading
  python seed_firestore.py --limit 100        # Upload only first 100 stories

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
DATASET_NAME = "MattBoraske/reddit-AITA-submissions-and-comments-multiclass"


def generate_votes_from_score(score: int) -> tuple[int, int]:
    """
    Generate realistic vote counts based on Reddit submission score.
    Higher scores tend to be clearer NTA/YTA cases.
    
    Args:
        score: Reddit submission score (upvotes - downvotes)
    
    Returns:
        Tuple of (yes_votes, no_votes)
    """
    # Normalize score to determine vote distribution
    # Higher score posts tend to have clearer community consensus
    
    if score > 50000:
        # Very high engagement - clear verdict
        if random.random() > 0.3:  # 70% NTA for popular posts
            yes_votes = random.randint(500, 900)
            no_votes = random.randint(20, 80)
        else:
            yes_votes = random.randint(20, 80)
            no_votes = random.randint(500, 900)
    elif score > 10000:
        # High engagement
        if random.random() > 0.4:
            yes_votes = random.randint(400, 700)
            no_votes = random.randint(30, 100)
        else:
            yes_votes = random.randint(30, 100)
            no_votes = random.randint(400, 700)
    elif score > 1000:
        # Medium engagement
        ratio = random.random()
        if ratio > 0.6:
            yes_votes = random.randint(300, 600)
            no_votes = random.randint(40, 120)
        elif ratio > 0.3:
            yes_votes = random.randint(40, 120)
            no_votes = random.randint(300, 600)
        else:
            # ESH - split votes
            base = random.randint(150, 250)
            yes_votes = base + random.randint(-30, 30)
            no_votes = base + random.randint(-30, 30)
    else:
        # Lower engagement - more varied
        base = random.randint(100, 300)
        yes_votes = base + random.randint(-50, 50)
        no_votes = random.randint(50, 200)
    
    return max(10, yes_votes), max(10, no_votes)


def load_from_huggingface(limit: int = 1000) -> list[dict]:
    """
    Load stories directly from HuggingFace dataset.
    
    Args:
        limit: Maximum number of stories to load
    
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
    
    # Load the dataset
    dataset = load_dataset(DATASET_NAME, split="train")
    
    print(f"Dataset loaded: {len(dataset)} total rows")
    print(f"Columns: {dataset.column_names}")
    
    # Sample or limit the dataset
    if limit and limit < len(dataset):
        # Shuffle and take first N
        dataset = dataset.shuffle(seed=42).select(range(limit))
    
    stories = []
    for row in dataset:
        title = row.get('submission_title', '') or ''
        text = row.get('submission_text', '') or ''
        score = row.get('submission_score', 0) or 0
        
        # Skip empty entries
        if not title.strip() or not text.strip():
            continue
        
        # Skip very short texts (likely deleted posts)
        if len(text) < 100:
            continue
        
        # Generate votes based on score
        yes_votes, no_votes = generate_votes_from_score(score)
        
        story = {
            'title': title.strip(),
            'body': text.strip(),
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
            title_preview = story['title'][:80] + "..." if len(story['title']) > 80 else story['title']
            body_preview = story['body'][:150] + "..." if len(story['body']) > 150 else story['body']
            print(f"Title: {title_preview}")
            print(f"Body: {body_preview}")
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
    
    collection_ref = db.collection(COLLECTION_NAME)
    
    print(f"\nUploading {len(stories)} stories to Firestore...")
    
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
        print(f"  Uploaded batch {i // batch_size + 1}/{(len(stories) // batch_size) + 1} ({len(batch_stories)} stories)")
    
    print(f"\n✅ Successfully uploaded {len(stories)} stories to Firestore!")


def main():
    parser = argparse.ArgumentParser(description='Seed Firestore with AITA stories from HuggingFace')
    parser.add_argument('--dry-run', action='store_true', 
                        help='Preview data without uploading')
    parser.add_argument('--limit', type=int, default=1000,
                        help='Number of stories to upload (default: 1000)')
    
    args = parser.parse_args()
    
    print("=" * 50)
    print("Judge It - Firestore Seeding Script")
    print("=" * 50)
    print(f"Source: HuggingFace - {DATASET_NAME}")
    print(f"Limit: {args.limit} stories")
    print("=" * 50)
    
    # Load from HuggingFace
    stories = load_from_huggingface(args.limit)
    print(f"\nProcessed {len(stories)} valid stories")
    
    # Calculate vote distribution stats
    nta_count = sum(1 for s in stories if s['yes_votes'] > s['no_votes'] * 2)
    yta_count = sum(1 for s in stories if s['no_votes'] > s['yes_votes'] * 2)
    esh_count = len(stories) - nta_count - yta_count
    
    print(f"\nVote Distribution:")
    print(f"  NTA (clear majority): {nta_count} ({nta_count/len(stories)*100:.1f}%)")
    print(f"  YTA (clear majority): {yta_count} ({yta_count/len(stories)*100:.1f}%)")
    print(f"  ESH/Split: {esh_count} ({esh_count/len(stories)*100:.1f}%)")
    
    # Upload to Firestore
    upload_to_firestore(stories, dry_run=args.dry_run)


if __name__ == '__main__':
    main()
