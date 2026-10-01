# Time Zone Converter (Flutter / Dart)

Android app to convert and compare times across cities.

## Run on your phone
1. Install Flutter: https://docs.flutter.dev/get-started/install
2. Enable USB debugging on your Android phone and plug it in.
3. In this folder:
   flutter pub get
   flutter devices
   flutter run

## Build an installable APK
   flutter build apk --release
Output: build/app/outputs/flutter-apk/app-release.apk  (copy to phone and install)

## Features
- Pick a source city + date/time, see converted times in many cities
- "Now" button, 12/24-hour toggle
- Add/remove cities, favourites persisted on device
- DST-aware rules for major regions (US, EU, AU, NZ, etc.)
