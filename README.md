# Flutter Todo App — Setup Guide

This package contains the **Dart/Flutter source** (`lib/`) and the **native
Android pieces** (`android_native/`) for the app. I can't run `flutter
create`, `pub get`, or `build_runner` from this sandbox (no access to
pub.dev), so the steps below get you from this package to a running app on
your machine.

## 0. Prerequisites
- Flutter SDK installed (`flutter doctor` should be clean for Android).
- Android Studio / an Android device or emulator.

## 1. Scaffold a fresh Flutter project
```bash
flutter create --org com.example flutter_todo_app
cd flutter_todo_app
```
This generates the full `android/`, `ios/`, gradle files, etc. that are too
large/boilerplate to hand-write here. The package name will be
`com.example.flutter_todo_app`, which matches everything below — if you use
a different `--org`, update the package name in `MainActivity.kt` and the
`MethodChannel` name in `notification_service.dart` to match.

## 2. Copy in the Dart source
Replace the generated `lib/` folder with the one from this package:
```bash
rm -rf lib
cp -r /path/to/this/package/lib .
```

## 3. Add dependencies
Replace the generated `pubspec.yaml` with the one from this package (or
merge the `dependencies`/`dev_dependencies` sections), then:
```bash
flutter pub get
```

## 4. Generate Drift's `database.g.dart`
`lib/data/local/database.dart` declares the schema with
`@DriftDatabase(...)` and `part 'database.g.dart';` — that generated file
doesn't exist yet. Create it with:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## 5. Run it
```bash
flutter run
```
# Flutter-TODO-app
# Flutter-TODO-APP
# TODO-APP
