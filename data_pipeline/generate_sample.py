"""
Medicine Saver BD - Sample Data Generator

Generates realistic sample medicine data for testing the app.
Expanded to include top-selling brands in Bangladesh.

Usage:
    python generate_sample.py
    python generate_sample.py --count 5000
"""

import argparse
import csv
import random
from pathlib import Path

OUTPUT_DIR = Path("output")
OUTPUT_CSV = OUTPUT_DIR / "sample_medicines.csv"

# Top selling medicines in Bangladesh (Generic + Indication)
GENERICS = [
    ("Paracetamol", "Analgesic & Antipyretic. Fever and pain relief."),
    ("Esomeprazole", "Proton Pump Inhibitor (PPI). Acidity, GERD, Ulcer."),
    ("Omeprazole", "Proton Pump Inhibitor (PPI). Gastric ulcers, Acidity."),
    ("Pantoprazole", "Proton Pump Inhibitor (PPI). Heartburn, Acid reflux."),
    ("Rabeprazole", "Proton Pump Inhibitor (PPI). GERD, Ulcer."),
    ("Dexlansoprazole", "Proton Pump Inhibitor (PPI). Severe acidity."),
    ("Cefixime", "Antibiotic (Cephalosporin). Typhoid, Respiratory infections."),
    ("Cefuroxime", "Antibiotic (Cephalosporin). Bacterial infections."),
    ("Azithromycin", "Antibiotic (Macrolide). Throat infection, Typhoid."),
    ("Ciprofloxacin", "Antibiotic (Fluoroquinolone). UTI, Diarrhea."),
    ("Levofloxacin", "Antibiotic (Fluoroquinolone). Pneumonia, Sinusitis."),
    ("Amoxicillin", "Antibiotic (Penicillin). Dental infection, Ear infection."),
    ("Metronidazole", "Antibiotic/Antiprotozoal. Amoebic dysentery, Diarrhea."),
    ("Fexofenadine", "Antihistamine. Allergic rhinitis, Urticaria."),
    ("Cetirizine", "Antihistamine. Cold, Allergy, Itching."),
    ("Rupatadine", "Antihistamine. Allergic rhinitis."),
    ("Ebastine", "Antihistamine. Allergic conditions."),
    ("Montelukast", "Leukotriene receptor antagonist. Asthma, Allergic rhinitis."),
    ("Doxophylline", "Bronchodilator. Asthma, COPD."),
    ("Salbutamol", "Bronchodilator. Relieves breathing difficulty."),
    ("Losartan Potassium", "Angiotensin receptor blocker. High blood pressure."),
    ("Valsartan", "Angiotensin receptor blocker. Hypertension, Heart failure."),
    ("Amlodipine", "Calcium channel blocker. Hypertension, Angina."),
    ("Bisoprolol", "Beta-blocker. Hypertension, Heart disease."),
    ("Rosuvastatin", "Statin. High cholesterol."),
    ("Atorvastatin", "Statin. Lipid lowering agent."),
    ("Metformin", "Biguanide. Type 2 Diabetes."),
    ("Linagliptin", "DPP-4 inhibitor. Type 2 Diabetes."),
    ("Sitagliptin", "DPP-4 inhibitor. Type 2 Diabetes."),
    ("Gliclazide", "Sulfonylurea. Type 2 Diabetes."),
    ("Naproxen", "NSAID. Pain, Inflammation, Arthritis."),
    ("Diclofenac Sodium", "NSAID. Joint pain, Muscle pain."),
    ("Ketorolac", "NSAID. Moderate to severe pain."),
    ("Tolfenamic Acid", "NSAID. Migraine, Headache."),
    ("Pregabalin", "Anticonvulsant. Neuropathic pain, Anxiety."),
    ("Domperidone", "Antiemetic. Nausea, Vomiting, Indigestion."),
    ("Tiemonium Methylsulphate", "Antispasmodic. Visceral pain."),
    ("Vitamin B Complex", "Supplement. Vitamin deficiency, Weakness."),
    ("Calcium + Vitamin D3", "Supplement. Bone health, Osteoporosis."),
    ("Ferrous Ascorbate", "Iron Supplement. Anemia."),
    ("Zinc Sulfate", "Mineral Supplement. Diarrhea, Zinc deficiency."),
    ("Oral Rehydration Saline", "Electrolyte. Dehydration due to diarrhea."),
]

# Common Brand Names mapping for realism
FAMOUS_BRANDS = {
    "Paracetamol": ["Napa", "Napa Extra", "Ace", "Ace Plus", "Renova", "Fast", "Reset", "Xcel", "Pyralgin"],
    "Esomeprazole": ["Maxpro", "Sergel", "Esooral", "Nexum", "Progut", "Opton", "Esonix", "Emanton"],
    "Omeprazole": ["Seclo", "Losectil", "Ometid", "Proceptin", "Omenix", "Xeldrin"],
    "Pantoprazole": ["Pantonix", "Protocid", "Pantodac", "Trupan", "Pantobex"],
    "Cefixime": ["Cef-3", "Emixef", "Rofecin", "Safix", "Denvar"],
    "Cefuroxime": ["Kilbac", "Cerox-CV", "Furocef", "Sefur", "Benekill"],
    "Azithromycin": ["Zimax", "Azithro", "Tridosil", "Odaz", "Zithrin"],
    "Metronidazole": ["Filmet", "Amodis", "Metro", "Diryl"],
    "Fexofenadine": ["Fexo", "Tofen", "Axodin", "Rifagut", "Dinafex"],
    "Cetirizine": ["Alatrol", "Atrizin", "Cetzin", "Acitrin"],
    "Montelukast": ["Monas", "Monakast", "Montene", "Provair", "Airlukast"],
    "Losartan Potassium": ["Osartil", "Angilock", "Prosan", "Rosatan"],
    "Amlodipine": ["Camlodin", "Amlocard", "Sidipin", "Amocal"],
    "Metformin": ["Comet", "Nobesit", "Daomin", "Infor"],
}

MANUFACTURERS = [
    "Square Pharmaceuticals Ltd.",
    "Beximco Pharmaceuticals Ltd.",
    "Incepta Pharmaceuticals Ltd.",
    "Renata Limited",
    "Healthcare Pharmaceuticals Ltd.",
    "ACI Limited",
    "Eskayef Pharmaceuticals Ltd. (SK+F)",
    "Aristopharma Ltd.",
    "ACME Laboratories Ltd.",
    "Opsonin Pharma Ltd.",
    "Drug International Ltd.",
    "Popylar Pharmaceuticals Ltd.",
    "Ibn Sina Pharmaceutical Ind. Ltd.",
    "General Pharmaceuticals Ltd.",
    "UniMed UniHealth Pharmaceuticals",
    "Orion Pharma Ltd.",
    "Nuvista Pharma",
    "Beacon Pharmaceuticals",
    "Radiant Pharmaceuticals",
    "Ziska Pharmaceuticals",
]

DOSAGE_FORMS = [
    ("Tablet", 0.45),
    ("Capsule", 0.20),
    ("Syrup", 0.10),
    ("Suspension", 0.05),
    ("Injection", 0.05),
    ("Cream", 0.03),
    ("Gel", 0.02),
    ("Ointment", 0.02),
    ("Eye Drops", 0.02),
    ("Suppository", 0.02),
    ("Sachet", 0.02),
    ("Inhaler", 0.02),
]

STRENGTHS = {
    "Tablet": ["500mg", "250mg", "100mg", "50mg", "20mg", "10mg", "5mg", "1000mg"],
    "Capsule": ["20mg", "40mg", "500mg", "250mg", "150mg"],
    "Syrup": ["100ml", "60ml", "200ml"],
    "Suspension": ["60ml", "100ml", "15ml"],
    "Injection": ["1g", "500mg", "250mg", "1ml", "2ml"],
}

def generate_brand_name(generic_name):
    """Pick a famous brand or generate a realistic one."""
    if generic_name in FAMOUS_BRANDS:
        # 60% chance to pick a famous brand, 40% to generate new
        if random.random() < 0.6:
            return random.choice(FAMOUS_BRANDS[generic_name])
    
    # Generate new
    prefixes = ["Neo", "Bex", "Reno", "Ace", "Gyn", "Omu", "Pan", "Tuf", "Mon", "Cef", "Azi", "Met"]
    suffixes = ["til", "pro", "fix", "cal", "min", "cin", "fen", "don", "lox", "met"]
    return f"{random.choice(prefixes)}{random.choice(suffixes)}"

def generate_price(dosage_form, strength):
    """Generate realistic prices."""
    base = 10.0
    if dosage_form == "Tablet": base = 5.0
    elif dosage_form == "Capsule": base = 8.0
    elif dosage_form == "Injection": base = 50.0
    elif dosage_form == "Syrup": base = 35.0
    
    variation = random.uniform(0.5, 3.0)
    return round(base * variation, 2)

def generate_sample_data(count=5000):
    """Generate large sample dataset."""
    medicines = []
    seen = set()
    
    print(f"Generating {count} medicines...")
    
    while len(medicines) < count:
        generic, indication = random.choice(GENERICS)
        manufacturer = random.choice(MANUFACTURERS)
        dosage_form, _ = random.choices(DOSAGE_FORMS, weights=[w for _, w in DOSAGE_FORMS], k=1)[0]
        strength = random.choice(STRENGTHS.get(dosage_form, ["10mg"]))
        
        # Try to make unique brand+strength combination
        base_brand = generate_brand_name(generic)
        
        # Add suffix to make unique if needed (e.g. Napa Extra, Napa Fast)
        if random.random() < 0.2:
            base_brand += f" {random.choice(['Plus', 'Extra', 'XR', 'ER', 'Forte', 'Max'])}"
            
        key = f"{base_brand}_{strength}_{manufacturer}"
        if key in seen:
            continue
        seen.add(key)
        
        unit_price = generate_price(dosage_form, strength)
        pack_size = random.choice(["10's", "20's", "30's", "50's", "100's", "1 strip"])
        
        if dosage_form in ["Syrup", "Suspension", "Cream", "Ointment", "Gel"]:
            pack_size = "1 unit"
            mrp_price = unit_price
        else:
             # Calculate pack price
            pack_qty = 10
            if "20" in pack_size: pack_qty = 20
            elif "30" in pack_size: pack_qty = 30
            mrp_price = unit_price * pack_qty

        # Confidence mostly high for sample data
        confidence = "HIGH" if base_brand in FAMOUS_BRANDS.get(generic, []) else "MEDIUM"
        
        med = {
            "brand_name": base_brand,
            "generic_name": generic,
            "strength": strength,
            "dosage_form": dosage_form,
            "manufacturer": manufacturer,
            "verified_price": round(mrp_price, 2),
            "unit_price": unit_price,
            "pack_size": pack_size,
            "indication": indication,
            "side_effects": "Nausea, Dizziness, Stomach upset (Sample Data)",
            "confidence": confidence,
            "discrepancy_flag": False
        }
        medicines.append(med)
        
    return medicines

def save_to_csv(medicines, filepath):
    filepath.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = list(medicines[0].keys())
    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(medicines)
    print(f"Saved {len(medicines)} records to {filepath}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--count", type=int, default=5000)
    args = parser.parse_args()
    
    data = generate_sample_data(args.count)
    save_to_csv(data, OUTPUT_CSV)
