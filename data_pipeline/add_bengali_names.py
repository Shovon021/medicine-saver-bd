"""
Bengali Transliteration Script for Medicine Names
Adds Bengali (বাংলা) names to the medicine database for Bangla search support.

Usage:
    python add_bengali_names.py
"""

import sqlite3
from pathlib import Path

# Database paths
DB_PATH = Path("output/medicines.db")
FLUTTER_DB_PATH = Path("../assets/db/medicines.db")

# ============================================================================
# ENGLISH TO BENGALI TRANSLITERATION MAPPINGS
# ============================================================================

# Manual mappings for popular medicine brand names (highest accuracy)
BRAND_NAME_MAPPINGS = {
    # Top searched medicines in Bangladesh
    'napa': 'নাপা',
    'napa extra': 'নাপা এক্সট্রা',
    'ace': 'এস',
    'ace plus': 'এস প্লাস',
    'seclo': 'সেক্লো',
    'maxpro': 'ম্যাক্সপ্রো',
    'sergel': 'সার্জেল',
    'losectil': 'লসেক্টিল',
    'amlodip': 'অ্যামলোডিপ',
    'neotack': 'নিওট্যাক',
    'antacid': 'অ্যান্টাসিড',
    'axodin': 'অ্যাক্সোডিন',
    'azith': 'এজিথ',
    'azithrocin': 'এজিথ্রোসিন',
    'azithromycin': 'এজিথ্রোমাইসিন',
    'atova': 'অ্যাটোভা',
    'amodis': 'অ্যামোডিস',
    'amoxicillin': 'অ্যামোক্সিসিলিন',
    'ciprocin': 'সিপ্রোসিন',
    'ciprofloxacin': 'সিপ্রোফ্লক্সাসিন',
    'cefixime': 'সেফিক্সিম',
    'cef-3': 'সেফ-৩',
    'ceftriaxone': 'সেফট্রায়াক্সোন',
    'domperidone': 'ডমপেরিডন',
    'don-a': 'ডন-এ',
    'eso': 'ইসো',
    'esoral': 'ইসোরাল',
    'esomeprazole': 'ইসোমেপ্রাজল',
    'fexo': 'ফেক্সো',
    'fexofenadine': 'ফেক্সোফেনাডিন',
    'filmet': 'ফিলমেট',
    'fluclox': 'ফ্লুক্লক্স',
    'flucloxacillin': 'ফ্লুক্লক্সাসিলিন',
    'gastoral': 'গ্যাস্টোরাল',
    'histacin': 'হিস্টাসিন',
    'histafree': 'হিস্টাফ্রি',
    'ibuprofen': 'আইবুপ্রোফেন',
    'indever': 'ইন্ডেভার',
    'levofloxacin': 'লেভোফ্লক্সাসিন',
    'losartan': 'লসার্টান',
    'loperin': 'লোপেরিন',
    'loperamide': 'লোপেরামাইড',
    'losium': 'লোসিয়াম',
    'mebex': 'মেবেক্স',
    'mebendazole': 'মেবেন্ডাজল',
    'metacin': 'মেটাসিন',
    'metformin': 'মেটফরমিন',
    'metronidazole': 'মেট্রোনিডাজল',
    'montas': 'মন্টাস',
    'montelukast': 'মন্টেলুকাস্ট',
    'naxen': 'ন্যাক্সেন',
    'naproxen': 'ন্যাপ্রোক্সেন',
    'neuro-b': 'নিউরো-বি',
    'omeprazole': 'ওমেপ্রাজল',
    'omenix': 'ওমেনিক্স',
    'oralex': 'ওরালেক্স',
    'orsalit': 'ওরস্যালিট',
    'pantonix': 'প্যান্টোনিক্স',
    'pantoprazole': 'প্যান্টোপ্রাজল',
    'paracetamol': 'প্যারাসিটামল',
    'pepto': 'পেপ্টো',
    'priton': 'প্রাইটন',
    'ranitidine': 'রেনিটিডিন',
    'renova': 'রেনোভা',
    'savlon': 'স্যাভলন',
    'sinacod': 'সিনাকড',
    'tifen': 'টাইফেন',
    'tycil': 'টাইসিল',
    'tofen': 'টোফেন',
    'tramadol': 'ট্রামাডল',
    'vitamin': 'ভিটামিন',
    'vit-b': 'ভিট-বি',
    'xpa': 'এক্সপিএ',
    'zimax': 'জিম্যাক্স',
    'zithrin': 'জিথ্রিন',
}

# Generic medicine name mappings
GENERIC_NAME_MAPPINGS = {
    'paracetamol': 'প্যারাসিটামল',
    'omeprazole': 'ওমেপ্রাজল',
    'esomeprazole': 'ইসোমেপ্রাজল',
    'pantoprazole': 'প্যান্টোপ্রাজল',
    'ranitidine': 'রেনিটিডিন',
    'famotidine': 'ফ্যামোটিডিন',
    'amoxicillin': 'অ্যামোক্সিসিলিন',
    'azithromycin': 'এজিথ্রোমাইসিন',
    'ciprofloxacin': 'সিপ্রোফ্লক্সাসিন',
    'levofloxacin': 'লেভোফ্লক্সাসিন',
    'cefixime': 'সেফিক্সিম',
    'ceftriaxone': 'সেফট্রায়াক্সোন',
    'metronidazole': 'মেট্রোনিডাজল',
    'flucloxacillin': 'ফ্লুক্লক্সাসিলিন',
    'doxycycline': 'ডক্সিসাইক্লিন',
    'ibuprofen': 'আইবুপ্রোফেন',
    'naproxen': 'ন্যাপ্রোক্সেন',
    'diclofenac': 'ডাইক্লোফেনাক',
    'ketoprofen': 'কিটোপ্রোফেন',
    'indomethacin': 'ইন্ডোমেথাসিন',
    'amlodipine': 'অ্যামলোডিপিন',
    'losartan': 'লসার্টান',
    'atenolol': 'এটেনোলল',
    'metoprolol': 'মেটোপ্রোলল',
    'propranolol': 'প্রোপ্রানোলল',
    'aspirin': 'অ্যাসপিরিন',
    'clopidogrel': 'ক্লোপিডোগ্রেল',
    'atorvastatin': 'অ্যাটরভাস্ট্যাটিন',
    'rosuvastatin': 'রসুভাস্ট্যাটিন',
    'metformin': 'মেটফরমিন',
    'glimepiride': 'গ্লিমেপিরাইড',
    'insulin': 'ইনসুলিন',
    'domperidone': 'ডমপেরিডন',
    'ondansetron': 'অন্ডানসেট্রন',
    'loperamide': 'লোপেরামাইড',
    'fexofenadine': 'ফেক্সোফেনাডিন',
    'cetirizine': 'সেটিরিজিন',
    'loratadine': 'লোরাটাডিন',
    'chlorpheniramine': 'ক্লোরফেনিরামিন',
    'montelukast': 'মন্টেলুকাস্ট',
    'salbutamol': 'সালবিউটামল',
    'theophylline': 'থিওফাইলিন',
    'mebendazole': 'মেবেন্ডাজল',
    'albendazole': 'অ্যালবেন্ডাজল',
    'tramadol': 'ট্রামাডল',
    'gabapentin': 'গ্যাবাপেন্টিন',
    'pregabalin': 'প্রিগাবালিন',
    'sertraline': 'সার্ট্রালিন',
    'fluoxetine': 'ফ্লুওক্সেটিন',
    'clonazepam': 'ক্লোনাজেপাম',
    'diazepam': 'ডায়াজেপাম',
    'alprazolam': 'অ্যালপ্রাজোলাম',
}

# Phonetic transliteration rules (consonants)
CONSONANT_MAP = {
    'b': 'ব', 'c': 'স', 'd': 'ড', 'f': 'ফ', 'g': 'গ', 
    'h': 'হ', 'j': 'জ', 'k': 'ক', 'l': 'ল', 'm': 'ম', 
    'n': 'ন', 'p': 'প', 'q': 'ক', 'r': 'র', 's': 'স', 
    't': 'ট', 'v': 'ভ', 'w': 'ও', 'x': 'ক্স', 'y': 'ই', 'z': 'জ',
    'ch': 'চ', 'sh': 'শ', 'th': 'থ', 'ph': 'ফ', 'gh': 'ঘ',
    'dh': 'ধ', 'bh': 'ভ', 'kh': 'খ', 'ng': 'ং', 'ck': 'ক',
}

# Vowel mappings
VOWEL_MAP = {
    'a': 'া', 'e': 'ে', 'i': 'ি', 'o': 'ো', 'u': 'ু',
    'aa': 'া', 'ee': 'ী', 'oo': 'ু', 'ai': 'াই', 'ou': 'াউ',
    'au': 'ো', 'ei': 'েই', 'oi': 'য়',
}


def transliterate_phonetic(name: str) -> str:
    """
    Convert English text to Bengali using phonetic transliteration.
    This is a fallback for names not in the manual mappings.
    """
    name = name.lower().strip()
    result = []
    i = 0
    
    while i < len(name):
        # Try 2-character combinations first
        if i + 1 < len(name):
            two_char = name[i:i+2]
            if two_char in CONSONANT_MAP:
                result.append(CONSONANT_MAP[two_char])
                i += 2
                continue
            if two_char in VOWEL_MAP:
                result.append(VOWEL_MAP[two_char])
                i += 2
                continue
        
        # Single character
        char = name[i]
        if char in CONSONANT_MAP:
            result.append(CONSONANT_MAP[char])
            # Add inherent 'অ' vowel for consonants (simplified)
        elif char in VOWEL_MAP:
            result.append(VOWEL_MAP[char])
        elif char.isdigit():
            # Bengali numerals
            bengali_digits = '০১২৩৪৫৬৭৮৯'
            result.append(bengali_digits[int(char)])
        elif char in ' -':
            result.append(char)
        else:
            result.append(char)
        
        i += 1
    
    return ''.join(result)


def get_bengali_name(english_name: str, mapping_dict: dict) -> str:
    """
    Get Bengali name from mapping or use phonetic transliteration.
    """
    name_lower = english_name.lower().strip()
    
    # Check exact match in mappings
    if name_lower in mapping_dict:
        return mapping_dict[name_lower]
    
    # Check partial match (for names like "Napa 500mg")
    for key, value in mapping_dict.items():
        if name_lower.startswith(key) or key in name_lower:
            # Replace the matched part with Bengali
            remaining = name_lower.replace(key, '', 1).strip()
            if remaining:
                return f"{value} {remaining}"
            return value
    
    # Fallback to phonetic transliteration
    return transliterate_phonetic(english_name)


def add_bengali_columns(conn: sqlite3.Connection):
    """Add name_bn columns to brands and generics tables if they don't exist."""
    cursor = conn.cursor()
    
    # Check if columns already exist
    cursor.execute("PRAGMA table_info(brands)")
    brand_columns = [col[1] for col in cursor.fetchall()]
    
    cursor.execute("PRAGMA table_info(generics)")
    generic_columns = [col[1] for col in cursor.fetchall()]
    
    # Add columns if missing
    if 'name_bn' not in brand_columns:
        print("Adding name_bn column to brands table...")
        cursor.execute("ALTER TABLE brands ADD COLUMN name_bn TEXT")
    
    if 'name_bn' not in generic_columns:
        print("Adding name_bn column to generics table...")
        cursor.execute("ALTER TABLE generics ADD COLUMN name_bn TEXT")
    
    conn.commit()
    print("Bengali columns ready.")


def populate_bengali_names(conn: sqlite3.Connection):
    """Populate Bengali names for all brands and generics."""
    cursor = conn.cursor()
    
    # Update generics
    print("\nUpdating generic names...")
    cursor.execute("SELECT id, name FROM generics")
    generics = cursor.fetchall()
    
    generic_updated = 0
    for gen_id, name in generics:
        bengali_name = get_bengali_name(name, GENERIC_NAME_MAPPINGS)
        cursor.execute("UPDATE generics SET name_bn = ? WHERE id = ?", (bengali_name, gen_id))
        generic_updated += 1
    
    print(f"  Updated {generic_updated} generics")
    
    # Update brands
    print("\nUpdating brand names...")
    cursor.execute("SELECT id, name FROM brands")
    brands = cursor.fetchall()
    
    brand_updated = 0
    for brand_id, name in brands:
        bengali_name = get_bengali_name(name, BRAND_NAME_MAPPINGS)
        cursor.execute("UPDATE brands SET name_bn = ? WHERE id = ?", (bengali_name, brand_id))
        brand_updated += 1
        
        if brand_updated % 5000 == 0:
            print(f"  Progress: {brand_updated}/{len(brands)}")
    
    print(f"  Updated {brand_updated} brands")
    
    conn.commit()


def update_fts_index(conn: sqlite3.Connection):
    """Update full-text search index to include Bengali names."""
    cursor = conn.cursor()
    
    print("\nUpdating full-text search index...")
    
    # Drop existing FTS table
    cursor.execute("DROP TABLE IF EXISTS brands_fts")
    
    # Create new FTS table with Bengali columns
    cursor.execute("""
        CREATE VIRTUAL TABLE IF NOT EXISTS brands_fts USING fts5(
            name,
            name_bn,
            generic_name,
            generic_name_bn,
            manufacturer_name,
            content='brands',
            content_rowid='id'
        )
    """)
    
    # Populate FTS index
    cursor.execute("""
        INSERT INTO brands_fts (rowid, name, name_bn, generic_name, generic_name_bn, manufacturer_name)
        SELECT 
            b.id,
            b.name,
            b.name_bn,
            g.name,
            g.name_bn,
            m.name
        FROM brands b
        JOIN generics g ON b.generic_id = g.id
        LEFT JOIN manufacturers m ON b.manufacturer_id = m.id
    """)
    
    conn.commit()
    print("FTS index updated with Bengali names.")


def verify_bengali_names(conn: sqlite3.Connection):
    """Print sample Bengali names for verification."""
    cursor = conn.cursor()
    
    print("\n" + "=" * 60)
    print("SAMPLE BENGALI NAMES")
    print("=" * 60)
    
    # Sample brands
    print("\nBrands (English → Bengali):")
    cursor.execute("""
        SELECT name, name_bn FROM brands 
        WHERE name_bn IS NOT NULL 
        ORDER BY RANDOM() LIMIT 10
    """)
    for name, name_bn in cursor.fetchall():
        print(f"  {name:30} → {name_bn}")
    
    # Sample generics
    print("\nGenerics (English → Bengali):")
    cursor.execute("""
        SELECT name, name_bn FROM generics 
        WHERE name_bn IS NOT NULL 
        ORDER BY RANDOM() LIMIT 10
    """)
    for name, name_bn in cursor.fetchall():
        print(f"  {name:30} → {name_bn}")
    
    # Test searches
    print("\nTest Searches:")
    test_queries = ['নাপা', 'প্যারাসিটামল', 'এস', 'সেক্লো', 'ওমেপ্রাজল']
    for query in test_queries:
        cursor.execute("""
            SELECT b.name, b.name_bn, g.name as generic 
            FROM brands b
            JOIN generics g ON b.generic_id = g.id
            WHERE b.name_bn LIKE ? OR g.name_bn LIKE ?
            LIMIT 1
        """, (f'%{query}%', f'%{query}%'))
        result = cursor.fetchone()
        if result:
            print(f"  '{query}' → {result[0]} ({result[2]})")
        else:
            print(f"  '{query}' → No match found")


def main():
    """Main function to add Bengali names to the database."""
    # Check which database to use
    if FLUTTER_DB_PATH.exists():
        db_path = FLUTTER_DB_PATH
        print(f"Using Flutter assets database: {db_path}")
    elif DB_PATH.exists():
        db_path = DB_PATH
        print(f"Using output database: {db_path}")
    else:
        print("Error: No database found!")
        print(f"Expected: {DB_PATH} or {FLUTTER_DB_PATH}")
        return
    
    # Connect to database
    conn = sqlite3.connect(db_path)
    
    try:
        # Step 1: Add Bengali columns
        add_bengali_columns(conn)
        
        # Step 2: Populate Bengali names
        populate_bengali_names(conn)
        
        # Step 3: Update FTS index
        update_fts_index(conn)
        
        # Step 4: Verify
        verify_bengali_names(conn)
        
        print("\n" + "=" * 60)
        print("BENGALI NAMES ADDED SUCCESSFULLY!")
        print("=" * 60)
        print(f"Database: {db_path}")
        print("You can now search in Bengali (বাংলা)")
        
    finally:
        conn.close()


if __name__ == "__main__":
    main()
