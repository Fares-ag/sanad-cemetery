# Sanad Cemetery Application — Report

**Document Date:** March 2026  
**Version:** 1.0.0+1  
**Platform:** Flutter (Android, iOS, Web, Windows, Linux, macOS)

---

## 1. Executive Summary

**Sanad Cemetery** is a Flutter-based mobile and web application for cemetery management. It helps users search for deceased records, navigate to grave locations, manage digital memorials, scan QR codes on headstones, and submit maintenance requests. The app supports English and Arabic (RTL), with a design system built around a maroon accent color and clean white layouts.

---

## 2. Application Overview

### 2.1 Purpose
- **Honor, remember, and find loved ones** — search deceased records by name, dates, or veteran status
- **Navigate to graves** — turn-by-turn navigation on cemetery maps
- **Digital memorials** — profiles with photos, life stories, family links, and tributes
- **QR integration** — scan headstone QR codes to open profiles; display emergency info
- **Maintenance** — report issues (sunken grave, damaged stone, overgrown grass)

### 2.2 Target Users
- Visitors looking for graves
- Families sharing memorial information
- Cemetery staff managing maintenance
- Admins managing cemeteries, sections, and deceased records

---

## 3. Technology Stack

| Category | Technologies |
|----------|--------------|
| **Framework** | Flutter SDK ≥3.2.0 |
| **State Management** | Provider |
| **Routing** | go_router |
| **Search** | fuzzy (fuzzy matching, backend-ready) |
| **Maps & GPS** | flutter_map, latlong2, geolocator, flutter_map_geojson |
| **Compass** | flutter_compass, sensors_plus |
| **QR** | mobile_scanner, qr_flutter, app_links |
| **Media** | cached_network_image, video_player, flutter_html, image_picker |
| **Localization** | flutter_localizations, intl |
| **Persistence** | shared_preferences, path_provider |
| **Utilities** | uuid, intl, http, url_launcher |

---

## 4. Core Features

### 4.1 Search & Discovery
- **Search by name** — fuzzy matching
- **Filters** — birth year range, death year range, veteran only, branch of service
- **Deceased profile** — name, age, death date, years interred, section/plot, bio, photos, video, family links

### 4.2 Navigation
- **Map view** — GeoJSON paths, cemetery layout
- **Turn-by-turn** — compass and GPS
- **Distance** — meters to grave
- **“Arrived”** state

### 4.3 QR Code
- **Scan tombstone** — open profile or link to maintenance report
- **Generate QR** — emergency info (name, contacts, share location) for first responders
- **Alert Police** — call 999 (Qatar)

### 4.4 Maintenance
- **Report issues** — sunken grave, damaged stone, overgrown grass, other
- **Photo required** — camera or gallery
- **GPS tagging** — optional location
- **Linked to grave** — when reported via QR scan
- **Status** — Reported → In Progress → Resolved

### 4.5 Announcements
- **Recent announcements** — funerals, memorial services
- **Add new** — submit name and details
- **Localized dates** — Arabic/English date formatting

### 4.6 Emergency
- **Settings profile** — configure emergency contacts
- **QR card** — encode contacts for quick access
- **Share location** toggle

---

## 5. Localization

- **Languages:** English, Arabic (RTL)
- **Toggle** — in-app language switch
- **Persistent** — locale saved across sessions
- **Date/number formatting** — locale-aware (Arabic numerals, month names)
- **Strings** — 180+ keys in `app_strings.dart`

---

## 6. Design System

| Element | Value |
|---------|-------|
| **Primary color** | Maroon `#8E1737` |
| **Secondary** | Maroon `#A91F42` |
| **Background** | White |
| **Border radius** | 6px, 8px |
| **Spacing** | 4, 8, 12, 16, 24, 32px |
| **Icons** | Material Icons via `AppIcons` |
| **Typography** | Consistent weights and sizes |

---

## 7. Screen Structure

### 7.1 Visitor App
- **Welcome** — onboarding
- **Login** — QID + password (demo)
- **Home** — report hero, metrics, recent reports, announcements preview, QR emergency card
- **Search** — name search, filters
- **Scan** — QR scanner
- **Add New** — add deceased record (form)
- **Maintenance** — report issue
- **Announcements** — list + add
- **Settings** — language, profile, emergency info
- **Deceased Profile** — full memorial
- **Map Navigation** — turn-by-turn to grave

### 7.2 Admin App
- **Dashboard** — overview
- **Deceased List/Edit** — manage records
- **Sections** — cemetery sections
- **Maintenance List/Detail** — tickets
- **Settings** — admin config

---

## 8. Data Models

### Deceased
- `id`, `firstName`, `middleName`, `lastName`, `maidenName`
- `birthDate`, `deathDate`, `birthYear`, `deathYear`
- `isVeteran`, `branchOfService`
- `lat`, `lon`, `sectionId`, `plotNumber`
- `bioHtml`, `imageUrls`, `legacyVideoUrl`
- `familyLinks`, `tributes`, `qrCodeData`

### MaintenanceTicket
- `id`, `category`, `description`, `photoPath`
- `lat`, `lon`, `graveId`
- `status` (reported, inProgress, resolved)
- `createdAt`, `updatedAt`, `reportedByUserId`

### EmergencyInfo
- `userName`, `contacts`, `shareLocation`
- Stored in SharedPreferences

---

## 9. Project Structure

```
lib/
├── admin/           # Admin screens and router
├── l10n/            # app_strings.dart (EN/AR)
├── models/          # Deceased, MaintenanceTicket
├── providers/       # LocaleProvider, EmergencyProvider
├── screens/         # Visitor screens
├── services/        # Search, Navigation, Maintenance, Emergency, QR
├── theme/           # app_theme.dart, AppIcons
├── utils/           # date_format.dart
├── app.dart         # App config, routing, theme
└── main.dart
```

---

## 10. Deployment

- **APK:** `build/app/outputs/flutter-apk/app-release.apk`
- **Platforms:** Android, iOS, Web, Windows, Linux, macOS
- **GitHub:** https://github.com/Fares-ag/sanad-cemetery

---

## 11. Recommendations

1. **Backend integration** — Replace demo in-memory data with REST/GraphQL
2. **Auth** — Add real authentication for login and admin
3. **Notifications** — Use `flutter_local_notifications` for maintenance updates
4. **Analytics** — Track search, navigation, reports
5. **Testing** — Unit and widget tests for critical flows

---

*Report generated for Sanad Cemetery application.*
