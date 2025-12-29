"""
Medicine Saver BD - DGDA Data Scraper

This script fetches medicine data from the DGDA website or uses a Kaggle backup.
It outputs a normalized CSV file for further processing.

Usage:
    python scraper.py --source dgda      # Scrape from DGDA (requires internet)
    python scraper.py --source kaggle    # Use downloaded Kaggle dataset
"""

import argparse
import csv
import os
import re
import time
from pathlib import Path

import requests
from bs4 import BeautifulSoup
from tqdm import tqdm

# Configuration
OUTPUT_DIR = Path("output")
RAW_CSV_PATH = OUTPUT_DIR / "raw_medicines.csv"

# DGDA URL pattern (may need adjustment based on actual site structure)
DGDA_BASE_URL = "https://dgda.gov.bd"
DGDA_SEARCH_URL = f"{DGDA_BASE_URL}/index.php/allophatic-registered-products"

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
}


def normalize_text(text: str) -> str:
    """Clean and normalize text fields."""
    if not text:
        return ""
    # Remove extra whitespace
    text = re.sub(r"\s+", " ", text.strip())
    return text


def normalize_strength(strength: str) -> str:
    """Standardize strength notation (e.g., '500 Mg' -> '500mg')."""
    if not strength:
        return ""
    # Convert to lowercase and remove spaces
    strength = strength.lower().replace(" ", "")
    # Standardize units
    strength = re.sub(r"(\d+)\s?(mg|mcg|ml|gm|iu)", r"\1\2", strength)
    return strength


def scrape_dgda_page(page_num: int) -> list[dict]:
    """Scrape a single page from DGDA."""
    medicines = []

    try:
        url = f"{DGDA_SEARCH_URL}?page={page_num}"
        response = requests.get(url, headers=HEADERS, timeout=30)
        response.raise_for_status()

        soup = BeautifulSoup(response.content, "lxml")

        # Find the medicine table (adjust selectors based on actual HTML structure)
        table = soup.find("table", class_="table")
        if not table:
            return medicines

        rows = table.find_all("tr")[1:]  # Skip header row

        for row in rows:
            cols = row.find_all("td")
            if len(cols) >= 5:
                medicine = {
                    "brand_name": normalize_text(cols[0].get_text()),
                    "generic_name": normalize_text(cols[1].get_text()),
                    "strength": normalize_strength(cols[2].get_text()),
                    "dosage_form": normalize_text(cols[3].get_text()),
                    "manufacturer": normalize_text(cols[4].get_text()),
                    "price": "",  # DGDA may not include price directly
                }
                medicines.append(medicine)

    except requests.RequestException as e:
        print(f"Error fetching page {page_num}: {e}")

    return medicines


def scrape_dgda(max_pages: int = 100) -> list[dict]:
    """Scrape all pages from DGDA."""
    all_medicines = []

    print("Scraping DGDA website...")
    for page in tqdm(range(1, max_pages + 1), desc="Pages"):
        medicines = scrape_dgda_page(page)
        if not medicines:
            print(f"\nNo more data at page {page}. Stopping.")
            break
        all_medicines.extend(medicines)
        time.sleep(1)  # Be polite to the server

    return all_medicines


def load_kaggle_data(filepath: str) -> list[dict]:
    """Load medicine data from a Kaggle CSV file."""
    medicines = []

    print(f"Loading data from {filepath}...")
    with open(filepath, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            medicine = {
                "brand_name": normalize_text(row.get("Brand Name", "")),
                "generic_name": normalize_text(row.get("Generic", "")),
                "strength": normalize_strength(row.get("Strength", "")),
                "dosage_form": normalize_text(row.get("Dosage Form", "")),
                "manufacturer": normalize_text(row.get("Manufacturer", "")),
                "price": row.get("Unit Price", ""),
            }
            medicines.append(medicine)

    return medicines


def save_to_csv(medicines: list[dict], filepath: Path) -> None:
    """Save medicines to a CSV file."""
    filepath.parent.mkdir(parents=True, exist_ok=True)

    fieldnames = [
        "brand_name",
        "generic_name",
        "strength",
        "dosage_form",
        "manufacturer",
        "price",
    ]

    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(medicines)

    print(f"Saved {len(medicines)} medicines to {filepath}")


def main():
    parser = argparse.ArgumentParser(description="Scrape medicine data for Medicine Saver BD")
    parser.add_argument(
        "--source",
        choices=["dgda", "kaggle"],
        default="kaggle",
        help="Data source (default: kaggle)",
    )
    parser.add_argument(
        "--kaggle-file",
        default="input/kaggle_medicines.csv",
        help="Path to Kaggle CSV file (if using kaggle source)",
    )
    parser.add_argument(
        "--max-pages",
        type=int,
        default=500,
        help="Maximum pages to scrape from DGDA",
    )
    args = parser.parse_args()

    if args.source == "dgda":
        medicines = scrape_dgda(args.max_pages)
    else:
        if not os.path.exists(args.kaggle_file):
            print(f"Error: Kaggle file not found at {args.kaggle_file}")
            print("Please download from: https://www.kaggle.com/datasets/...")
            return
        medicines = load_kaggle_data(args.kaggle_file)

    # Save raw data
    save_to_csv(medicines, RAW_CSV_PATH)

    print(f"\nScraping complete! Total records: {len(medicines)}")
    print(f"Next step: Run 'python validate.py' to validate the data.")


if __name__ == "__main__":
    main()
