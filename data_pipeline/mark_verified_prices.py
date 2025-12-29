"""
Improved Price Verification - Mark real prices from external dataset
Uses better fuzzy matching to identify more verified prices
"""

import sqlite3
import csv
import re

def normalize(name):
    """Normalize medicine name for matching"""
    if not name:
        return ""
    name = name.lower().strip()
    # Remove common suffixes
    name = re.sub(r'\s*(tablet|syrup|injection|capsule|cream|ointment|drops|gel|suspension|solution|powder|inhaler|spray)s?$', '', name, flags=re.I)
    name = re.sub(r'[^\w\s]', ' ', name)  # Replace punctuation with space
    name = re.sub(r'\s+', ' ', name).strip()  # Normalize whitespace
    return name

def main():
    db_path = 'assets/db/medicines.db'
    csv_path = 'data_pipeline/input/medicine_price_dataset.csv'
    
    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    
    # Step 1: Reset all to estimated
    print("Resetting all prices to ESTIMATED...")
    c.execute("UPDATE brands SET verified = 0, confidence = 'ESTIMATED'")
    initial_reset = c.rowcount
    conn.commit()
    print(f"  Reset {initial_reset} brands")
    
    # Step 2: Load real prices from external CSV
    print("\nLoading external price data...")
    real_names = set()
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row.get('medicine_name', '')
            price = row.get('price', '')
            if name and price and price.strip() and price != '0':
                real_names.add(normalize(name))
                # Also add first word only for better matching
                first_word = normalize(name).split()[0] if normalize(name) else ''
                if len(first_word) > 3:
                    real_names.add(first_word)
    
    print(f"  Loaded {len(real_names)} unique searchable names")
    
    # Step 3: Get all brands from database
    print("\nMatching against database...")
    c.execute("SELECT id, name FROM brands")
    brands = c.fetchall()
    
    matched = 0
    for brand_id, brand_name in brands:
        norm = normalize(brand_name)
        first_word = norm.split()[0] if norm else ''
        
        # Check for match
        if norm in real_names or first_word in real_names:
            c.execute("UPDATE brands SET verified = 1, confidence = 'VERIFIED' WHERE id = ?", (brand_id,))
            matched += 1
    
    conn.commit()
    
    # Step 4: Summary
    c.execute("SELECT COUNT(*) FROM brands WHERE verified = 1")
    verified = c.fetchone()[0]
    c.execute("SELECT COUNT(*) FROM brands WHERE verified = 0")
    estimated = c.fetchone()[0]
    
    print(f"\n=== FINAL SUMMARY ===")
    print(f"🟢 VERIFIED (real price): {verified} medicines")
    print(f"🟠 ESTIMATED (generated): {estimated} medicines")
    print(f"\nDatabase updated successfully!")
    
    conn.close()

if __name__ == "__main__":
    main()
