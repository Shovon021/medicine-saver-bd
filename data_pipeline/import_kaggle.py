"""
Medicine Saver BD - Kaggle Dataset Importer

Imports the "Assorted Medicine Dataset of Bangladesh" from Kaggle.
Merges multiple CSVs (medicine.csv, generic.csv) into our app's format.

Usage:
    1. Download dataset from Kaggle
    2. Extract to data_pipeline/input/kaggle_data/
    3. Run: python import_kaggle.py
"""

import csv
import re
from pathlib import Path

# Paths
INPUT_DIR = Path("input/kaggle_data")
OUTPUT_CSV = Path("output/verified_medicines.csv")

def normalize_text(text):
    if not text: return ""
    return re.sub(r"\s+", " ", str(text).strip())

def parse_price(price_str):
    if not price_str: return 0.0
    try:
        # Remove "Tk", "৳", commas, etc.
        cleaned = re.sub(r"[^\d.]", "", str(price_str))
        return float(cleaned) if cleaned else 0.0
    except ValueError:
        return 0.0

def load_generics():
    """Load generic details (indication, side effects) from generic.csv."""
    generics = {}
    csv_path = INPUT_DIR / "generic.csv"
    
    if not csv_path.exists():
        print(f"Warning: {csv_path} not found. Medical info will be missing.")
        return generics
        
    print(f"Loading generics from {csv_path}...")
    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = normalize_text(row.get("generic_name", "") or row.get("name", ""))
            if name:
                generics[name.lower()] = {
                    "indication": normalize_text(row.get("indication", "")),
                    "description": normalize_text(row.get("indication_description", "")),
                    "side_effects": normalize_text(row.get("side_effects_description", ""))
                }
    return generics

def import_data():
    medicine_path = INPUT_DIR / "medicine.csv"
    if not medicine_path.exists():
        print(f"Error: {medicine_path} not found!")
        print("Please download the dataset and extract to data_pipeline/input/kaggle_data/")
        return

    # Load enriched generic info
    generics_db = load_generics()
    
    medicines = []
    print(f"Importing medicines from {medicine_path}...")
    
    with open(medicine_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            # Map various possible column names
            brand_name = normalize_text(
                row.get("brand name") or row.get("brand_name") or row.get("name")
            )
            generic_name = normalize_text(
                row.get("generic") or row.get("generic name") or row.get("generic_name") or row.get("generic_name")
            )
            manufacturer = normalize_text(row.get("manufacturer") or row.get("manufacturer name"))
            strength = normalize_text(row.get("strength"))
            dosage_form = normalize_text(row.get("dosage form") or row.get("type"))
            
            # Price parsing
            price_str = row.get("package container") or row.get("price")
            unit_price = parse_price(row.get("unit price") or row.get("unit_price"))
            pack_price = parse_price(price_str)
            
            # Pack size
            pack_size = normalize_text(row.get("package size") or row.get("package_size"))

            # Lookup medical info
            med_info = generics_db.get(generic_name.lower(), {})
            indication = med_info.get("indication", "")
            side_effects = med_info.get("side_effects", "")
            
            med = {
                "brand_name": brand_name,
                "generic_name": generic_name,
                "strength": strength,
                "dosage_form": dosage_form,
                "manufacturer": manufacturer,
                "verified_price": pack_price if pack_price > 0 else unit_price,
                "unit_price": unit_price,
                "pack_size": pack_size,
                "indication": indication,
                "side_effects": side_effects,
                "confidence": "HIGH",
                "discrepancy_flag": False
            }
            medicines.append(med)

    # Save to output
    OUTPUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = list(medicines[0].keys())
    
    with open(OUTPUT_CSV, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(medicines)
        
    print(f"Successfully imported {len(medicines)} records to {OUTPUT_CSV}")
    print("Now run: python build_db.py --copy-to-flutter")

if __name__ == "__main__":
    import_data()
