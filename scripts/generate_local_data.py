"""
Generate Local JSON Data for Judge It App
==========================================
Creates a bundled JSON file with TOP-SCORED stories for offline/fallback use.
Stories are sorted by Reddit score and randomized for display.

Usage:
  python generate_local_data.py
  python generate_local_data.py --top 3500

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

# Default: get top N stories by score
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


def generate_id() -> str:
    """Generate a random ID similar to Firestore document IDs."""
    import string
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for _ in range(20))


def load_and_process_data(top_count: int = DEFAULT_TOP_COUNT) -> list[dict]:
    """
    Load TOP stories from HuggingFace sorted by score (highest first).
    
    Args:
        top_count: Number of top-scored stories to include
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
    
    # Convert to list and sort by score (highest first)
    print("Sorting by score (highest first)...")
    all_stories = []
    for row in dataset:
        score = row.get('submission_score', 0) or 0
        title = row.get('submission_title', '') or ''
        text = row.get('submission_text', '') or ''
        top_comment = row.get('top_comment_1', '') or ''
        
        # Skip empty or too short
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
    print(f"Score range: {all_stories[0]['score']} (highest) to {all_stories[-1]['score']} (lowest)")
    
    # Take top N
    top_stories = all_stories[:top_count]
    print(f"Selected top {len(top_stories)} stories")
    print(f"Min score in selection: {top_stories[-1]['score']}")
    
    # Add votes and IDs
    stories = []
    for row in top_stories:
        yes_votes, no_votes = generate_votes_from_score(row['score'])
        
        story = {
            'id': generate_id(),
            'title': row['title'],
            'body': row['body'],
            'yes_votes': yes_votes,
            'no_votes': no_votes,
        }
        
        # Add top comment if available
        if row.get('top_comment'):
            story['top_comment'] = row['top_comment']
        
        stories.append(story)
    
    # Shuffle for random display order
    random.shuffle(stories)
    print("Shuffled stories for random display order")
    
    return stories


def main():
    parser = argparse.ArgumentParser(description='Generate local JSON with top-scored stories')
    parser.add_argument('--top', type=int, default=DEFAULT_TOP_COUNT,
                        help=f'Number of top-scored stories to include (default: {DEFAULT_TOP_COUNT})')
    
    args = parser.parse_args()
    
    print("=" * 50)
    print("Judge It - Local Data Generator (Top Scored)")
    print("=" * 50)
    print(f"Getting top {args.top} stories by Reddit score")
    
    # Load and process data
    stories = load_and_process_data(args.top)
    print(f"Processed {len(stories)} stories")
    
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
