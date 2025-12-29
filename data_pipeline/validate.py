"""
Medicine Saver BD - Data Validator

Validates the scraped medicine data for completeness and sanity.
Generates a validation report and cleans the data.

Usage:
    python validate.py
"""

import csv
import re
from collections import Counter
from pathlib import Path

# Paths
INPUT_CSV = Path("output/raw_medicines.csv")
VALIDATED_CSV = Path("output/validated_medicines.csv")
REPORT_PATH = Path("output/validation_report.txt")


def validate_price(price_str: str) -> tuple[bool, float | None]:
    """Validate and parse price string."""
    if not price_str:
        return True, None  # Missing price is acceptable

    try:
        # Remove currency symbols and clean
        cleaned = re.sub(r"[^\d.]", "", price_str)
        price = float(cleaned)

        # Sanity checks
        if price < 0:
            return False, None
        if price > 50000:  # Unreasonably high
            return False, None

        return True, price
    except ValueError:
        return False, None


def validate_record(record: dict) -> tuple[bool, list[str]]:
    """Validate a single medicine record."""
    errors = []

    # Required fields
    if not record.get("brand_name"):
        errors.append("Missing brand name")
    if not record.get("generic_name"):
        errors.append("Missing generic name")
    if not record.get("manufacturer"):
        errors.append("Missing manufacturer")

    # Price validation
    if record.get("price"):
        is_valid_price, _ = validate_price(record["price"])
        if not is_valid_price:
            errors.append(f"Invalid price: {record['price']}")

    return len(errors) == 0, errors


def main():
    if not INPUT_CSV.exists():
        print(f"Error: Input file not found at {INPUT_CSV}")
        print("Please run 'python scraper.py' first.")
        return

    # Read input data
    with open(INPUT_CSV, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        records = list(reader)

    print(f"Loaded {len(records)} records")

    # Validation statistics
    stats = {
        "total": len(records),
        "valid": 0,
        "invalid": 0,
        "warnings": 0,
        "missing_price": 0,
    }
    error_counts = Counter()
    valid_records = []

    # Validate each record
    for record in records:
        is_valid, errors = validate_record(record)

        if is_valid:
            stats["valid"] += 1
            valid_records.append(record)
        else:
            stats["invalid"] += 1
            for error in errors:
                error_counts[error] += 1

        if not record.get("price"):
            stats["missing_price"] += 1

    # Check for duplicates
    brand_names = [r["brand_name"] for r in valid_records]
    duplicates = [name for name, count in Counter(brand_names).items() if count > 1]
    stats["duplicates"] = len(duplicates)

    # Generate report
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(REPORT_PATH, "w", encoding="utf-8") as f:
        f.write("=" * 50 + "\n")
        f.write("MEDICINE SAVER BD - VALIDATION REPORT\n")
        f.write("=" * 50 + "\n\n")

        f.write("STATISTICS:\n")
        f.write(f"  Total Records: {stats['total']}\n")
        f.write(f"  Valid Records: {stats['valid']}\n")
        f.write(f"  Invalid Records: {stats['invalid']}\n")
        f.write(f"  Missing Price: {stats['missing_price']}\n")
        f.write(f"  Duplicates: {stats['duplicates']}\n\n")

        if error_counts:
            f.write("ERROR BREAKDOWN:\n")
            for error, count in error_counts.most_common():
                f.write(f"  {error}: {count}\n")
            f.write("\n")

        if duplicates[:10]:
            f.write(f"SAMPLE DUPLICATES (first 10 of {len(duplicates)}):\n")
            for dup in duplicates[:10]:
                f.write(f"  - {dup}\n")

    # Save validated records
    fieldnames = ["brand_name", "generic_name", "strength", "dosage_form",
                  "manufacturer", "price"]

    with open(VALIDATED_CSV, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(valid_records)

    print(f"\nValidation complete!")
    print(f"  Valid: {stats['valid']} / {stats['total']}")
    print(f"  Invalid: {stats['invalid']}")
    print(f"  Report saved to: {REPORT_PATH}")
    print(f"  Clean data saved to: {VALIDATED_CSV}")


if __name__ == "__main__":
    main()
