"""Test search functionality against database - Simple version"""
import sqlite3

db_path = 'assets/db/medicines.db'
conn = sqlite3.connect(db_path)
c = conn.cursor()

def test_search(query):
    search_query = f'%{query.lower()}%'
    c.execute('''
        SELECT b.name, g.name, m.name, b.price, b.verified
        FROM brands b
        LEFT JOIN generics g ON b.generic_id = g.id
        LEFT JOIN manufacturers m ON b.manufacturer_id = m.id
        WHERE LOWER(b.name) LIKE ? OR LOWER(g.name) LIKE ?
        ORDER BY b.price ASC
        LIMIT 5
    ''', [search_query, search_query])
    return c.fetchall()

# Test cases
tests = ['Napa', 'Seclo', 'Paracetamol', 'Ace']

for query in tests:
    print(f"\nSearch: {query}")
    results = test_search(query)
    if results:
        for name, generic, mfr, price, verified in results:
            v = "V" if verified else "E"
            print(f"  [{v}] {name} | {generic} | {price} Tk")
    else:
        print("  No results!")

conn.close()
