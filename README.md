# VoiceText Converter

Convert text to speech and save as MP3 file on Android devices.

## Features

- ✅ Enter or paste text
- ✅ Multiple language support (10+ languages)
- ✅ Real-time preview/playback
- ✅ Adjust speed, pitch, and volume
- ✅ Save audio as MP3 file
- ✅ Manage saved files
- ✅ Share files via email, WhatsApp, etc.
- ✅ Delete files

## Installation

### Prerequisites

- Flutter SDK 3.0+
- Android SDK 21+
- Xcode (for iOS)

### Setup

```bash
# Clone repository
git clone https://github.com/httapk84-cell/voice_text_converter.git
cd voice_text_converter

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run
```

## Build APK

```bash
# Build release APK
flutter build apk --release

# Output: build/app/outputs/apk/release/app-release.apk
```

## Build APK with Split by ABI (smaller file size)

```bash
flutter build apk --split-per-abi

# Output in: build/app/outputs/apk/release/
# - app-armeabi-v7a-release.apk
# - app-arm64-v8a-release.apk
# - app-x86-release.apk
```

## Project Structure

```
lib/
├── main.dart                 # Main app entry point
├── models/
│   └── audio_file.dart       # AudioFile model
├── screens/
│   ├── home_screen.dart      # Main conversion screen
│   └── files_screen.dart     # Saved files screen
└── services/
    ├── tts_service.dart      # Text-to-Speech service
    └── file_service.dart     # File management service
```

## Dependencies

- **flutter_tts**: Text-to-speech conversion
- **permission_handler**: Request app permissions
- **path_provider**: Access device directories
- **share_plus**: Share files
- **intl**: Internationalization support

## Usage

1. **Enter Text**: Type or paste text in the text field
2. **Choose Language**: Select desired language from dropdown
3. **Adjust Settings**: Control speed, pitch, and volume
4. **Preview**: Click "Preview" to hear the text
5. **Save**: Click "Save MP3" to create audio file
6. **Manage Files**: View, share, or delete saved files

## License

MIT License

## Author

httapk84-cell
