"""
Medicine Saver BD - Medex.com.bd Scraper

This script scrapes medicine data from Medex.com.bd which provides 
comprehensive information including:
- Brand Name, Generic Name, Strength, Dosage Form
- Manufacturer, MRP (Maximum Retail Price)
- Indications, Side Effects, Contraindications
- Pack Size

Usage:
    python scrape_medex.py --category all        # Scrape all categories
    python scrape_medex.py --category antibiotics # Scrape specific category
    python scrape_medex.py --letter A             # Scrape brands starting with A
"""

import argparse
import csv
import json
import os
import re
import time
from pathlib import Path
from typing import Optional
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup
from tqdm import tqdm

# Configuration
OUTPUT_DIR = Path("output")
OUTPUT_DIR.mkdir(exist_ok=True)

MEDEX_BASE_URL = "https://medex.com.bd"
MEDEX_BRANDS_URL = f"{MEDEX_BASE_URL}/brands"
MEDEX_GENERICS_URL = f"{MEDEX_BASE_URL}/generics"

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
    "Connection": "keep-alive",
}

# Rate limiting
REQUEST_DELAY = 1.0  # Seconds between requests
MAX_RETRIES = 3


def safe_request(url: str, session: requests.Session, retries: int = MAX_RETRIES) -> Optional[BeautifulSoup]:
    """Make a request with retry logic and rate limiting."""
    for attempt in range(retries):
        try:
            time.sleep(REQUEST_DELAY)
            response = session.get(url, headers=HEADERS, timeout=30)
            response.raise_for_status()
            return BeautifulSoup(response.content, "lxml")
        except requests.RequestException as e:
            print(f"Attempt {attempt + 1}/{retries} failed for {url}: {e}")
            if attempt < retries - 1:
                time.sleep(2 ** attempt)  # Exponential backoff
    return None


def normalize_price(price_str: str) -> float:
    """Extract numeric price from string like '৳ 12.50' or 'Tk. 12.50'."""
    if not price_str:
        return 0.0
    # Remove currency symbols and extract numbers
    price = re.sub(r"[^\d.]", "", price_str)
    try:
        return float(price) if price else 0.0
    except ValueError:
        return 0.0


def normalize_text(text: str) -> str:
    """Clean and normalize text."""
    if not text:
        return ""
    return re.sub(r"\s+", " ", text.strip())


def get_brand_list_by_letter(letter: str, session: requests.Session, page: int = 1) -> list[str]:
    """Get all brand URLs starting with a specific letter on a specific page."""
    brand_urls = []
    url = f"{MEDEX_BRANDS_URL}?letter={letter.upper()}&page={page}"
    
    soup = safe_request(url, session)
    if not soup:
        return brand_urls
    
    # Find all brand links (adjust selector based on actual HTML)
    brand_links = soup.select("a.hoverable-block")
    if not brand_links:
        brand_links = soup.select("div.data-row-top a")
    
    for link in brand_links:
        href = link.get("href", "")
        # Medex URLs are like https://medex.com.bd/brands/13717/name
        if href and ("/brands/" in href or "/brand/" in href):
            brand_urls.append(urljoin(MEDEX_BASE_URL, href))
    
    return brand_urls


def scrape_brand_details(url: str, session: requests.Session) -> Optional[dict]:
    """Scrape detailed information for a single brand."""
    soup = safe_request(url, session)
    if not soup:
        return None
    
    try:
        # Extract brand name
        brand_name_elem = soup.select_one("h1.page-heading-1-l")
        if not brand_name_elem:
            brand_name_elem = soup.select_one("h1")
        brand_name = normalize_text(brand_name_elem.get_text()) if brand_name_elem else ""
        
        # Extract generic name
        generic_elem = soup.select_one("a[href*='/generic/']")
        generic_name = normalize_text(generic_elem.get_text()) if generic_elem else ""
        
        # Extract strength from brand name (often included like "Napa 500mg")
        strength = ""
        strength_match = re.search(r"(\d+(?:\.\d+)?\s*(?:mg|mcg|ml|gm|iu|%|IU|MG))", brand_name, re.IGNORECASE)
        if strength_match:
            strength = strength_match.group(1).lower().replace(" ", "")
        
        # Extract dosage form
        dosage_elem = soup.select_one("div.data-row-top small, span.dosage-form")
        dosage_form = normalize_text(dosage_elem.get_text()) if dosage_elem else ""
        if not dosage_form:
            # Try to find in brand name or description
            form_patterns = ["tablet", "capsule", "syrup", "injection", "cream", "ointment", "drops", "suspension"]
            for form in form_patterns:
                if form.lower() in brand_name.lower():
                    dosage_form = form.title()
                    break
        
        # Extract manufacturer
        manufacturer_elem = soup.select_one("a[href*='/company/']")
        manufacturer = normalize_text(manufacturer_elem.get_text()) if manufacturer_elem else ""
        
        # Extract price (MRP)
        price_elem = soup.select_one("span.package-price, div.price")
        price_text = price_elem.get_text() if price_elem else ""
        price = normalize_price(price_text)
        
        # Extract pack size
        pack_elem = soup.select_one("span.pack-size")
        pack_size = normalize_text(pack_elem.get_text()) if pack_elem else ""
        
        # Calculate unit price if pack info available
        unit_price = price
        pack_quantity = 1
        if pack_size:
            pack_match = re.search(r"(\d+)", pack_size)
            if pack_match:
                pack_quantity = int(pack_match.group(1))
                if pack_quantity > 0:
                    unit_price = round(price / pack_quantity, 2)
        
        # Extract medical info (indications, side effects)
        indication_section = soup.select_one("div#indication, div.indication")
        indication = normalize_text(indication_section.get_text()) if indication_section else ""
        
        side_effects_section = soup.select_one("div#side-effect, div.side-effects")
        side_effects = normalize_text(side_effects_section.get_text()) if side_effects_section else ""
        
        contraindication_section = soup.select_one("div#contraindication, div.contraindication")
        contraindication = normalize_text(contraindication_section.get_text()) if contraindication_section else ""
        
        return {
            "brand_name": brand_name,
            "generic_name": generic_name,
            "strength": strength,
            "dosage_form": dosage_form,
            "manufacturer": manufacturer,
            "mrp_price": price,
            "unit_price": unit_price,
            "pack_size": pack_size,
            "pack_quantity": pack_quantity,
            "indication": indication[:500] if indication else "",  # Truncate long text
            "side_effects": side_effects[:500] if side_effects else "",
            "contraindication": contraindication[:500] if contraindication else "",
            "source_url": url,
            "source": "medex",
        }
        
    except Exception as e:
        print(f"Error parsing {url}: {e}")
        return None


def scrape_all_brands(letters: list[str] = None) -> list[dict]:
    """Scrape all brands from Medex."""
    if letters is None:
        letters = list("ABCDEFGHIJKLMNOPQRSTUVWXYZ") + ["0-9"]
    
    all_medicines = []
    session = requests.Session()
    
    for letter in tqdm(letters, desc="Letters"):
        print(f"\nScraping brands starting with '{letter}'...")
        page = 1
        letter_brands_count = 0
        
        while True:
            # Get brands for current page
            try:
                brand_urls = get_brand_list_by_letter(letter, session, page=page)
            except Exception as e:
                print(f"Error fetching page {page} for letter {letter}: {e}")
                break
                
            if not brand_urls:
                print(f"No more brands found on page {page}. Moving to next letter.")
                break
                
            print(f"  Page {page}: Found {len(brand_urls)} brands")
            
            for url in tqdm(brand_urls, desc=f"Brands ({letter} p{page})", leave=False):
                medicine = scrape_brand_details(url, session)
                if medicine:
                    all_medicines.append(medicine)
            
            letter_brands_count += len(brand_urls)
            page += 1
            
        print(f"Finished '{letter}': {letter_brands_count} brands total")
    
    return all_medicines


def save_to_csv(medicines: list[dict], filepath: Path) -> None:
    """Save medicines to CSV."""
    if not medicines:
        print("No medicines to save!")
        return
    
    fieldnames = list(medicines[0].keys())
    
    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(medicines)
    
    print(f"Saved {len(medicines)} medicines to {filepath}")


def save_to_json(medicines: list[dict], filepath: Path) -> None:
    """Save medicines to JSON."""
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(medicines, f, ensure_ascii=False, indent=2)
    
    print(f"Saved {len(medicines)} medicines to {filepath}")


def main():
    parser = argparse.ArgumentParser(description="Scrape medicine data from Medex.com.bd")
    parser.add_argument(
        "--letter",
        type=str,
        default=None,
        help="Scrape brands starting with specific letter (e.g., A, B, C)",
    )
    parser.add_argument(
        "--output-format",
        choices=["csv", "json", "both"],
        default="both",
        help="Output format",
    )
    parser.add_argument(
        "--sample",
        action="store_true",
        help="Only scrape a small sample (first 10 brands from letter A)",
    )
    parser.add_argument(
        "--stealth",
        action="store_true",
        help="Run in stealth mode (10s delay) to avoid blocking",
    )
    args = parser.parse_args()
    
    if args.stealth:
        global REQUEST_DELAY
        REQUEST_DELAY = 10.0
        print("🕵️ Stealth Mode Activated: Delay set to 10 seconds")
    
    print("=" * 60)
    print("Medicine Saver BD - Medex.com.bd Scraper")
    print("=" * 60)
    
    if args.sample:
        print("\n[SAMPLE MODE] Scraping only 10 brands from letter A...")
        session = requests.Session()
        brand_urls = get_brand_list_by_letter("A", session)[:10]
        medicines = []
        for url in tqdm(brand_urls, desc="Brands"):
            medicine = scrape_brand_details(url, session)
            if medicine:
                medicines.append(medicine)
    elif args.letter:
        letters = [args.letter.upper()]
        medicines = scrape_all_brands(letters)
    else:
        medicines = scrape_all_brands()
    
    # Save outputs
    if args.output_format in ["csv", "both"]:
        save_to_csv(medicines, OUTPUT_DIR / "medex_medicines.csv")
    
    if args.output_format in ["json", "both"]:
        save_to_json(medicines, OUTPUT_DIR / "medex_medicines.json")
    
    print(f"\n{'=' * 60}")
    print(f"Scraping complete! Total records: {len(medicines)}")
    print(f"Next step: Run 'python cross_verify.py' to verify prices")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()
