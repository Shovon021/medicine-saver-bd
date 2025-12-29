# Medicine Saver BD - Data Pipeline

This directory contains Python scripts for acquiring, validating, and building the medicine database for the Medicine Saver BD app.

## Architecture

```
┌─────────────────┐     ┌─────────────────┐
│  Medex.com.bd   │     │   DGDA/Kaggle   │
│  (Rich Source)  │     │ (Golden Source) │
└────────┬────────┘     └────────┬────────┘
         │                       │
         ▼                       ▼
    scrape_medex.py          scraper.py
         │                       │
         └───────────┬───────────┘
                     ▼
              cross_verify.py
              (Data Integrity)
                     │
                     ▼
               build_db.py
                     │
                     ▼
            ┌───────────────┐
            │  medicines.db │
            │   (SQLite)    │
            └───────────────┘
```

## Quick Start

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Run the Pipeline

**Option A: Full Pipeline**
```bash
# Step 1: Scrape from Medex (Rich source - medical info + prices)
python scrape_medex.py --sample  # Test with 10 brands
python scrape_medex.py           # Full scrape (takes hours)

# Step 2: Scrape from DGDA/Kaggle (Golden source - official prices)
python scraper.py --source kaggle --kaggle-file input/kaggle_medicines.csv

# Step 3: Cross-verify prices
python cross_verify.py

# Step 4: Build SQLite database
python build_db.py --copy-to-flutter
```

**Option B: Sample Data (For Testing)**
```bash
# Generate sample database with test data
python generate_sample.py

# Build database
python build_db.py --input output/sample_medicines.csv --copy-to-flutter
```

## Scripts

### `scrape_medex.py`
Scrapes medicine data from [Medex.com.bd](https://medex.com.bd), a comprehensive medicine database for Bangladesh.

**Features scraped:**
- Brand Name, Generic Name, Strength, Dosage Form
- Manufacturer, MRP Price, Pack Size
- Medical Info (Indications, Side Effects, Contraindications)

**Usage:**
```bash
python scrape_medex.py --sample          # Quick 10-brand sample
python scrape_medex.py --letter A        # Brands starting with A
python scrape_medex.py                    # All brands (slow)
```

### `scraper.py`
Scrapes from DGDA website or loads from Kaggle CSV backup.

**Usage:**
```bash
python scraper.py --source dgda           # Scrape from DGDA
python scraper.py --source kaggle         # Load from Kaggle CSV
```

### `cross_verify.py`
Implements the "Data Integrity Engine" that:
1. Matches medicines across sources using normalized keys
2. Compares prices and flags discrepancies > 10%
3. Assigns confidence levels (HIGH/MEDIUM/LOW)
4. Produces verified, authoritative dataset

**Usage:**
```bash
python cross_verify.py
```

### `validate.py`
Validates scraped data and removes duplicates/invalid entries.

**Usage:**
```bash
python validate.py
```

### `build_db.py`
Builds the SQLite database with:
- Normalized tables (generics, manufacturers, brands)
- Full-text search (FTS5) for fast queries
- Indices for price and name lookups
- Database metadata

**Usage:**
```bash
python build_db.py                        # Build from verified data
python build_db.py --copy-to-flutter      # Also copy to Flutter assets
```

## Data Sources

| Source | Type | Data Quality | Updates |
|--------|------|--------------|---------|
| **Medex.com.bd** | Rich | High (medical info) | Weekly |
| **DGDA** | Golden | Official (legal MRP) | Monthly |
| **Kaggle** | Backup | Medium | Archived |

## Confidence Levels

| Level | Criteria | Trust |
|-------|----------|-------|
| **HIGH** | Verified by 2+ sources, <10% price variance | ✅✅✅ |
| **MEDIUM** | Minor discrepancy between sources | ✅✅ |
| **LOW** | Single source or unverified | ✅ |

## Directory Structure

```
data_pipeline/
├── input/               # Raw input files (Kaggle CSV, etc.)
├── output/              # Generated files
│   ├── medex_medicines.csv
│   ├── raw_medicines.csv
│   ├── verified_medicines.csv
│   ├── price_discrepancies.csv
│   └── medicines.db
├── scrape_medex.py      # Medex scraper
├── scraper.py           # DGDA/Kaggle scraper
├── cross_verify.py      # Price verification
├── validate.py          # Data validation
├── build_db.py          # Database builder
├── generate_sample.py   # Sample data generator
├── requirements.txt     # Python dependencies
└── README.md            # This file
```

## Troubleshooting

### "No data loaded"
Make sure you've run the scrapers first:
```bash
python scrape_medex.py --sample
python build_db.py --input output/medex_medicines.csv
```

### Rate Limiting
The scrapers include polite delays (1s between requests). Don't reduce these to avoid getting blocked.

### CORS/Access Issues
Some sources may block scrapers. Try:
- Using a VPN
- Running during off-peak hours
- Using the Kaggle backup instead

## License

MIT License - For educational purposes only.
