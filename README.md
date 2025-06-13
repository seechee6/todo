# Flutter Todo App with SQLite

A comprehensive Flutter todo application with SQLite database integration for robust data persistence.

## Features

- ✅ Create, read, update, and delete tasks
- 📅 Calendar view with task scheduling
- 🗄️ SQLite database for reliable data storage
- 🔄 Automatic migration from SharedPreferences to SQLite
- 📱 Cross-platform support (iOS, Android, Web, Desktop)
- 🎨 Modern Material Design 3 UI

## Data Persistence

This app uses **SQLite** for data storage, providing:
- Better performance than SharedPreferences
- ACID compliance for data integrity
- Support for complex queries
- Scalable storage for large datasets

### Migration
The app automatically migrates existing data from SharedPreferences to SQLite on first launch after the update.

## Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation
1. Clone this repository
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

### Dependencies
- `sqflite`: SQLite database integration
- `path`: Database file path management
- `table_calendar`: Calendar widget
- `intl`: Date formatting
- `uuid`: Unique ID generation

## Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/
│   └── task.dart            # Task data model
├── services/
│   ├── database_helper.dart  # SQLite operations
│   ├── migration_service.dart # Data migration
│   └── task_service.dart    # Task business logic
└── screens/
    ├── home_screen.dart     # Main task list
    ├── calendar_screen.dart # Calendar view
    └── task_form_screen.dart # Add/edit tasks
```

## Database Schema
```sql
CREATE TABLE tasks(
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  date TEXT NOT NULL,
  isCompleted INTEGER NOT NULL DEFAULT 0
)
```

For detailed migration information, see [SQLITE_MIGRATION.md](SQLITE_MIGRATION.md).

## Flutter Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Online documentation](https://docs.flutter.dev/)
