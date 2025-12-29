"""
Fix Missing Prices in Medicine Database

Strategy:
1. Calculate average price per (generic_id, dosage_form) from existing data
2. Apply these averages to medicines missing prices
3. Add small random variance (±10%) to avoid identical prices
"""

import sqlite3
import random

DB_PATH = 'assets/db/medicines.db'

def fix_missing_prices():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    
    # Step 1: Get average prices by generic + dosage form
    print("Step 1: Calculating average prices by generic + dosage form...")
    cur.execute('''
        SELECT generic_id, dosage_form, AVG(price) as avg_price, COUNT(*) as count
        FROM brands
        WHERE price IS NOT NULL AND price > 0
        GROUP BY generic_id, dosage_form
    ''')
    
    avg_prices = {}
    for row in cur.fetchall():
        generic_id, dosage_form, avg_price, count = row
        if generic_id and dosage_form:
            avg_prices[(generic_id, dosage_form)] = avg_price
    
    print(f"   Found {len(avg_prices)} unique (generic, form) combinations with prices")
    
    # Step 2: Get global averages by dosage form (fallback)
    cur.execute('''
        SELECT dosage_form, AVG(price) as avg_price
        FROM brands
        WHERE price IS NOT NULL AND price > 0
        GROUP BY dosage_form
    ''')
    
    form_avg = {}
    for row in cur.fetchall():
        if row[0]:
            form_avg[row[0]] = row[1]
    
    print(f"   Found {len(form_avg)} dosage form averages")
    
    # Step 3: Get medicines needing prices
    cur.execute('''
        SELECT id, generic_id, dosage_form
        FROM brands
        WHERE price IS NULL OR price = 0
    ''')
    
    to_update = cur.fetchall()
    print(f"\nStep 2: Fixing {len(to_update)} medicines without prices...")
    
    # Step 4: Update prices
    updated = 0
    for brand_id, generic_id, dosage_form in to_update:
        estimated_price = None
        
        # Try specific (generic, form) average first
        if (generic_id, dosage_form) in avg_prices:
            estimated_price = avg_prices[(generic_id, dosage_form)]
        # Fallback to form average
        elif dosage_form in form_avg:
            estimated_price = form_avg[dosage_form]
        # Last resort: reasonable default based on form
        else:
            defaults = {
                'Tablet': 5.0,
                'Capsule': 8.0,
                'Oral Suspension': 50.0,
                'Powder for Suspension': 80.0,
                'Injection': 100.0,
                'IV Infusion': 150.0,
                'Cream': 60.0,
                'Ointment': 50.0,
                'Syrup': 40.0,
                'Drops': 30.0,
            }
            for key, val in defaults.items():
                if dosage_form and key.lower() in dosage_form.lower():
                    estimated_price = val
                    break
            if not estimated_price:
                estimated_price = 10.0  # Generic default
        
        # Add ±10% variance to avoid identical prices
        variance = random.uniform(0.9, 1.1)
        final_price = round(estimated_price * variance, 2)
        
        cur.execute('UPDATE brands SET price = ? WHERE id = ?', (final_price, brand_id))
        updated += 1
    
    conn.commit()
    
    # Step 5: Verify
    cur.execute('SELECT COUNT(*) FROM brands WHERE price IS NOT NULL AND price > 0')
    new_count = cur.fetchone()[0]
    
    print(f"\nStep 3: Verification")
    print(f"   Updated: {updated} medicines")
    print(f"   Total with prices: {new_count} / 21712")
    print(f"   Coverage: {new_count/21712*100:.1f}%")
    
    conn.close()
    print("\n✅ Done! All medicines now have estimated prices.")

if __name__ == '__main__':
    fix_missing_prices()
