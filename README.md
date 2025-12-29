# 💊 Medicine Saver BD

> **Save money on medicines.** Find affordable alternatives for branded drugs in Bangladesh.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green)]()
[![License](https://img.shields.io/badge/License-MIT-yellow)]()

---

## 🎯 Features

### Core
- 🔍 **Smart Search** – Fuzzy search by Brand or Generic name with strength filtering
- 💰 **Savings Calculator** – See how much you can save (up to X%) on alternatives
- 📊 **Price Comparison** – Compare branded vs generic medicine prices sorted by cost
- ⭐ **Recent Searches** – Quick access to your last 5 searches

### Advanced
- 🎙️ **Voice Search** – Search medicines using voice commands
- 📷 **Prescription Scanner (OCR)** – Scan prescriptions to find medicines
- ⚠️ **Drug Interaction Checker** – Check for dangerous drug combinations
- ✅ **Trusted Manufacturer Badges** – Verified badges for major BD pharma (Square, Beximco, Renata, etc.)

### User Utility
- 📁 **My Cabinet** – Bookmark frequently used medicines with Add-to-Cabinet button
- ⏰ **Medicine Reminders** – Never miss a dose with notifications
- 🏥 **Pharmacy Locator** – Find nearby pharmacies using GPS
- 💡 **Health Tips** – Daily health and medicine safety tips

### UI/UX Polish
- ✨ **Loading Shimmer** – Premium skeleton loading instead of spinners
- 🎨 **Modern Clinical Theme** – Teal/Navy medical-grade design
- 🌙 **Dark Mode** – Automatic dark theme support
- 📴 **Offline-First** – Works without internet using local SQLite database

---

## 📊 Database Stats

| Metric | Value |
|--------|-------|
| **Total Medicines** | 21,712 |
| **Generic Compounds** | 1,661 |
| **Manufacturers** | 232 |
| **Price Coverage** | 100% |

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

# Run the app
flutter run
```

### Build APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🏗️ Architecture

```
medicine/
├── lib/
│   ├── config/theme.dart       # Modern Clinical theme system
│   ├── models/                 # Brand, Generic, Manufacturer models
│   ├── screens/                # 7 screens (Home, Details, Cabinet, etc.)
│   ├── services/               # 10 services (Database, Voice, OCR, etc.)
│   └── widgets/                # Reusable components (MedicineCard, Shimmer)
├── assets/db/medicines.db      # SQLite database (3.97 MB)
└── data_pipeline/              # Python scrapers & data tools
```

---

## 📊 Data Pipeline

The app uses a multi-source data pipeline for accurate medicine data:

```
Kaggle Dataset ──┐
                 ├──→ Cross-Verify ──→ SQLite DB
Medex/DGDA ──────┘
```

| Script | Purpose |
|--------|---------|
| `load_new_prices.py` | Import external price CSV |
| `normalize_prices.py` | Normalize to realistic BD Taka ranges |
| `cross_verify.py` | Compare sources, assign confidence |
| `build_db.py` | Compile final SQLite database |

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.x |
| **Database** | SQLite (sqflite) |
| **Voice** | speech_to_text |
| **OCR** | Google ML Kit |
| **Notifications** | flutter_local_notifications |
| **Location** | Geolocator + Google Maps |
| **Animations** | flutter_staggered_animations, shimmer |

---

## 📱 Screenshots

| Home | Search Results | Empty State |
|:----:|:--------------:|:-----------:|
| Search & Quick Actions | Alternatives with Savings % | No Results Illustration |

---

## 🔮 Future Roadmap

- [ ] Barcode Scanner for medicine lookup
- [ ] Price Alerts when medicine costs drop
- [ ] User Reviews for pharmacies
- [ ] Cloud sync for user data

---

## 📄 License

MIT License – See [LICENSE](LICENSE) for details.

---

## 👨‍💻 Author

**Sarfaraz Ahamed Shovon**
- GitHub: [@Shovon021](https://github.com/Shovon021)

---

<p align="center">Made with ❤️ for Bangladesh</p>
