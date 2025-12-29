# 💊 Medicine Saver BD

> **Save money on medicines.** Find affordable alternatives for branded drugs in Bangladesh.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-green?logo=android)]()
[![License](https://img.shields.io/badge/License-MIT-yellow)]()
[![APK Size](https://img.shields.io/badge/APK%20Size-52.9MB-orange)]()

---

## 📥 Download APK

**[⬇️ Download Latest APK (v1.0.0)](https://github.com/Shovon021/medicine-saver-bd/releases/latest)**

Or build from source:
```bash
flutter build apk --release
```

---

## 🎯 Features

### ✅ Core (Working)
- 🔍 **Smart Search** – Fuzzy search by Brand or Generic name with strength filtering
- 💰 **Savings Calculator** – See how much you can save on alternatives
- 📊 **Price Comparison** – Compare branded vs generic medicine prices
- ⭐ **Recent Searches** – Quick access to your last 5 searches
- ✅ **Trusted Manufacturer Badges** – Verified badges for major BD pharma

### ✅ User Utility (Working)
- 📁 **My Cabinet** – Bookmark frequently used medicines
- ⏰ **Medicine Reminders** – Never miss a dose with notifications
- ⚠️ **Drug Interaction Checker** – Check for dangerous drug combinations
- 💡 **Health Tips** – Daily health and medicine safety tips

### ✅ UI/UX (Working)
- ✨ **Loading Shimmer** – Premium skeleton loading instead of spinners
- 🎨 **Modern Clinical Theme** – Teal/Navy medical-grade design
- 🌙 **Dark Mode** – Automatic dark theme support
- 📴 **Offline-First** – Works without internet using local SQLite database

### ⚠️ Disabled Features (Coming Soon)
- 🎙️ Voice Search – Temporarily disabled
- 📷 Prescription Scanner (OCR) – Temporarily disabled
- 🔐 Biometric Authentication – Temporarily disabled
- 🏥 Pharmacy Locator (GPS) – Temporarily disabled

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
- Android Studio / VS Code

### Installation

```bash
# Clone the repository
git clone https://github.com/Shovon021/medicine-saver-bd.git
cd medicine-saver-bd

# Install dependencies
flutter pub get

# Run the app
flutter run

# Build release APK
flutter build apk --release
```

**APK Location:** `build/app/outputs/flutter-apk/app-release.apk`

---

## 🏗️ Architecture

```
medicine/
├── lib/
│   ├── config/theme.dart       # Modern Clinical theme system
│   ├── models/                 # Brand, Generic, Manufacturer models
│   ├── screens/                # 7 screens (Home, Details, Cabinet, etc.)
│   ├── services/               # Database, Cabinet, Reminders, etc.
│   └── widgets/                # MedicineCard, Shimmer loading
├── assets/db/medicines.db      # SQLite database (3.97 MB)
└── data_pipeline/              # Python scrapers & data tools
```

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.x |
| **Database** | SQLite (sqflite) |
| **Notifications** | flutter_local_notifications |
| **Animations** | flutter_staggered_animations, shimmer |
| **Storage** | shared_preferences, flutter_secure_storage |

---

## 📱 Screenshots

| Home | Search Results | Medicine Details |
|:----:|:--------------:|:----------------:|
| Search & Quick Actions | Alternatives with Savings % | Full Medicine Info |

---

## 📄 License

MIT License – See [LICENSE](LICENSE) for details.

---

## 👨‍💻 Author

**Sarfaraz Ahamed Shovon**
- GitHub: [@Shovon021](https://github.com/Shovon021)

---

## 🔮 Roadmap

- [ ] Re-enable Voice Search with optimized dependencies
- [ ] Re-enable Prescription Scanner (OCR)
- [ ] Add Barcode Scanner for medicine lookup
- [ ] Price Alerts when medicine costs drop
- [ ] Cloud sync for user data

---

<p align="center">Made with ❤️ for Bangladesh</p>
