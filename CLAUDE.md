# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter-based Sudoku application. The project follows standard Flutter conventions and is configured for multi-platform development (Android, iOS, Web, Windows, Linux, macOS).

## Development Commands

### Core Flutter Commands
- `flutter run` - Run the app on a connected device or emulator
- `flutter run -d chrome` - Run in Chrome browser for web development
- `flutter run --hot-reload` - Enable hot reload for faster development iterations

### Testing
- `flutter test` - Run all unit tests
- `flutter test test/widget_test.dart` - Run a specific test file
- `flutter test --coverage` - Run tests with code coverage

### Code Quality
- `flutter analyze` - Static code analysis (uses flutter_lints rules)
- `flutter analyze --watch` - Continuous analysis during development
- `flutter pub get` - Install/update dependencies

### Build Commands
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter build web` - Build web version
- `flutter clean` - Clean build artifacts

## Project Structure

- `lib/main.dart` - Application entry point with MyApp root widget
- `test/` - Unit and widget tests
- `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/` - Platform-specific code
- `pubspec.yaml` - Project configuration and dependencies

## Architecture Notes

This is currently a basic Flutter app with:
- Material Design theming using ColorScheme.fromSeed
- StatefulWidget pattern for state management (counter example)
- Standard Flutter project structure for multi-platform development

## Testing Strategy

- Uses flutter_test package for widget testing
- Basic smoke test included for counter functionality
- Tests are located in the `test/` directory and mirror the `lib/` structure

## Code Style

- Uses flutter_lints package for code standards
- Analysis options configured in `analysis_options.yaml`
- Follows standard Dart/Flutter conventions