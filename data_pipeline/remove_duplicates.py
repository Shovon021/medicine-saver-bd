"""
Remove duplicate medicine entries from database
- Keeps the entry with lowest price (best deal for users)
- Groups by name + strength + dosage_form to identify true duplicates
"""

import sqlite3

db_path = 'assets/db/medicines.db'
conn = sqlite3.connect(db_path)
c = conn.cursor()

print("=" * 60)
print("REMOVING DUPLICATE MEDICINE ENTRIES")
print("=" * 60)

# Step 1: Count duplicates before
c.execute('''
    SELECT name, strength, dosage_form, COUNT(*) as cnt 
    FROM brands 
    GROUP BY name, strength, dosage_form 
    HAVING cnt > 1
''')
duplicates_before = c.fetchall()
print(f"\nDuplicate groups found: {len(duplicates_before)}")

# Step 2: Get total count before
c.execute("SELECT COUNT(*) FROM brands")
total_before = c.fetchone()[0]
print(f"Total medicines before: {total_before}")

# Step 3: Create temp table with unique entries (keep lowest price)
print("\nRemoving duplicates (keeping lowest price)...")

c.execute('''
    CREATE TABLE IF NOT EXISTS brands_unique AS
    SELECT * FROM brands WHERE id IN (
        SELECT id FROM (
            SELECT id, 
                   ROW_NUMBER() OVER (
                       PARTITION BY name, strength, dosage_form 
                       ORDER BY price ASC, verified DESC
                   ) as rn
            FROM brands
        ) WHERE rn = 1
    )
''')

# Step 4: Replace original table
c.execute("DROP TABLE brands")
c.execute("ALTER TABLE brands_unique RENAME TO brands")
conn.commit()

# Step 5: Count after
c.execute("SELECT COUNT(*) FROM brands")
total_after = c.fetchone()[0]

removed = total_before - total_after

print(f"\n" + "=" * 60)
print("SUMMARY")
print("=" * 60)
print(f"Before: {total_before} medicines")
print(f"After:  {total_after} medicines")
print(f"Removed: {removed} duplicates")
print("=" * 60)

# Verify no more duplicates
c.execute('''
    SELECT name, strength, dosage_form, COUNT(*) as cnt 
    FROM brands 
    GROUP BY name, strength, dosage_form 
    HAVING cnt > 1
''')
remaining_duplicates = c.fetchall()
print(f"\nRemaining duplicate groups: {len(remaining_duplicates)}")

conn.close()
print("\n✅ Database cleaned successfully!")
