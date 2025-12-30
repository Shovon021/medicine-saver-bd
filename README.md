# Medicine Saver BD

> **Save money on medicines.** Find affordable generic alternatives for branded drugs in Bangladesh.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-Ready-3DDC84?style=for-the-badge&logo=android&logoColor=white)]()
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)]()
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)]()

---

## [i] About

**Medicine Saver BD** is a production-ready mobile application designed to help Bangladeshi citizens find affordable medicine alternatives. With rising healthcare costs, this app empowers users to compare branded vs. generic medicine prices and save up to 70% on their prescriptions.

### [!] The Problem We Solve

In Bangladesh, branded medicines often cost **2-5x more** than their generic equivalents, even though they contain the same active ingredients. Most people are unaware of affordable alternatives.

### [*] Our Solution

- Instant price comparisons between branded and generic medicines
- Real-time savings calculations
- Prescription scanning with OCR technology
- Drug interaction safety checks using FDA data
- Cloud sync for your medicine cabinet

---

## [+] Download

### Latest Release

**[Download APK v1.0](https://github.com/Shovon021/medicine-saver-bd/releases/latest)** 

### Build from Source

```bash
git clone https://github.com/Shovon021/medicine-saver-bd.git
cd medicine-saver-bd
flutter pub get
flutter build apk --release
```

**APK Location:** `build/app/outputs/flutter-apk/app-release.apk`

---

## [=] Features

### [1] Smart Medicine Search
| Feature | Status |
|---------|--------|
| Fuzzy Search (typo-tolerant) | [x] |
| Brand + Generic Search | [x] |
| Bengali Language Support | [x] |
| Voice Search (Native Android) | [x] |
| Recent Searches History | [x] |

### [2] Prescription Scanner (OCR)
| Feature | Status |
|---------|--------|
| Camera Capture | [x] |
| Text Recognition (ML Kit) | [x] |
| Auto Medicine Detection | [x] |
| Direct Search Integration | [x] |

### [3] Drug Interaction Checker
| Feature | Status |
|---------|--------|
| OpenFDA API Integration | [x] |
| Real-time FDA Data | [x] |
| Severity Classification | [x] |
| Offline Fallback Database | [x] |

### [4] Crowdsourced Price Reporting
| Feature | Status |
|---------|--------|
| Submit Street Prices | [x] |
| Average Price Calculation | [x] |
| Pharmacy Location Tracking | [x] |
| Community Verification | [x] |

### [5] Personal Medicine Cabinet
| Feature | Status |
|---------|--------|
| Bookmark Medicines | [x] |
| Cloud Sync (Supabase) | [x] |
| Offline Support | [x] |
| Export/Backup (JSON) | [x] |

### [6] Medicine Reminders
| Feature | Status |
|---------|--------|
| Custom Scheduling | [x] |
| Push Notifications | [x] |
| Weekly Repeat | [x] |
| Persistent Storage | [x] |

### [7] Authentication
| Feature | Status |
|---------|--------|
| Google Sign-In (OAuth) | [x] |
| Guest Mode | [x] |
| PIN Protection | [x] |
| Secure Storage | [x] |

### [8] Database Updates
| Feature | Status |
|---------|--------|
| Auto-Check on Startup | [x] |
| Cloud Download (Supabase) | [x] |
| Version Tracking | [x] |
| Silent Update | [x] |

### [9] Pharmacy Locator
| Feature | Status |
|---------|--------|
| Google Maps Integration | [x] |
| Search by City/Area | [x] |
| Popular Pharmacy Chains | [x] |

### [10] UI/UX
| Feature | Status |
|---------|--------|
| Light + Dark Theme | [x] |
| Glassmorphism Design | [x] |
| Shimmer Loading | [x] |
| Staggered Animations | [x] |

---

## [#] Database Statistics

| Metric | Value |
|--------|-------|
| Total Medicines | 21,712+ |
| Generic Compounds | 1,661 |
| Manufacturers | 232 |
| Price Coverage | 100% |
| Database Size | 5.8 MB |

---

## [~] Tech Stack

### Core
| Technology | Purpose |
|------------|---------|
| Flutter 3.x | Cross-platform UI |
| Dart 3.x | Programming language |
| Supabase | Backend (Auth, DB, Storage) |
| SQLite | Offline database |

### APIs
| Service | Purpose |
|---------|---------|
| OpenFDA | Drug interaction data |
| Google ML Kit | OCR text recognition |
| Google Maps | Pharmacy locator |

### Packages
| Package | Purpose |
|---------|---------|
| `supabase_flutter` | Backend integration |
| `google_mlkit_text_recognition` | OCR scanner |
| `dio` | HTTP client |
| `flutter_local_notifications` | Reminders |
| `google_fonts` | Typography |

---

## [>] Project Structure

```
medicine-saver-bd/
|-- lib/
|   |-- config/          # Theme system
|   |-- models/          # Data models (Brand, Generic, PriceReport)
|   |-- screens/         # 14 screens
|   |-- services/        # 15 services
|   |-- widgets/         # Reusable components
|   |-- main.dart
|-- assets/db/           # Pre-populated SQLite (5.8 MB)
|-- data_pipeline/       # Python scraping tools
|-- android/             # Android config
|-- pubspec.yaml
```

---

## [?] Getting Started

### Prerequisites
- Flutter SDK 3.10+
- Dart SDK 3.0+
- Android SDK (API 21+)

### Setup

```bash
# Clone
git clone https://github.com/Shovon021/medicine-saver-bd.git
cd medicine-saver-bd

# Install
flutter pub get

# Run
flutter run

# Build Release
flutter build apk --release
```

---

## [@] Author

**Sarfaraz Ahamed Shovon**

GitHub: [@Shovon021](https://github.com/Shovon021)

---

## [!] Disclaimer

> This app is for **informational purposes only**. Always consult a qualified healthcare professional before switching medications. The developers are not responsible for any health decisions made based on this app.

---

## [^] License

MIT License - See [LICENSE](LICENSE) for details.

---

<p align="center">
  <strong>Made for Bangladesh</strong>
  <br>
  <sub>Helping citizens save money on essential medicines</sub>
</p>
