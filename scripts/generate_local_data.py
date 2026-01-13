"""
Generate Local JSON Data for Judge It App
==========================================
Creates a bundled JSON file with high-engagement stories for offline/fallback use.

Usage:
  python generate_local_data.py
  python generate_local_data.py --limit 3000 --min-score 5000

Requirements:
  - pip install datasets
"""

import argparse
import random
import json
import os
import sys

OUTPUT_PATH = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data', 'stories.json')
DATASET_NAME = "MattBoraske/reddit-AITA-submissions-and-comments-multiclass"

# Default minimum score for "interesting" stories
DEFAULT_MIN_SCORE = 5000


def generate_votes_from_score(score: int) -> tuple[int, int]:
    """Generate realistic vote counts based on Reddit submission score."""
    if score > 50000:
        if random.random() > 0.3:
            yes_votes = random.randint(500, 900)
            no_votes = random.randint(20, 80)
        else:
            yes_votes = random.randint(20, 80)
            no_votes = random.randint(500, 900)
    elif score > 10000:
        if random.random() > 0.4:
            yes_votes = random.randint(400, 700)
            no_votes = random.randint(30, 100)
        else:
            yes_votes = random.randint(30, 100)
            no_votes = random.randint(400, 700)
    else:  # score > 5000 (our minimum)
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


def generate_id() -> str:
    """Generate a random ID similar to Firestore document IDs."""
    import string
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for _ in range(20))


def load_and_process_data(limit: int = 3000, min_score: int = DEFAULT_MIN_SCORE) -> list[dict]:
    """
    Load high-engagement stories from HuggingFace and process for local storage.
    
    Args:
        limit: Maximum number of stories to include
        min_score: Minimum Reddit score for a story to be included
    """
    try:
        from datasets import load_dataset
    except ImportError:
        print("Error: 'datasets' library not installed.")
        print("Run: pip install datasets")
        sys.exit(1)
    
    print(f"Loading dataset from HuggingFace: {DATASET_NAME}")
    dataset = load_dataset(DATASET_NAME, split="train")
    
    print(f"Dataset loaded: {len(dataset)} total rows")
    print(f"Filtering for stories with score >= {min_score}...")
    
    # Filter for high-engagement stories first
    high_engagement = []
    for row in dataset:
        score = row.get('submission_score', 0) or 0
        if score >= min_score:
            high_engagement.append(row)
    
    print(f"Found {len(high_engagement)} high-engagement stories")
    
    # Shuffle and limit
    random.seed(42)
    random.shuffle(high_engagement)
    if limit and len(high_engagement) > limit:
        high_engagement = high_engagement[:limit]
    
    stories = []
    for row in high_engagement:
        title = row.get('submission_title', '') or ''
        text = row.get('submission_text', '') or ''
        score = row.get('submission_score', 0) or 0
        
        if not title.strip() or not text.strip():
            continue
        if len(text) < 100:
            continue
        
        yes_votes, no_votes = generate_votes_from_score(score)
        
        story = {
            'id': generate_id(),
            'title': title.strip(),
            'body': text.strip(),
            'yes_votes': yes_votes,
            'no_votes': no_votes,
        }
        stories.append(story)
    
    return stories


def main():
    parser = argparse.ArgumentParser(description='Generate local JSON data for offline use')
    parser.add_argument('--limit', type=int, default=3000,
                        help='Max number of stories to include (default: 3000)')
    parser.add_argument('--min-score', type=int, default=DEFAULT_MIN_SCORE,
                        help=f'Minimum Reddit score for stories (default: {DEFAULT_MIN_SCORE})')
    
    args = parser.parse_args()
    
    print("=" * 50)
    print("Judge It - Local Data Generator (High Engagement)")
    print("=" * 50)
    print(f"Min score filter: {args.min_score}")
    print(f"Max stories: {args.limit}")
    
    # Load and process data
    stories = load_and_process_data(args.limit, args.min_score)
    print(f"Processed {len(stories)} valid high-engagement stories")
    
    # Ensure output directory exists
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    
    # Write to JSON
    with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
        json.dump({'stories': stories}, f, ensure_ascii=False)
    
    file_size = os.path.getsize(OUTPUT_PATH) / (1024 * 1024)
    print(f"\n✅ Generated {OUTPUT_PATH}")
    print(f"   File size: {file_size:.2f} MB")
    print(f"   Stories: {len(stories)}")


if __name__ == '__main__':
    main()
