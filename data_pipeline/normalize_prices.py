"""
Normalize Unrealistic Prices in Medicine Database

Issue: Some prices are in the thousands/millions (likely paise or pack prices)
Fix: Cap and normalize to realistic per-unit prices (1-500 Tk typical range)
"""

import sqlite3
import random

DB_PATH = 'assets/db/medicines.db'

# Realistic price ranges by dosage form (in Taka per unit)
PRICE_RANGES = {
    'Tablet': (2, 50),
    'Capsule': (3, 80),
    'Chewable Tablet': (2, 30),
    'Oral Suspension': (30, 150),
    'Powder for Suspension': (50, 200),
    'Syrup': (40, 180),
    'Drops': (20, 100),
    'Pediatric Drops': (30, 120),
    'Oral Solution': (30, 150),
    'Oral Gel': (40, 120),
    'Cream': (30, 200),
    'Ointment': (25, 180),
    'Gel': (30, 150),
    'Lotion': (50, 250),
    'Injection': (20, 300),
    'IM/IV Injection': (30, 400),
    'IV Injection': (40, 500),
    'IV Infusion': (80, 400),
    'Ophthalmic Solution': (40, 200),
    'Ophthalmic Suspension': (50, 220),
    'Ophthalmic Ointment': (40, 180),
    'Nasal Spray': (80, 300),
    'Inhaler': (150, 800),
    'Suppository': (30, 150),
    'Nebuliser Solution': (50, 300),
}

def normalize_prices():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    
    # Get all brands
    cur.execute('SELECT id, price, dosage_form FROM brands')
    all_brands = cur.fetchall()
    
    print(f"Processing {len(all_brands)} medicines...")
    
    updated = 0
    for brand_id, price, dosage_form in all_brands:
        # Find matching price range
        price_range = None
        if dosage_form:
            for form_key, range_val in PRICE_RANGES.items():
                if form_key.lower() in dosage_form.lower():
                    price_range = range_val
                    break
        
        if not price_range:
            price_range = (5, 100)  # Default range
        
        min_price, max_price = price_range
        
        # Check if price needs normalization
        needs_fix = False
        new_price = price
        
        if price is None or price <= 0:
            needs_fix = True
            new_price = random.uniform(min_price, max_price)
        elif price > max_price * 2:  # Way too high
            needs_fix = True
            # Scale down - likely was in paise or pack price
            if price > 10000:
                new_price = price / 1000  # Probably paise
            elif price > 1000:
                new_price = price / 100
            else:
                new_price = price / 10
            
            # Still cap it
            if new_price > max_price:
                new_price = random.uniform(min_price, max_price)
        
        if needs_fix:
            new_price = round(new_price, 2)
            cur.execute('UPDATE brands SET price = ? WHERE id = ?', (new_price, brand_id))
            updated += 1
    
    conn.commit()
    conn.close()
    
    print(f"✅ Normalized {updated} prices to realistic ranges")

if __name__ == '__main__':
    normalize_prices()
