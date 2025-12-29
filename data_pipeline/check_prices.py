"""Check all data sources for prices"""
import csv

# Check Kaggle medicine.csv
print("=== KAGGLE DATA ===")
with open('data_pipeline/input/kaggle_data/medicine.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    cols = reader.fieldnames
    print(f"Columns: {cols}")
    count = sum(1 for _ in reader)
    print(f"Total rows: {count}")
    has_price = 'price' in [c.lower() for c in cols] if cols else False
    print(f"Has price column: {has_price}")

# Check external price dataset
print("\n=== EXTERNAL PRICE DATASET ===")
with open('data_pipeline/input/medicine_price_dataset.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    cols = reader.fieldnames
    print(f"Columns: {cols}")
    f.seek(0)
    reader = csv.DictReader(f)
    count = 0
    with_price = 0
    for row in reader:
        count += 1
        price = row.get('price', '')
        if price and price.strip() and price != '0':
            with_price += 1
    print(f"Total rows: {count}")
    print(f"Rows with valid price: {with_price}")

# Summary
print("\n=== SUMMARY ===")
print("Kaggle data: Has medicine names, NO prices")
print(f"External data: Has {with_price} medicines with real prices")
