"""Test alternatives feature - find all brands with same generic"""
import sqlite3

db_path = 'assets/db/medicines.db'
conn = sqlite3.connect(db_path)
c = conn.cursor()

print("=" * 60)
print("ALTERNATIVES SEARCH TEST")
print("Search for 'Napa' -> Show all Paracetamol brands")
print("=" * 60)

# Step 1: Find the searched brand
c.execute('''
    SELECT b.id, b.name, b.generic_id, g.name as generic
    FROM brands b
    JOIN generics g ON b.generic_id = g.id
    WHERE LOWER(b.name) LIKE '%napa%'
    LIMIT 1
''')
brand = c.fetchone()

if brand:
    brand_id, brand_name, generic_id, generic_name = brand
    print(f"\nFound: {brand_name} (Generic: {generic_name})")
    
    # Step 2: Find all alternatives with same generic
    c.execute('''
        SELECT DISTINCT b.name, m.name, b.strength, b.price, b.verified
        FROM brands b
        LEFT JOIN manufacturers m ON b.manufacturer_id = m.id
        WHERE b.generic_id = ?
        ORDER BY b.price ASC
        LIMIT 15
    ''', [generic_id])
    
    alternatives = c.fetchall()
    print(f"\nAll {generic_name} brands (cheapest first):")
    print("-" * 60)
    
    cheapest = alternatives[0][3] if alternatives else 0
    most_expensive = max(a[3] for a in alternatives) if alternatives else 0
    savings = ((most_expensive - cheapest) / most_expensive * 100) if most_expensive > 0 else 0
    
    for i, (name, mfr, strength, price, verified) in enumerate(alternatives):
        v = "V" if verified else "E"
        is_cheapest = " <- BEST PRICE" if i == 0 else ""
        print(f"  [{v}] {name} ({mfr}) - {strength} - {price:.2f} Tk{is_cheapest}")
    
    print(f"\n💰 Potential savings: {savings:.0f}% (from {cheapest:.2f} to {most_expensive:.2f} Tk)")
else:
    print("No brand found!")

conn.close()
