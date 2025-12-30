<div align="center">

# Medicine Saver BD

### Save Money on Medicines in Bangladesh

[![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-API_21+-3DDC84?style=flat-square&logo=android&logoColor=white)]()
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=flat-square&logo=supabase&logoColor=white)](https://supabase.com)
[![OpenFDA](https://img.shields.io/badge/OpenFDA-API-0066CC?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0xMiAyQzYuNDggMiAyIDYuNDggMiAxMnM0LjQ4IDEwIDEwIDEwIDEwLTQuNDggMTAtMTBTMTcuNTIgMiAxMiAyem0xIDE1aC0ydi02aDJ2NnptMC04aC0yVjdoMnYyeiIvPjwvc3ZnPg==)]()
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)]()

---

**Find affordable generic alternatives** | **Compare prices instantly** | **Save up to 70%**

[Download APK](https://github.com/Shovon021/medicine-saver-bd/releases/latest) · [Report Bug](https://github.com/Shovon021/medicine-saver-bd/issues) · [Request Feature](https://github.com/Shovon021/medicine-saver-bd/issues)

</div>

---

## ![Info](https://img.shields.io/badge/-About-2196F3?style=flat-square) About

**Medicine Saver BD** is a production-ready Flutter application that helps Bangladeshi citizens find affordable medicine alternatives. In Bangladesh, branded medicines often cost **2-5x more** than their generic equivalents containing the same active ingredients.

This app bridges that knowledge gap with:
- **21,712+ medicines** in an offline-first SQLite database
- **Real-time price comparisons** between branded and generic options
- **AI-powered prescription scanning** using Google ML Kit
- **FDA-verified drug interaction checking** via OpenFDA API
- **Cloud sync** for your personalized medicine cabinet

---

## ![Download](https://img.shields.io/badge/-Download-4CAF50?style=flat-square) Installation

### Direct Download
[![Download APK](https://img.shields.io/badge/Download-APK_v1.0-success?style=for-the-badge&logo=android)](https://github.com/Shovon021/medicine-saver-bd/releases/latest)

### Build from Source
```bash
git clone https://github.com/Shovon021/medicine-saver-bd.git
cd medicine-saver-bd
flutter pub get
flutter build apk --release
```

---

## ![Features](https://img.shields.io/badge/-Features-9C27B0?style=flat-square) Complete Feature List

### ![Search](https://img.shields.io/badge/-Smart_Search-blue?style=flat-square&logo=searchengin) Smart Medicine Search

| Feature | Description | Status |
|---------|-------------|--------|
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Fuzzy Search | Find medicines even with typos or partial names | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Bengali Support | Search in English or বাংলা | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Voice Search | Native Android speech recognition | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Strength Filter | Filter by dosage (mg, ml, etc.) | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Recent Searches | Quick access to last 5 searches | Complete |

---

### ![Scanner](https://img.shields.io/badge/-Prescription_Scanner-orange?style=flat-square&logo=googlelens) OCR Prescription Scanner

| Feature | Description | Status |
|---------|-------------|--------|
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Camera Capture | Point and shoot prescription scanning | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) ML Kit OCR | Google's text recognition engine | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Auto Detection | Automatically identifies medicine names | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Instant Search | Tap scanned names to find alternatives | Complete |

**Technology:** `google_mlkit_text_recognition` + `image_picker`

---

### ![FDA](https://img.shields.io/badge/-Drug_Interactions-red?style=flat-square&logo=redux) FDA Drug Interaction Checker

| Feature | Description | Status |
|---------|-------------|--------|
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) OpenFDA API | Real FDA drug label data | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Live Queries | Fetches latest interaction warnings | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Severity Levels | Mild / Moderate / Severe classification | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Offline Fallback | Local database when offline | Complete |

**API:** `https://api.fda.gov/drug/label.json` (Free, no key required)

---

### ![Price](https://img.shields.io/badge/-Price_Reporting-green?style=flat-square&logo=cashapp) Crowdsourced Price Reporting

| Feature | Description | Status |
|---------|-------------|--------|
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Submit Prices | Report street prices from pharmacies | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Average Calculator | See community average prices | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Location Tracking | Track which pharmacy has best price | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Supabase Backend | Real-time cloud database | Complete |

**Backend:** Supabase PostgreSQL with Row Level Security

---

### ![Cabinet](https://img.shields.io/badge/-Medicine_Cabinet-teal?style=flat-square&logo=dropbox) Personal Medicine Cabinet

| Feature | Description | Status |
|---------|-------------|--------|
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Bookmark Medicines | Save frequently used medicines | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Cloud Sync | Sync across devices via Supabase | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Offline Mode | Works without internet | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) JSON Export | Backup your data locally | Complete |

---

### ![Reminder](https://img.shields.io/badge/-Reminders-purple?style=flat-square&logo=clockify) Medicine Reminders

| Feature | Description | Status |
|---------|-------------|--------|
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Push Notifications | Never miss a dose | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Custom Schedule | Daily, weekly, or custom intervals | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Persistent Storage | Reminders survive app restart | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Timezone Support | Accurate scheduling | Complete |

**Package:** `flutter_local_notifications` + `timezone`

---

### ![Auth](https://img.shields.io/badge/-Authentication-yellow?style=flat-square&logo=google) User Authentication

| Feature | Description | Status |
|---------|-------------|--------|
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Google Sign-In | OAuth via Supabase | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Guest Mode | Use without account | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) PIN Protection | Secure cabinet access | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Secure Storage | Encrypted credentials | Complete |

---

### ![Update](https://img.shields.io/badge/-Auto_Updates-cyan?style=flat-square&logo=icloud) Database Auto-Update

| Feature | Description | Status |
|---------|-------------|--------|
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Startup Check | Checks for updates on launch | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Cloud Download | Downloads from Supabase Storage | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Version Tracking | Only downloads if newer | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) User Prompt | Asks before downloading | Complete |

---

### ![Pharmacy](https://img.shields.io/badge/-Pharmacy_Finder-pink?style=flat-square&logo=googlemaps) Pharmacy Locator

| Feature | Description | Status |
|---------|-------------|--------|
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Google Maps | Opens Maps to find pharmacies | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) City Search | Search by Dhaka, Chittagong, etc. | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Chain Pharmacies | Quick links to Lazz, Drug Int'l, etc. | Complete |

---

### ![Theme](https://img.shields.io/badge/-UI%2FUX-gray?style=flat-square&logo=materialdesign) Modern UI/UX

| Feature | Description | Status |
|---------|-------------|--------|
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Light + Dark Theme | System-aware theming | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Glassmorphism | Modern frosted glass effects | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Shimmer Loading | Premium skeleton animations | Complete |
| ![check](https://img.shields.io/badge/-✓-success?style=flat-square) Staggered Animations | Smooth list transitions | Complete |

---

## ![Database](https://img.shields.io/badge/-Database-brown?style=flat-square&logo=sqlite) Database Statistics

| Metric | Value |
|--------|-------|
| ![pill](https://img.shields.io/badge/Medicines-21,712+-blue?style=flat-square) | Total medicine entries |
| ![dna](https://img.shields.io/badge/Generics-1,661-green?style=flat-square) | Unique generic compounds |
| ![factory](https://img.shields.io/badge/Manufacturers-232-orange?style=flat-square) | Pharmaceutical companies |
| ![check](https://img.shields.io/badge/Prices-100%25-success?style=flat-square) | Price data coverage |
| ![database](https://img.shields.io/badge/Size-5.8_MB-lightgrey?style=flat-square) | Offline database size |

---

## ![Tech](https://img.shields.io/badge/-Tech_Stack-black?style=flat-square&logo=stackshare) Technology Stack

### Core Framework
| Technology | Version | Purpose |
|------------|---------|---------|
| ![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?style=flat-square&logo=flutter&logoColor=white) | 3.24.x | Cross-platform UI |
| ![Dart](https://img.shields.io/badge/Dart-3.5-0175C2?style=flat-square&logo=dart&logoColor=white) | 3.5.x | Programming language |
| ![Material](https://img.shields.io/badge/Material-3-000000?style=flat-square&logo=materialdesign&logoColor=white) | 3 | Design system |

### Backend Services
| Service | Purpose |
|---------|---------|
| ![Supabase](https://img.shields.io/badge/Supabase-Auth_+_DB-3ECF8E?style=flat-square&logo=supabase&logoColor=white) | Authentication, Database, Storage |
| ![OpenFDA](https://img.shields.io/badge/OpenFDA-Drug_Data-0066CC?style=flat-square) | Drug interaction API |
| ![MLKit](https://img.shields.io/badge/ML_Kit-OCR-4285F4?style=flat-square&logo=google&logoColor=white) | Text recognition |

### Key Packages
| Package | Purpose |
|---------|---------|
| `supabase_flutter` | Backend integration |
| `google_mlkit_text_recognition` | OCR scanning |
| `sqflite` | Local SQLite database |
| `dio` | HTTP client |
| `flutter_local_notifications` | Push notifications |
| `google_fonts` | Inter typography |
| `shimmer` | Loading effects |

---

## ![Structure](https://img.shields.io/badge/-Project_Structure-navy?style=flat-square&logo=files) Architecture

```
medicine-saver-bd/
├── lib/
│   ├── config/
│   │   └── theme.dart                # Light + Dark theme system
│   ├── models/
│   │   ├── brand.dart                # Medicine brand model
│   │   ├── generic.dart              # Generic compound model
│   │   ├── price_report.dart         # Crowdsourced price model
│   │   └── models.dart               # Barrel export
│   ├── screens/
│   │   ├── home_screen.dart          # Main search hub
│   │   ├── details_screen.dart       # Medicine details + alternatives
│   │   ├── scanner_screen.dart       # OCR prescription scanner
│   │   ├── cabinet_screen.dart       # Bookmarked medicines
│   │   ├── reminder_screen.dart      # Medicine reminders
│   │   ├── interaction_checker_screen.dart  # FDA drug checker
│   │   ├── welcome_screen.dart       # Auth selection
│   │   └── ... (7 more screens)
│   ├── services/
│   │   ├── database_helper.dart      # SQLite operations
│   │   ├── drug_interaction_service.dart  # OpenFDA API
│   │   ├── prescription_scanner_service.dart  # ML Kit OCR
│   │   ├── price_report_service.dart # Supabase prices
│   │   ├── sync_service.dart         # Cloud cabinet sync
│   │   ├── auth_service.dart         # Google OAuth
│   │   └── ... (9 more services)
│   ├── widgets/
│   │   ├── medicine_card.dart        # Medicine list item
│   │   ├── shimmer_loading.dart      # Skeleton loaders
│   │   └── report_price_sheet.dart   # Price report modal
│   └── main.dart
├── assets/
│   └── db/
│       └── medicines.db              # Pre-populated SQLite (5.8 MB)
├── data_pipeline/                    # Python data tools
│   ├── scrape_medex.py               # Web scraper
│   ├── build_db.py                   # Database builder
│   └── ... (20+ scripts)
└── android/
    └── app/src/main/AndroidManifest.xml  # Permissions
```

---

## ![Setup](https://img.shields.io/badge/-Getting_Started-darkgreen?style=flat-square&logo=rocket) Developer Setup

### Prerequisites
- ![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=flat-square) Flutter SDK 3.10+
- ![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat-square) Dart SDK 3.0+
- ![Android](https://img.shields.io/badge/Android_SDK-API_21+-3DDC84?style=flat-square) Android SDK (API 21+)

### Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/Shovon021/medicine-saver-bd.git
cd medicine-saver-bd

# 2. Install dependencies
flutter pub get

# 3. Run in debug mode
flutter run

# 4. Build release APK
flutter build apk --release
```

### Supabase Setup (Optional - for cloud features)
1. Create a project at [supabase.com](https://supabase.com)
2. Run the SQL scripts from `data_pipeline/` to create tables
3. Update `lib/main.dart` with your Supabase URL and anon key

---

## ![Author](https://img.shields.io/badge/-Author-darkblue?style=flat-square&logo=github) Developer

<div align="center">

**Sarfaraz Ahamed Shovon**

[![GitHub](https://img.shields.io/badge/GitHub-@Shovon021-181717?style=for-the-badge&logo=github)](https://github.com/Shovon021)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/shovon021)

</div>

---

## ![Warning](https://img.shields.io/badge/-Disclaimer-red?style=flat-square&logo=warning) Medical Disclaimer

> **⚠️ Important:** This app is for **informational purposes only**. Always consult a qualified healthcare professional or pharmacist before switching medications. The developers are not responsible for any health decisions made based on this app's information.

---

## ![License](https://img.shields.io/badge/-License-lightgrey?style=flat-square&logo=opensourceinitiative) License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

### Made for Bangladesh

*Helping citizens save money on essential medicines*

[![Stars](https://img.shields.io/github/stars/Shovon021/medicine-saver-bd?style=social)](https://github.com/Shovon021/medicine-saver-bd)
[![Forks](https://img.shields.io/github/forks/Shovon021/medicine-saver-bd?style=social)](https://github.com/Shovon021/medicine-saver-bd)

</div>
