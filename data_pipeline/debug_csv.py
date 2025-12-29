"""Debug CSV reading"""
import csv

csv_path = 'data_pipeline/input/medicine_price_dataset.csv'

# Try reading with different approaches
print("=== RAW FILE READ ===")
with open(csv_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()[:5]
    for i, line in enumerate(lines):
        print(f"Line {i}: {line.strip()[:100]}...")

print("\n=== CSV DICTREADER ===")
with open(csv_path, 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    print(f"Fieldnames: {reader.fieldnames}")
    for i, row in enumerate(reader):
        if i < 3:
            print(f"Row {i}: medicine_name='{row.get('medicine_name')}', price='{row.get('price')}'")
        else:
            break

print("\n=== COUNT ALL ROWS ===")
with open(csv_path, 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    names = []
    for row in reader:
        name = row.get('medicine_name', '')
        if name:
            names.append(name)
    print(f"Total rows with medicine_name: {len(names)}")
    print(f"Sample names: {names[:10]}")
