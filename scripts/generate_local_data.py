"""
Generate Local JSON Data for Judge It App
==========================================
Creates a bundled JSON file with stories for offline/fallback use.

Usage:
  python generate_local_data.py
  python generate_local_data.py --limit 3000

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
    elif score > 1000:
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
    else:
        base = random.randint(100, 300)
        yes_votes = base + random.randint(-50, 50)
        no_votes = random.randint(50, 200)
    
    return max(10, yes_votes), max(10, no_votes)


def generate_id() -> str:
    """Generate a random ID similar to Firestore document IDs."""
    import string
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for _ in range(20))


def load_and_process_data(limit: int = 3000) -> list[dict]:
    """Load stories from HuggingFace and process for local storage."""
    try:
        from datasets import load_dataset
    except ImportError:
        print("Error: 'datasets' library not installed.")
        print("Run: pip install datasets")
        sys.exit(1)
    
    print(f"Loading dataset from HuggingFace: {DATASET_NAME}")
    dataset = load_dataset(DATASET_NAME, split="train")
    
    print(f"Dataset loaded: {len(dataset)} total rows")
    
    if limit and limit < len(dataset):
        dataset = dataset.shuffle(seed=42).select(range(limit))
    
    stories = []
    for row in dataset:
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
                        help='Number of stories to include (default: 3000)')
    
    args = parser.parse_args()
    
    print("=" * 50)
    print("Judge It - Local Data Generator")
    print("=" * 50)
    
    # Load and process data
    stories = load_and_process_data(args.limit)
    print(f"Processed {len(stories)} valid stories")
    
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
