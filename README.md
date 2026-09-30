# DocReader - Flutter Local Document Reader

A clean, minimalist cross-platform mobile application built with Flutter that serves as a local document reader. It provides a fluid, distraction-free reading experience for local files stored on your device.

---

## Features

- **Supported Document Formats**:
  - 📕 **PDF** (`.pdf`)
  - 📘 **Word Documents** (`.docx`, `.doc`)
  - 📗 **Excel Spreadsheets** (`.xlsx`, `.xls`)
  - 📙 **PowerPoint Presentations** (`.pptx`, `.ppt`)
- **Native Viewing Engine**:
  - Leverages **`open_filex`** with native platform intents and file providers.
  - **iOS**: Uses Apple's native **QuickLook** preview system (`UIDocumentInteractionController`), providing pinch-to-zoom, pagination, and file sharing right out of the box without requiring third-party apps.
  - **Android**: Dispatches documents via `FileProvider` and `Intent.ACTION_VIEW` to the user's preferred viewer app (Google Docs/Drive, Microsoft 365, WPS Office, Adobe Acrobat, Samsung Notes).
  - **Actionable Fallback Dialog**: If a device lacks an app for a specific format, the app detects it and presents friendly suggestions for compatible viewers from the store.
- **Clean, Minimalist UI**:
  - **Pick Document Action**: Prominent hero button to open the system file picker with extension filtering.
  - **Format Filtering**: Quick filter chips for *All*, *PDF*, *Word*, *Excel*, and *PowerPoint*.
  - **Instant Search**: Search through recently opened documents in real-time.
  - **Recent Documents & Persistence**: Automatically stores recent documents with file size and timestamp via `shared_preferences`.
  - **Document Metadata Modal**: View file size, modified date, full file path, and format badge.
  - **Native Sharing**: Share documents directly via the system share sheet.
  - **Light & Dark Mode**: Handcrafted Material 3 color schemes with smooth theme toggling.

---

## Project Structure

```
doc_reader/
├── lib/
│   ├── main.dart                          # App entry point & theme state
│   ├── models/
│   │   └── document_item.dart             # Model with types, formatting, icons & colors
│   ├── services/
│   │   ├── document_service.dart          # Picker, native launcher & share service
│   │   └── storage_service.dart           # Persistent recents storage
│   ├── theme/
│   │   └── app_theme.dart                 # Material 3 Light & Dark themes
│   ├── views/
│   │   └── home_screen.dart               # Main UI, recents list & search
│   └── widgets/
│       ├── category_filter_chip.dart      # Filter chips for PDF/Word/Excel/PowerPoint
│       ├── document_card.dart             # Document list item with actions
│       ├── document_details_modal.dart    # Detailed bottom sheet
│       └── empty_state.dart               # Clean minimalist empty state
├── android/
│   ├── app/src/main/AndroidManifest.xml   # Intent queries & permissions for Android 11+
│   ├── app/build.gradle                   # App Gradle configuration
│   ├── build.gradle                       # Root Gradle configuration
│   └── settings.gradle                    # Gradle plugin settings
├── ios/
│   └── Runner/Info.plist                  # Document types & QuickLook configuration
├── test_assets/                           # Generated sample test files
│   ├── Financial_Spreadsheet.xlsx
│   ├── Project_Pitch.pptx
│   ├── Quarterly_Summary.docx
│   └── Sample_Report.pdf
├── create_sample_docs.py                  # Script to generate sample test files
└── pubspec.yaml                           # Flutter dependencies
```

---

## Getting Started

### Prerequisites

Ensure you have the Flutter SDK installed and configured on your system:
```bash
flutter doctor
```

### Install Dependencies

Navigate to the project root directory and fetch the required packages:
```bash
flutter pub get
```

### Run on Connected Device / Simulator

- **Android Device or Emulator**:
  ```bash
  flutter run -d android
  ```

- **iOS Simulator or iPhone**:
  ```bash
  flutter run -d ios
  ```

---

## Testing with Sample Files

The repository includes a set of pre-generated sample documents in `test_assets/`:
1. `Sample_Report.pdf`
2. `Quarterly_Summary.docx`
3. `Financial_Spreadsheet.xlsx`
4. `Project_Pitch.pptx`

You can push these files to your emulator / device storage (e.g. using `adb push test_assets /sdcard/Download/` on Android) and test picking and viewing each document format.
