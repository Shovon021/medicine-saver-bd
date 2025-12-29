# 💊 Medicine Saver BD

> **Save money on medicines.** Find affordable alternatives for branded drugs in Bangladesh.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green)]()
[![License](https://img.shields.io/badge/License-MIT-yellow)]()

---

## 🎯 Features

### Core
- 🔍 **Smart Search** – Fuzzy search with Bangla transliteration support
- 💰 **Savings Calculator** – See how much you can save on alternatives
- 📊 **Price Comparison** – Compare branded vs generic medicine prices

### Advanced
- 🎙️ **Voice Search** – Search medicines using voice commands
- 📷 **Prescription Scanner (OCR)** – Scan prescriptions to find medicines
- ⚠️ **Drug Interaction Checker** – Check for dangerous drug combinations

### User Utility
- 📁 **My Cabinet** – Bookmark frequently used medicines
- ⏰ **Medicine Reminders** – Never miss a dose with notifications
- 🏥 **Pharmacy Locator** – Find nearby pharmacies using GPS

### Extras
- 💡 **Health Tips** – Daily health and medicine safety tips
- 🌙 **Dark Mode** – Automatic dark theme support
- 📴 **Offline-First** – Works without internet using local database

---

## 📱 Screenshots

| Home | Details | Interactions |
|:----:|:-------:|:------------:|
| Search & Quick Actions | Medicine Details | Drug Checker |

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.x
- Python 3.8+ (for data pipeline)

### Installation

```bash
# Clone the repository
git clone https://github.com/Shovon021/medicine-saver-bd.git
cd medicine-saver-bd

# Install Flutter dependencies
flutter pub get

# Generate sample database
cd data_pipeline
pip install -r requirements.txt
python generate_sample.py --count 500
python build_db.py --copy-to-flutter
cd ..

# Run the app
flutter run
```

---

## 🏗️ Architecture

```
medicine/
├── lib/                    # Flutter app code
│   ├── config/            # Theme & config
│   ├── models/            # Data models
│   ├── screens/           # UI screens (7 screens)
│   ├── services/          # Business logic (8 services)
│   └── widgets/           # Reusable components
├── assets/db/             # SQLite database
└── data_pipeline/         # Python scrapers
```

---

## 📊 Data Pipeline

The app uses a multi-source data pipeline for accurate medicine data:

```
Medex.com.bd ──┐
               ├──→ Cross-Verify ──→ SQLite DB
DGDA/Kaggle ───┘
```

| Source | Data Type |
|--------|-----------|
| Medex | Medical info, prices |
| DGDA | Official MRP (Government) |

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.x |
| Database | SQLite (sqflite) |
| Voice | speech_to_text |
| OCR | Google ML Kit |
| Notifications | flutter_local_notifications |
| Location | Geolocator + Google Maps |
| Scraping | Python + BeautifulSoup |

---

## 📄 License

MIT License – See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- Medicine data from [Medex.com.bd](https://medex.com.bd)
- Price verification from [DGDA](https://dgda.gov.bd)
- Icons by [Material Design](https://material.io/icons)

---

<p align="center">Made with ❤️ for Bangladesh</p>
