"""
Update Database with REAL Kaggle Prices
- Extracts prices from 'package container' field in Kaggle medicine.csv
- Updates database with real prices and marks as VERIFIED
- Any medicine without real price stays ESTIMATED
"""

import csv
import re
import sqlite3
import sys

sys.stdout.reconfigure(encoding='utf-8')

def normalize_name(name):
    """Normalize medicine name for matching"""
    if not name:
        return ""
    return name.lower().strip()

def extract_price(package_container):
    """Extract price from package container field (e.g., '100 ml bottle: ৳ 40.12')"""
    if not package_container:
        return None
    
    # Look for Unit Price first, then any ৳ symbol
    match = re.search(r'Unit Price:\s*৳\s*([\d,.]+)', package_container)
    if not match:
        match = re.search(r'৳\s*([\d,.]+)', package_container)
    
    if match:
        price_str = match.group(1).replace(',', '')
        try:
            return float(price_str)
        except:
            return None
    return None

def main():
    kaggle_path = 'data_pipeline/input/kaggle_data/medicine.csv'
    db_path = 'assets/db/medicines.db'
    
    print("=" * 60)
    print("UPDATING DATABASE WITH REAL KAGGLE PRICES")
    print("=" * 60)
    
    # Step 1: Load Kaggle data with prices
    print("\n[1] Loading Kaggle medicine data...")
    kaggle_prices = {}  # name -> (price, original)
    
    with open(kaggle_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = normalize_name(row.get('brand name', ''))
            pkg = row.get('package container', '')
            price = extract_price(pkg)
            
            if name and price and price > 0:
                # Keep the first (usually correct) price for each medicine
                if name not in kaggle_prices:
                    kaggle_prices[name] = price
    
    print(f"   Loaded {len(kaggle_prices)} unique medicines with prices")
    
    # Step 2: Update database
    print("\n[2] Updating database...")
    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    
    # First, mark all as ESTIMATED
    c.execute("UPDATE brands SET verified = 0, confidence = 'ESTIMATED'")
    conn.commit()
    
    # Get all brands
    c.execute("SELECT id, name, price FROM brands")
    brands = c.fetchall()
    
    updated_count = 0
    verified_count = 0
    
    for brand_id, brand_name, current_price in brands:
        norm_name = normalize_name(brand_name)
        
        if norm_name in kaggle_prices:
            real_price = kaggle_prices[norm_name]
            # Update with real price and mark as VERIFIED
            c.execute("""
                UPDATE brands 
                SET price = ?, verified = 1, confidence = 'VERIFIED'
                WHERE id = ?
            """, (real_price, brand_id))
            updated_count += 1
            verified_count += 1
        else:
            # Keep generated price, mark as ESTIMATED
            pass  # Already marked as ESTIMATED above
    
    conn.commit()
    
    # Step 3: Get final stats
    c.execute("SELECT COUNT(*) FROM brands WHERE verified = 1")
    verified = c.fetchone()[0]
    c.execute("SELECT COUNT(*) FROM brands WHERE verified = 0")
    estimated = c.fetchone()[0]
    c.execute("SELECT COUNT(*) FROM brands")
    total = c.fetchone()[0]
    
    print(f"   Updated {updated_count} medicines with real prices")
    
    print("\n" + "=" * 60)
    print("FINAL SUMMARY")
    print("=" * 60)
    print(f"🟢 VERIFIED (Real Kaggle Price): {verified} ({verified/total*100:.1f}%)")
    print(f"🟠 ESTIMATED (Generated Price):  {estimated} ({estimated/total*100:.1f}%)")
    print(f"📊 Total Medicines:              {total}")
    print("=" * 60)
    
    # Sample verified medicines
    print("\nSample VERIFIED medicines:")
    c.execute("SELECT name, price FROM brands WHERE verified = 1 LIMIT 5")
    for name, price in c.fetchall():
        print(f"  ✓ {name}: {price:.2f} Tk")
    
    # Sample estimated medicines
    print("\nSample ESTIMATED medicines:")
    c.execute("SELECT name, price FROM brands WHERE verified = 0 LIMIT 5")
    for name, price in c.fetchall():
        print(f"  ~ {name}: {price:.2f} Tk (estimated)")
    
    conn.close()
    print("\n✅ Database updated successfully!")

if __name__ == "__main__":
    main()
