"""Extract REAL prices from Kaggle medicine.csv package container field"""
import csv
import re
import sys

# Force UTF-8 output
sys.stdout.reconfigure(encoding='utf-8')

csv_path = 'data_pipeline/input/kaggle_data/medicine.csv'

print("=== EXTRACTING PRICES FROM KAGGLE DATA ===")
print("Price is embedded in 'package container' field after BDT symbol\n")

with_price = 0
total = 0
samples = []

with open(csv_path, 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        total += 1
        pkg = row.get('package container', '')
        
        # Extract price after ৳ symbol (Taka sign)
        match = re.search(r'৳\s*([\d,.]+)', pkg)
        if match:
            with_price += 1
            price = match.group(1).replace(',', '')
            if len(samples) < 10:
                samples.append((row['brand name'], price))

print(f"Total medicines: {total}")
print(f"With extracted price: {with_price}")
print(f"Percentage: {with_price/total*100:.1f}%\n")

print("Sample extractions:")
for name, price in samples:
    print(f"  {name}: {price} Tk")
