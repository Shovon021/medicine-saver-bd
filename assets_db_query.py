import sqlite3

conn = sqlite3.connect('assets/db/medicines.db')
cur = conn.cursor()
cur.execute('''
    SELECT 
        b.name, g.name, m.name, b.strength, b.dosage_form, b.price, b.pack_size
    FROM brands b
    LEFT JOIN generics g ON b.generic_id = g.id
    LEFT JOIN manufacturers m ON b.manufacturer_id = m.id
    ORDER BY b.name
    LIMIT 100
''')

print("=" * 80)
print("FIRST 100 BRANDS FROM DATABASE")
print("=" * 80)

for i, row in enumerate(cur.fetchall(), 1):
    brand, generic, mfr, strength, form, price, pack = row
    print(f"\n{i}. {brand}")
    print(f"   Generic: {generic}")
    print(f"   Manufacturer: {mfr}")
    print(f"   Strength: {strength}")
    print(f"   Form: {form}")
    print(f"   Price: {price} Tk")
    print(f"   Pack: {pack}")

conn.close()
