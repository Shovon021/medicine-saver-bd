"""
Medicine Saver BD - SQLite Database Builder

Builds the medicines.db SQLite database from verified/validated CSV data.
Creates normalized tables for generics, manufacturers, and brands with
medical information.

Usage:
    python build_db.py                              # Use verified_medicines.csv
    python build_db.py --input validated_medicines.csv  # Use specific file
"""

import argparse
import csv
import re
import shutil
import sqlite3
from datetime import datetime
from pathlib import Path

# Paths
OUTPUT_DIR = Path("output")
DEFAULT_INPUT = OUTPUT_DIR / "verified_medicines.csv"
FALLBACK_INPUT = OUTPUT_DIR / "validated_medicines.csv"
OUTPUT_DB = OUTPUT_DIR / "medicines.db"
FLUTTER_ASSETS_DB = Path("../assets/db/medicines.db")


def create_schema(conn: sqlite3.Connection) -> None:
    """Create database schema with enhanced fields."""
    cursor = conn.cursor()

    # Generics table with medical information
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS generics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            indication TEXT,
            dosage_info TEXT,
            side_effects TEXT,
            contraindication TEXT,
            drug_class TEXT
        )
    """)

    # Manufacturers table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS manufacturers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            country TEXT DEFAULT 'Bangladesh'
        )
    """)

    # Brands table with enhanced fields
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS brands (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            generic_id INTEGER NOT NULL,
            manufacturer_id INTEGER,
            strength TEXT,
            dosage_form TEXT,
            price REAL,
            unit_price REAL,
            pack_size TEXT,
            confidence TEXT DEFAULT 'LOW',
            verified BOOLEAN DEFAULT 0,
            last_updated TEXT,
            FOREIGN KEY (generic_id) REFERENCES generics (id),
            FOREIGN KEY (manufacturer_id) REFERENCES manufacturers (id)
        )
    """)

    # Database metadata table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS metadata (
            key TEXT PRIMARY KEY,
            value TEXT
        )
    """)

    # Create indices for fast searching
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_brands_name ON brands(name)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_brands_name_lower ON brands(lower(name))")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_brands_generic ON brands(generic_id)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_brands_price ON brands(price)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_generics_name ON generics(name)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_generics_name_lower ON generics(lower(name))")

    # Full-text search virtual table
    cursor.execute("""
        CREATE VIRTUAL TABLE IF NOT EXISTS brands_fts USING fts5(
            name,
            generic_name,
            manufacturer_name,
            content='brands',
            content_rowid='id'
        )
    """)

    conn.commit()


def get_or_create_generic(
    cursor: sqlite3.Cursor, 
    name: str, 
    indication: str = "",
    side_effects: str = ""
) -> int:
    """Get generic ID, creating if it doesn't exist."""
    cursor.execute("SELECT id FROM generics WHERE name = ?", (name,))
    result = cursor.fetchone()
    if result:
        # Update medical info if provided
        if indication or side_effects:
            cursor.execute(
                "UPDATE generics SET indication = ?, side_effects = ? WHERE id = ?",
                (indication, side_effects, result[0])
            )
        return result[0]

    cursor.execute(
        "INSERT INTO generics (name, indication, side_effects) VALUES (?, ?, ?)", 
        (name, indication, side_effects)
    )
    return cursor.lastrowid


def get_or_create_manufacturer(cursor: sqlite3.Cursor, name: str) -> int:
    """Get manufacturer ID, creating if it doesn't exist."""
    cursor.execute("SELECT id FROM manufacturers WHERE name = ?", (name,))
    result = cursor.fetchone()
    if result:
        return result[0]

    cursor.execute("INSERT INTO manufacturers (name) VALUES (?)", (name,))
    return cursor.lastrowid


def parse_price(price_str) -> float | None:
    """Parse price string or number to float."""
    if price_str is None:
        return None
    if isinstance(price_str, (int, float)):
        return float(price_str) if price_str > 0 else None
    if not price_str:
        return None
    try:
        cleaned = re.sub(r"[^\d.]", "", str(price_str))
        return float(cleaned) if cleaned else None
    except ValueError:
        return None


def populate_fts(cursor: sqlite3.Cursor) -> None:
    """Populate full-text search index."""
    cursor.execute("""
        INSERT INTO brands_fts (rowid, name, generic_name, manufacturer_name)
        SELECT 
            b.id,
            b.name,
            g.name,
            m.name
        FROM brands b
        JOIN generics g ON b.generic_id = g.id
        LEFT JOIN manufacturers m ON b.manufacturer_id = m.id
    """)


def main():
    parser = argparse.ArgumentParser(description="Build SQLite database from medicine data")
    parser.add_argument(
        "--input",
        type=Path,
        default=None,
        help="Input CSV file (default: verified_medicines.csv or validated_medicines.csv)",
    )
    parser.add_argument(
        "--copy-to-flutter",
        action="store_true",
        help="Copy database to Flutter assets folder",
    )
    args = parser.parse_args()

    # Determine input file
    if args.input:
        input_csv = args.input
    elif DEFAULT_INPUT.exists():
        input_csv = DEFAULT_INPUT
    elif FALLBACK_INPUT.exists():
        input_csv = FALLBACK_INPUT
    else:
        print(f"Error: No input file found!")
        print(f"Expected: {DEFAULT_INPUT} or {FALLBACK_INPUT}")
        print("Please run the scrapers and cross_verify.py first.")
        return

    print(f"Using input: {input_csv}")

    # Remove existing database
    OUTPUT_DB.parent.mkdir(parents=True, exist_ok=True)
    if OUTPUT_DB.exists():
        OUTPUT_DB.unlink()

    # Connect and create schema
    conn = sqlite3.connect(OUTPUT_DB)
    create_schema(conn)
    cursor = conn.cursor()

    # Read input data
    with open(input_csv, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        records = list(reader)

    print(f"Building database from {len(records)} records...")

    # Insert records
    inserted = 0
    for record in records:
        # Handle both "generic_name" and "generic" column names
        generic_name = (
            record.get("generic_name", "") or 
            record.get("generic", "")
        ).strip()
        
        manufacturer_name = (
            record.get("manufacturer", "") or 
            record.get("company", "")
        ).strip()
        
        brand_name = record.get("brand_name", "").strip()

        if not generic_name or not brand_name:
            continue

        # Get medical info if available
        indication = record.get("indication", "")
        side_effects = record.get("side_effects", "")

        # Get or create related records
        generic_id = get_or_create_generic(
            cursor, generic_name, indication, side_effects
        )
        manufacturer_id = (
            get_or_create_manufacturer(cursor, manufacturer_name)
            if manufacturer_name
            else None
        )

        # Determine confidence level
        confidence = record.get("confidence", "LOW")
        verified = confidence in ("HIGH", "MEDIUM")

        # Parse prices
        price = parse_price(record.get("verified_price")) or parse_price(record.get("price"))
        unit_price = parse_price(record.get("unit_price")) or price

        # Insert brand
        cursor.execute(
            """
            INSERT INTO brands (
                name, generic_id, manufacturer_id, strength, dosage_form, 
                price, unit_price, pack_size, confidence, verified, last_updated
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                brand_name,
                generic_id,
                manufacturer_id,
                record.get("strength", ""),
                record.get("dosage_form", ""),
                price,
                unit_price,
                record.get("pack_size", ""),
                confidence,
                verified,
                datetime.now().strftime("%Y-%m-%d"),
            ),
        )
        inserted += 1

    # Populate FTS
    print("Building full-text search index...")
    populate_fts(cursor)

    # Add metadata
    cursor.execute(
        "INSERT OR REPLACE INTO metadata (key, value) VALUES (?, ?)",
        ("version", "1.0")
    )
    cursor.execute(
        "INSERT OR REPLACE INTO metadata (key, value) VALUES (?, ?)",
        ("build_date", datetime.now().isoformat())
    )
    cursor.execute(
        "INSERT OR REPLACE INTO metadata (key, value) VALUES (?, ?)",
        ("record_count", str(inserted))
    )

    conn.commit()

    # Print statistics
    cursor.execute("SELECT COUNT(*) FROM generics")
    generic_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM manufacturers")
    manufacturer_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM brands")
    brand_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM brands WHERE verified = 1")
    verified_count = cursor.fetchone()[0]

    conn.close()

    print(f"\n{'=' * 50}")
    print("DATABASE BUILD COMPLETE")
    print(f"{'=' * 50}")
    print(f"  Location:      {OUTPUT_DB}")
    print(f"  Generics:      {generic_count:,}")
    print(f"  Manufacturers: {manufacturer_count:,}")
    print(f"  Brands:        {brand_count:,}")
    print(f"  Verified:      {verified_count:,} ({verified_count/max(brand_count,1)*100:.1f}%)")
    print(f"{'=' * 50}")

    # Copy to Flutter assets
    if args.copy_to_flutter:
        FLUTTER_ASSETS_DB.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy(OUTPUT_DB, FLUTTER_ASSETS_DB)
        print(f"\nCopied to Flutter: {FLUTTER_ASSETS_DB}")
    else:
        print(f"\nTo copy to Flutter:")
        print(f"  cp {OUTPUT_DB} ../assets/db/")


if __name__ == "__main__":
    main()
