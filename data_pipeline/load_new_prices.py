"""
Load New Price Dataset and Merge with Existing Database

This script:
1. Reads the new medicine_price_dataset.csv
2. Matches medicines by name + company (manufacturer)
3. Updates prices in the SQLite database
4. Reports statistics on matches and updates
"""

import csv
import sqlite3
from pathlib import Path

# Paths
CSV_PATH = Path(__file__).parent / 'input' / 'medicine_price_dataset.csv'
DB_PATH = Path(__file__).parent.parent / 'assets' / 'db' / 'medicines.db'

def normalize(text):
    """Normalize text for matching."""
    if not text:
        return ''
    return text.strip().lower().replace('-', '').replace(' ', '')

def load_new_prices():
    print("=" * 60)
    print("LOADING NEW PRICE DATASET")
    print("=" * 60)
    
    # Read CSV
    with open(CSV_PATH, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        new_data = list(reader)
    
    print(f"📂 Loaded {len(new_data)} records from CSV")
    
    # Connect to database
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    
    # 1. Build Manufacturer Map (Fuzzy Matching)
    mfr_map = {}
    cur.execute('SELECT id, name FROM manufacturers')
    for mfr_id, mfr_name in cur.fetchall():
        simplified = normalize(mfr_name)
        mfr_map[simplified] = mfr_name
        
        # Also map strictly the first word if it's unique enough
        # e.g. "square" -> "Square Pharmaceuticals Ltd."
        first_word = simplified.split('pharm')[0].split('lab')[0].strip()
        if len(first_word) > 3: 
             mfr_map[first_word] = mfr_name

    # 2. Build Existing Brands Map
    cur.execute('''
        SELECT b.id, b.name, m.name as manufacturer, b.price
        FROM brands b
        LEFT JOIN manufacturers m ON b.manufacturer_id = m.id
    ''')
    
    existing = {}
    for row in cur.fetchall():
        brand_id, name, mfr_name, price = row
        # key = (normalized_brand_name, normalized_manufacturer_name)
        key = (normalize(name), normalize(mfr_name))
        existing[key] = {'id': brand_id, 'current_price': price}

    print(f"📊 Database has {len(existing)} brand entries")
    
    # 3. Match and Update
    updated = 0
    matched = 0
    not_found = []
    
    for row in new_data:
        name = row['medicine_name']
        company = row['company'].strip()
        new_price = float(row['price'])
        
        # Resolve company name using map
        safe_company = normalize(company)
        db_mfr_name = None
        
        # Exact match in map
        if safe_company in mfr_map:
             db_mfr_name = mfr_map[safe_company]
        else:
            # Substring match attempt
            for key in mfr_map:
                if safe_company in key or key in safe_company:
                    db_mfr_name = mfr_map[key]
                    break
        
        if not db_mfr_name:
            db_mfr_name = company  # Fallback
            
        # Try matching
        key = (normalize(name), normalize(db_mfr_name))
        
        match = existing.get(key)
        
        if match:
            matched += 1
            brand_id = match['id']
            old_price = match['current_price']
            
            # Update if diff > 0.01 (handling float precision)
            if old_price is None or abs(old_price - new_price) > 0.01:
                cur.execute('UPDATE brands SET price = ? WHERE id = ?', (new_price, brand_id))
                updated += 1
        else:
            not_found.append(f"{name} ({company}) -> Analyzed as: {db_mfr_name}")
    
    conn.commit()
    conn.close()
    
    # Report
    print("\n" + "=" * 60)
    print("RESULTS")
    print("=" * 60)
    print(f"✅ Matched: {matched} / {len(new_data)}")
    print(f"📝 Updated: {updated} prices")
    print(f"❌ Not found: {len(not_found)}")
    
    if not_found:
        print("\nSample unmatched medicines:")
        for item in not_found[:10]:
            print(f"   - {item}")
    
    print("\n✅ Done!")

if __name__ == '__main__':
    load_new_prices()
