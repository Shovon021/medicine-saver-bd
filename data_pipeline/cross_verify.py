"""
Medicine Saver BD - Cross-Verification Algorithm

This script implements the "Data Integrity Engine" that:
1. Loads data from multiple sources (Medex, DGDA, Kaggle)
2. Normalizes and matches medicines across sources
3. Compares prices and flags discrepancies
4. Produces a verified, authoritative dataset

Price Verification Rules:
- DGDA is the "Golden Source" for legal MRP
- Medex is the "Rich Source" for medical info
- Discrepancies > 10% are flagged for review
- Crowdsourced reports influence confidence scores

Usage:
    python cross_verify.py --medex output/medex_medicines.csv --dgda output/raw_medicines.csv
"""

import argparse
import csv
import json
import re
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

# Configuration
OUTPUT_DIR = Path("output")
VERIFIED_OUTPUT = OUTPUT_DIR / "verified_medicines.csv"
DISCREPANCY_REPORT = OUTPUT_DIR / "price_discrepancies.csv"

# Price discrepancy threshold (10%)
PRICE_TOLERANCE = 0.10

# Confidence levels
CONFIDENCE_HIGH = "HIGH"
CONFIDENCE_MEDIUM = "MEDIUM"
CONFIDENCE_LOW = "LOW"


@dataclass
class MedicineRecord:
    """Represents a medicine record from any source."""
    brand_name: str
    generic_name: str = ""
    strength: str = ""
    dosage_form: str = ""
    manufacturer: str = ""
    price: float = 0.0
    unit_price: float = 0.0
    pack_size: str = ""
    indication: str = ""
    side_effects: str = ""
    source: str = ""
    source_url: str = ""
    
    def get_match_key(self) -> str:
        """Generate a normalized key for matching across sources."""
        # Normalize brand name: lowercase, remove special chars
        brand = re.sub(r"[^a-z0-9]", "", self.brand_name.lower())
        # Normalize strength
        strength = re.sub(r"[^a-z0-9]", "", self.strength.lower()) if self.strength else ""
        return f"{brand}_{strength}"


@dataclass
class VerifiedMedicine:
    """A medicine record verified across multiple sources."""
    brand_name: str
    generic_name: str
    strength: str
    dosage_form: str
    manufacturer: str
    verified_price: float
    unit_price: float
    pack_size: str
    indication: str
    side_effects: str
    confidence: str
    price_sources: dict = field(default_factory=dict)
    discrepancy_flag: bool = False
    discrepancy_details: str = ""
    last_updated: str = ""


def normalize_strength(strength: str) -> str:
    """Standardize strength notation."""
    if not strength:
        return ""
    strength = strength.lower().replace(" ", "")
    return re.sub(r"(\d+(?:\.\d+)?)(\s*)(mg|mcg|ml|gm|iu|%)", r"\1\3", strength)


def normalize_brand(name: str) -> str:
    """Normalize brand name for matching."""
    if not name:
        return ""
    # Remove strength info from brand name
    name = re.sub(r"\d+(?:\.\d+)?\s*(?:mg|mcg|ml|gm|iu|%)", "", name, flags=re.IGNORECASE)
    # Remove special characters and extra spaces
    name = re.sub(r"[^a-zA-Z0-9\s]", "", name)
    return " ".join(name.split()).strip().title()


def load_medex_data(filepath: Path) -> list[MedicineRecord]:
    """Load medicine data from Medex CSV."""
    records = []
    
    if not filepath.exists():
        print(f"Warning: Medex file not found at {filepath}")
        return records
    
    with open(filepath, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                unit_price = float(row.get("unit_price", 0) or 0)
                mrp_price = float(row.get("mrp_price", 0) or 0)
            except ValueError:
                unit_price = 0.0
                mrp_price = 0.0
            
            record = MedicineRecord(
                brand_name=row.get("brand_name", ""),
                generic_name=row.get("generic_name", ""),
                strength=row.get("strength", ""),
                dosage_form=row.get("dosage_form", ""),
                manufacturer=row.get("manufacturer", ""),
                price=mrp_price,
                unit_price=unit_price,
                pack_size=row.get("pack_size", ""),
                indication=row.get("indication", ""),
                side_effects=row.get("side_effects", ""),
                source="medex",
                source_url=row.get("source_url", ""),
            )
            records.append(record)
    
    print(f"Loaded {len(records)} records from Medex")
    return records


def load_dgda_data(filepath: Path) -> list[MedicineRecord]:
    """Load medicine data from DGDA/Kaggle CSV."""
    records = []
    
    if not filepath.exists():
        print(f"Warning: DGDA file not found at {filepath}")
        return records
    
    with open(filepath, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                price = float(row.get("price", 0) or 0)
            except ValueError:
                price = 0.0
            
            record = MedicineRecord(
                brand_name=row.get("brand_name", ""),
                generic_name=row.get("generic_name", ""),
                strength=row.get("strength", ""),
                dosage_form=row.get("dosage_form", ""),
                manufacturer=row.get("manufacturer", ""),
                price=price,
                unit_price=price,  # Assume unit price for this source
                source="dgda",
            )
            records.append(record)
    
    print(f"Loaded {len(records)} records from DGDA")
    return records


def build_match_index(records: list[MedicineRecord]) -> dict[str, list[MedicineRecord]]:
    """Build an index for fast matching."""
    index = defaultdict(list)
    for record in records:
        key = record.get_match_key()
        index[key].append(record)
    return index


def calculate_price_discrepancy(prices: list[float]) -> tuple[float, float, bool]:
    """
    Calculate price discrepancy between sources.
    Returns: (average_price, max_deviation_percent, has_discrepancy)
    """
    if not prices:
        return 0.0, 0.0, False
    
    # Filter out zero prices
    valid_prices = [p for p in prices if p > 0]
    if not valid_prices:
        return 0.0, 0.0, False
    
    avg_price = sum(valid_prices) / len(valid_prices)
    if avg_price == 0:
        return 0.0, 0.0, False
    
    max_deviation = max(abs(p - avg_price) / avg_price for p in valid_prices)
    has_discrepancy = max_deviation > PRICE_TOLERANCE
    
    return avg_price, max_deviation * 100, has_discrepancy


def verify_and_merge(
    medex_records: list[MedicineRecord],
    dgda_records: list[MedicineRecord]
) -> tuple[list[VerifiedMedicine], list[dict]]:
    """
    Cross-verify and merge data from multiple sources.
    Returns: (verified_medicines, discrepancy_records)
    """
    verified = []
    discrepancies = []
    
    # Build indices
    dgda_index = build_match_index(dgda_records)
    processed_keys = set()
    
    print("\nCross-verifying medicines...")
    
    # Start with Medex as the rich source
    for medex_record in medex_records:
        key = medex_record.get_match_key()
        
        if key in processed_keys:
            continue
        processed_keys.add(key)
        
        # Find matching DGDA records
        dgda_matches = dgda_index.get(key, [])
        
        # Collect prices from all sources
        price_sources = {"medex": medex_record.unit_price}
        all_prices = [medex_record.unit_price]
        
        for dgda in dgda_matches:
            if dgda.unit_price > 0:
                price_sources["dgda"] = dgda.unit_price
                all_prices.append(dgda.unit_price)
        
        # Calculate verified price and discrepancy
        avg_price, deviation, has_discrepancy = calculate_price_discrepancy(all_prices)
        
        # Determine confidence level
        if len(all_prices) >= 2 and not has_discrepancy:
            confidence = CONFIDENCE_HIGH
        elif len(all_prices) >= 2:
            confidence = CONFIDENCE_MEDIUM
        else:
            confidence = CONFIDENCE_LOW
        
        # Use DGDA price as authoritative if available, otherwise Medex
        if "dgda" in price_sources and price_sources["dgda"] > 0:
            verified_price = price_sources["dgda"]
        else:
            verified_price = medex_record.unit_price
        
        # Merge medical info from Medex (rich source)
        verified_med = VerifiedMedicine(
            brand_name=normalize_brand(medex_record.brand_name),
            generic_name=medex_record.generic_name,
            strength=normalize_strength(medex_record.strength),
            dosage_form=medex_record.dosage_form,
            manufacturer=medex_record.manufacturer,
            verified_price=round(verified_price, 2),
            unit_price=round(medex_record.unit_price, 2),
            pack_size=medex_record.pack_size,
            indication=medex_record.indication,
            side_effects=medex_record.side_effects,
            confidence=confidence,
            price_sources=price_sources,
            discrepancy_flag=has_discrepancy,
            discrepancy_details=f"{deviation:.1f}% deviation" if has_discrepancy else "",
        )
        
        verified.append(verified_med)
        
        # Record discrepancies
        if has_discrepancy:
            discrepancies.append({
                "brand_name": verified_med.brand_name,
                "strength": verified_med.strength,
                "medex_price": price_sources.get("medex", 0),
                "dgda_price": price_sources.get("dgda", 0),
                "deviation_percent": deviation,
                "action_required": "REVIEW",
            })
    
    # Add DGDA-only records
    for key, dgda_list in dgda_index.items():
        if key not in processed_keys:
            dgda = dgda_list[0]  # Take first match
            verified_med = VerifiedMedicine(
                brand_name=normalize_brand(dgda.brand_name),
                generic_name=dgda.generic_name,
                strength=normalize_strength(dgda.strength),
                dosage_form=dgda.dosage_form,
                manufacturer=dgda.manufacturer,
                verified_price=round(dgda.unit_price, 2),
                unit_price=round(dgda.unit_price, 2),
                pack_size="",
                indication="",
                side_effects="",
                confidence=CONFIDENCE_LOW,  # Single source
                price_sources={"dgda": dgda.unit_price},
            )
            verified.append(verified_med)
    
    return verified, discrepancies


def save_verified_data(medicines: list[VerifiedMedicine], filepath: Path) -> None:
    """Save verified medicines to CSV."""
    fieldnames = [
        "brand_name", "generic_name", "strength", "dosage_form",
        "manufacturer", "verified_price", "unit_price", "pack_size",
        "indication", "side_effects", "confidence", "discrepancy_flag"
    ]
    
    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for med in medicines:
            row = {
                "brand_name": med.brand_name,
                "generic_name": med.generic_name,
                "strength": med.strength,
                "dosage_form": med.dosage_form,
                "manufacturer": med.manufacturer,
                "verified_price": med.verified_price,
                "unit_price": med.unit_price,
                "pack_size": med.pack_size,
                "indication": med.indication[:200],  # Truncate for CSV
                "side_effects": med.side_effects[:200],
                "confidence": med.confidence,
                "discrepancy_flag": med.discrepancy_flag,
            }
            writer.writerow(row)
    
    print(f"Saved {len(medicines)} verified medicines to {filepath}")


def save_discrepancies(discrepancies: list[dict], filepath: Path) -> None:
    """Save price discrepancies for review."""
    if not discrepancies:
        print("No discrepancies found!")
        return
    
    fieldnames = list(discrepancies[0].keys())
    
    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(discrepancies)
    
    print(f"Saved {len(discrepancies)} price discrepancies to {filepath}")


def print_summary(verified: list[VerifiedMedicine], discrepancies: list[dict]) -> None:
    """Print verification summary."""
    high_conf = sum(1 for v in verified if v.confidence == CONFIDENCE_HIGH)
    med_conf = sum(1 for v in verified if v.confidence == CONFIDENCE_MEDIUM)
    low_conf = sum(1 for v in verified if v.confidence == CONFIDENCE_LOW)
    
    print("\n" + "=" * 60)
    print("VERIFICATION SUMMARY")
    print("=" * 60)
    print(f"Total medicines verified: {len(verified)}")
    print(f"  - HIGH confidence:   {high_conf}")
    print(f"  - MEDIUM confidence: {med_conf}")
    print(f"  - LOW confidence:    {low_conf}")
    print(f"\nPrice discrepancies:    {len(discrepancies)}")
    print("=" * 60)


def main():
    parser = argparse.ArgumentParser(description="Cross-verify medicine data from multiple sources")
    parser.add_argument(
        "--medex",
        type=Path,
        default=OUTPUT_DIR / "medex_medicines.csv",
        help="Path to Medex data CSV",
    )
    parser.add_argument(
        "--dgda",
        type=Path,
        default=OUTPUT_DIR / "raw_medicines.csv",
        help="Path to DGDA/Kaggle data CSV",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=VERIFIED_OUTPUT,
        help="Output path for verified data",
    )
    args = parser.parse_args()
    
    print("=" * 60)
    print("Medicine Saver BD - Cross-Verification Engine")
    print("=" * 60)
    
    # Load data from sources
    medex_data = load_medex_data(args.medex)
    dgda_data = load_dgda_data(args.dgda)
    
    if not medex_data and not dgda_data:
        print("\nError: No data loaded from any source!")
        print("Please run the scrapers first:")
        print("  python scrape_medex.py --sample")
        print("  python scraper.py --source kaggle")
        return
    
    # Cross-verify and merge
    verified, discrepancies = verify_and_merge(medex_data, dgda_data)
    
    # Save outputs
    save_verified_data(verified, args.output)
    save_discrepancies(discrepancies, DISCREPANCY_REPORT)
    
    # Print summary
    print_summary(verified, discrepancies)
    
    print(f"\nNext step: Run 'python build_db.py' to create SQLite database")


if __name__ == "__main__":
    main()
