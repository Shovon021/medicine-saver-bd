# 💊 Medicine Saver BD

> **Save money on medicines.** Find affordable generic alternatives for branded drugs in Bangladesh.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-Ready-3DDC84?style=for-the-badge&logo=android&logoColor=white)]()
[![SQLite](https://img.shields.io/badge/SQLite-Offline--First-003B57?style=for-the-badge&logo=sqlite&logoColor=white)]()
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)]()

---

## 📖 About

**Medicine Saver BD** is a comprehensive mobile application designed to help Bangladeshi citizens find affordable medicine alternatives. With rising healthcare costs, this app empowers users to compare branded vs. generic medicine prices and potentially save significant amounts on their prescriptions.

### 💡 The Problem We Solve

In Bangladesh, branded medicines often cost **2-5x more** than their generic equivalents, even though they contain the same active ingredients. Most people are unaware of affordable alternatives, leading to unnecessary healthcare expenses.

### ✨ Our Solution

Medicine Saver BD provides:
- **Instant price comparisons** between branded and generic medicines
- **Savings calculations** showing exactly how much you can save
- **Trusted manufacturer verification** for popular pharmaceutical companies
- **Offline functionality** – works without internet connection

---

## 📥 Download

### 🔗 Latest Release

**[⬇️ Download APK (v1.0.0)](https://github.com/Shovon021/medicine-saver-bd/releases/latest)** – 53.3 MB

### 🛠️ Build from Source

```bash
# Clone the repository
git clone https://github.com/Shovon021/medicine-saver-bd.git
cd medicine-saver-bd

# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```

**APK Location:** `build/app/outputs/flutter-apk/app-release.apk`

---

## 🎯 Features

### 🔍 Smart Medicine Search
| Feature | Description |
|---------|-------------|
| **Fuzzy Search** | Find medicines even with typos or partial names |
| **Brand + Generic Search** | Search by brand name OR generic compound |
| **Strength Filtering** | Filter results by dosage strength (mg, ml, etc.) |
| **Recent Searches** | Quick access to your last 5 searches |

### 💰 Savings & Price Comparison
| Feature | Description |
|---------|-------------|
| **Savings Calculator** | See exact savings percentage vs. branded medicines |
| **Price per Unit** | Compare unit prices across alternatives |
| **Cheapest Alternative** | Instantly find the most affordable option |
| **Price Difference Display** | Visual savings indicators on each medicine |

### 📦 Personal Medicine Cabinet
| Feature | Description |
|---------|-------------|
| **Bookmark Medicines** | Save frequently used medicines for quick access |
| **Cabinet Organization** | Access all bookmarked medicines in one place |
| **Quick Actions** | One-tap access to medicine details |

### ⏰ Medicine Reminders
| Feature | Description |
|---------|-------------|
| **Custom Reminders** | Set reminders for any medicine |
| **Flexible Scheduling** | Daily, weekly, or custom intervals |
| **Push Notifications** | Never miss a dose with local notifications |
| **Reminder Management** | Edit, delete, and manage all reminders |

### ⚠️ Drug Interaction Checker
| Feature | Description |
|---------|-------------|
| **Interaction Database** | Check for dangerous drug combinations |
| **Severity Levels** | Critical, Major, and Minor interaction warnings |
| **Safety Alerts** | Prominent warnings for potentially harmful combinations |

### 💡 Health Tips
| Feature | Description |
|---------|-------------|
| **Daily Health Tips** | Curated health and medicine safety tips |
| **Categories** | General health, medicine storage, dosage guidance |
| **Actionable Advice** | Practical tips for everyday wellness |

### 🎨 Modern UI/UX
| Feature | Description |
|---------|-------------|
| **Modern Clinical Theme** | Professional Teal/Navy medical-grade design |
| **Dark Mode** | Full dark theme support with enhanced contrast |
| **Shimmer Loading** | Premium skeleton loading animations |
| **Smooth Animations** | Staggered list animations and micro-interactions |
| **Trusted Badges** | Verified badges for major BD pharmaceutical companies |

### 📴 Offline-First Architecture
| Feature | Description |
|---------|-------------|
| **Local SQLite Database** | Complete medicine database stored locally |
| **No Internet Required** | All core features work without connectivity |
| **Fast Performance** | Instant search results from local data |

---

## 📊 Database Statistics

| Metric | Value |
|--------|-------|
| 💊 **Total Medicines** | 21,712+ |
| 🧬 **Generic Compounds** | 1,661 |
| 🏭 **Manufacturers** | 232 |
| 💵 **Price Coverage** | 100% |
| 📦 **Database Size** | 5.8 MB |

---

## 🖼️ Screenshots

| Home Screen | Search Results | Medicine Details |
|:-----------:|:--------------:|:----------------:|
| Smart search with quick actions | Alternatives with savings % | Complete medicine information |

| My Cabinet | Reminders | Drug Interactions |
|:----------:|:---------:|:-----------------:|
| Bookmarked medicines | Never miss a dose | Safety warnings |

---

## 🏗️ Project Architecture

```
medicine-saver-bd/
├── 📁 lib/
│   ├── 📁 config/
│   │   └── theme.dart              # Modern Clinical theme system (Light + Dark)
│   ├── 📁 models/
│   │   ├── brand.dart              # Brand medicine model
│   │   ├── generic.dart            # Generic compound model
│   │   ├── manufacturer.dart       # Manufacturer model
│   │   └── models.dart             # Barrel export
│   ├── 📁 screens/
│   │   ├── home_screen.dart        # Main search & navigation hub
│   │   ├── details_screen.dart     # Medicine details & alternatives
│   │   ├── cabinet_screen.dart     # Bookmarked medicines
│   │   ├── reminder_screen.dart    # Medicine reminders management
│   │   ├── interaction_checker_screen.dart  # Drug interaction checker
│   │   ├── health_tips_screen.dart # Daily health tips
│   │   ├── splash_screen.dart      # App launch screen
│   │   ├── login_screen.dart       # PIN-based login
│   │   ├── about_screen.dart       # App information
│   │   ├── developer_screen.dart   # Developer credits
│   │   ├── theme_settings_screen.dart  # Theme preferences
│   │   └── pharmacy_locator_screen.dart # Nearby pharmacies (Coming Soon)
│   ├── 📁 services/
│   │   ├── database_helper.dart    # SQLite operations
│   │   ├── fuzzy_search.dart       # Fuzzy string matching algorithm
│   │   ├── cabinet_service.dart    # Bookmark management
│   │   ├── reminder_service.dart   # Notification scheduling
│   │   ├── drug_interaction_service.dart  # Interaction checking
│   │   ├── health_tips_service.dart # Health tips content
│   │   ├── theme_service.dart      # Theme persistence
│   │   ├── auth_service.dart       # PIN authentication
│   │   ├── security_service.dart   # Secure storage
│   │   ├── backup_service.dart     # Data export/import
│   │   ├── voice_search_service.dart   # Voice input (Coming Soon)
│   │   └── prescription_scanner_service.dart  # OCR scanning (Coming Soon)
│   ├── 📁 widgets/
│   │   ├── medicine_card.dart      # Medicine list item widget
│   │   ├── shimmer_loading.dart    # Loading skeleton animations
│   │   └── animated_widgets.dart   # Reusable animation components
│   └── main.dart                   # App entry point
├── 📁 assets/
│   ├── 📁 db/
│   │   └── medicines.db            # Pre-populated SQLite database (5.8 MB)
│   ├── icon.jpg                    # App launcher icon
│   └── logo.jpg                    # App logo
├── 📁 data_pipeline/               # Python data processing tools
│   ├── scrape_medex.py             # Web scraper for Medex.com.bd
│   ├── build_db.py                 # SQLite database builder
│   ├── cross_verify.py             # Price verification tool
│   ├── validate.py                 # Data validation scripts
│   └── ...                         # Additional data tools
├── 📁 android/                     # Android platform configuration
├── pubspec.yaml                    # Flutter dependencies
└── README.md                       # This file
```

---

## 🛠️ Tech Stack

### Core Framework
| Technology | Purpose |
|------------|---------|
| **Flutter 3.x** | Cross-platform UI framework |
| **Dart 3.x** | Programming language |
| **Material Design 3** | UI component library |

### Database & Storage
| Package | Purpose |
|---------|---------|
| `sqflite` | Local SQLite database |
| `shared_preferences` | Key-value storage for settings |
| `flutter_secure_storage` | Encrypted storage for sensitive data |
| `path_provider` | File system access |

### UI & Animations
| Package | Purpose |
|---------|---------|
| `google_fonts` | Inter font family |
| `shimmer` | Loading skeleton effects |
| `flutter_staggered_animations` | List item animations |
| `font_awesome_flutter` | Medical icons |

### Features
| Package | Purpose |
|---------|---------|
| `flutter_local_notifications` | Push notifications for reminders |
| `share_plus` | Share/export functionality |
| `file_picker` | Import/export files |
| `url_launcher` | Open external links |
| `permission_handler` | Runtime permissions |
| `connectivity_plus` | Network status checking |
| `dio` | HTTP client for future sync features |

---

## 🎨 Design System

### Light Theme
| Element | Color | Hex |
|---------|-------|-----|
| Background | Warm White | `#FAFAF9` |
| Surface | Soft Cream | `#FDFBF7` |
| Primary | Teal Blue | `#0D9488` |
| Secondary | Warm Gold | `#F59E0B` |
| Text Heading | Deep Navy | `#1E3A5F` |
| Text Body | Slate Grey | `#4B5563` |

### Dark Theme
| Element | Color | Hex |
|---------|-------|-----|
| Background | Rich Navy | `#0F172A` |
| Surface | Slate | `#1E293B` |
| Primary | Bright Teal | `#2DD4BF` |
| Secondary | Bright Gold | `#FBBF24` |
| Text Heading | Almost White | `#F8FAFC` |
| Text Body | Light Slate | `#CBD5E1` |

### Typography
- **Font Family:** Inter (Google Fonts)
- **Heading:** 28px Bold
- **Title:** 20px Semi-Bold
- **Body:** 14-16px Regular
- **Labels:** 14px Medium

---

## 🔮 Roadmap

### Coming Soon
- [ ] 🎙️ **Voice Search** – Search medicines using voice input
- [ ] 📷 **Prescription Scanner (OCR)** – Scan prescriptions to find alternatives
- [ ] 🔐 **Biometric Authentication** – Fingerprint/Face unlock
- [ ] 🏥 **Pharmacy Locator** – Find nearby pharmacies with GPS
- [ ] 📊 **Barcode Scanner** – Scan medicine barcodes for instant lookup

### Future Plans
- [ ] ☁️ **Cloud Sync** – Sync cabinet and reminders across devices
- [ ] 💰 **Price Alerts** – Get notified when medicine prices drop
- [ ] 📈 **Price History** – Track medicine price trends over time
- [ ] 🏥 **Doctor Recommendations** – Suggested alternatives by specialists
- [ ] 🌐 **Multi-language Support** – Bengali language option

---

## 🚀 Getting Started for Developers

### Prerequisites
- Flutter SDK 3.10.4 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Android SDK (API 21+)

### Environment Setup

```bash
# Verify Flutter installation
flutter doctor

# Clone and setup
git clone https://github.com/Shovon021/medicine-saver-bd.git
cd medicine-saver-bd

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Data Pipeline (Python)

The `data_pipeline/` directory contains Python scripts for:
- Scraping medicine data from Medex.com.bd
- Building and populating the SQLite database
- Validating and verifying price data

```bash
cd data_pipeline

# Create virtual environment
python -m venv .venv
.venv\Scripts\activate  # Windows
source .venv/bin/activate  # macOS/Linux

# Install dependencies
pip install -r requirements.txt

# Run scraper
python scrape_medex.py

# Build database
python build_db.py
```

---

## 📄 License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

<div align="center">

**Sarfaraz Ahamed Shovon**

[![GitHub](https://img.shields.io/badge/GitHub-@Shovon021-181717?style=for-the-badge&logo=github)](https://github.com/Shovon021)

</div>

---

## 🙏 Acknowledgments

- Medicine data sourced from [Medex.com.bd](https://medex.com.bd)
- Drug interaction data for safety features
- Flutter team for the amazing framework
- All Bangladeshi pharmaceutical companies included in the database

---

## ⚠️ Disclaimer

> This app is for **informational purposes only**. Always consult a qualified healthcare professional or pharmacist before switching medications. The developers are not responsible for any health decisions made based on this app's information.

---

<p align="center">
  <strong>Made with ❤️ for Bangladesh</strong>
  <br>
  <sub>Helping citizens save money on essential medicines</sub>
</p>
