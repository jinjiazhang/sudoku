# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a complete Flutter Sudoku application with multi-difficulty support. The app features a comprehensive 9-level difficulty system supporting 4x4, 6x6, and 9x9 Sudoku variants with adaptive UI and intelligent game state management.

## Development Commands

### Core Flutter Commands
- `flutter run` - Run the app on a connected device or emulator
- `flutter run -d chrome` - Run in Chrome browser for web development
- `flutter run --hot-reload` - Enable hot reload for faster development iterations

### Code Quality
- `flutter analyze` - Static code analysis (MUST run before committing any changes)
- `flutter pub get` - Install/update dependencies
- `flutter clean` - Clean build artifacts when needed

### Testing
- `flutter test` - Run all unit tests
- `flutter test --coverage` - Run tests with code coverage

### Build Commands
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter build web` - Build web version

## Project Architecture

The app follows **Clean Architecture** with strict separation of concerns:

```
lib/
├── main.dart                    # App entry point with bottom navigation
├── models/                      # Data Layer
│   └── sudoku_game.dart         # Game state model & difficulty definitions
├── services/                    # Business Logic Layer  
│   └── sudoku_service.dart      # Game logic, validation & state management
└── screens/                     # Presentation Layer
    ├── home_screen.dart         # Home page with smart state management
    ├── profile_screen.dart      # Profile page (simplified)
    └── sudoku_screen.dart       # Adaptive game interface
```

## Key Features & Implementation

### 1. Multi-Difficulty System
- **Level 1**: 4x4 grid (1-4 numbers, 2x2 sub-regions)
- **Level 2**: 6x6 grid (1-6 numbers, 2x3 sub-regions in 3×2 layout)
- **Level 3-9**: 9x9 grid (1-9 numbers, 3x3 sub-regions, decreasing hints)

### 2. Adaptive UI Components
- Dynamic grid layout based on difficulty
- Smart number keyboard (shows only valid range)
- Professional border styling (thick/thin lines)
- Responsive design with AspectRatio

### 3. Game State Management
- Static methods in SudokuService for persistence
- Auto-save every second during gameplay
- Continue game functionality
- Smart home screen state switching

### 4. Random Generation Algorithm
- Template-based generation with random transformations
- Row/column swapping within sub-regions
- Number remapping for variation
- Proper clue removal maintaining solvability

## Development Guidelines

### Code Quality Standards
- ALWAYS run `flutter analyze` before committing - zero warnings policy
- Follow established patterns for new features
- Maintain clean architecture separation
- Use proper error handling and validation

### State Management Pattern
```dart
// Static methods for game state persistence
static void saveGame(SudokuGame game) { _savedGame = game; }
static SudokuGame? getSavedGame() { return _savedGame; }
static bool hasSavedGame() { return _savedGame != null; }
```

### UI Development Guidelines
- Use AspectRatio for grid layouts to ensure proper scaling
- Follow existing color scheme and styling patterns
- Implement proper SafeArea and responsive design
- Test on different screen sizes

## File-Specific Notes

### sudoku_service.dart
- Contains all business logic and validation
- Handles different sub-region types (2x2, 2x3, 3x3)
- Implements random generation for all difficulty levels
- Manages game state persistence

### sudoku_screen.dart
- Adaptive UI that works with all grid sizes
- Complex border styling with specialized methods
- Real-time game state saving
- Dynamic keyboard and highlighting

### home_screen.dart
- Smart state management with conditional UI
- Integrated difficulty slider
- Continue/restart game logic
- Navigation result handling

## Testing Strategy

- Widget tests for UI components
- Unit tests for game logic validation
- Integration tests for game flow
- Test different difficulty levels and edge cases

## Performance Considerations

- Efficient grid rendering with GridView.builder
- Minimal setState calls with targeted updates
- Optimized random generation algorithms
- Proper memory management for game states