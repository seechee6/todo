# SQLite Migration Guide

## Overview
Your Flutter todo app has been successfully migrated from SharedPreferences to SQLite for better data persistence and performance.

## What Changed

### 1. Dependencies Added
- `sqflite`: For SQLite database operations
- `path`: For database file path management

### 2. New Files Created
- `lib/services/database_helper.dart`: Main SQLite database operations
- `lib/services/migration_service.dart`: Handles migration from SharedPreferences to SQLite
- `lib/test_sqlite.dart`: Test file to verify SQLite functionality

### 3. Modified Files
- `lib/models/task.dart`: Updated `toMap()` and `fromMap()` methods for SQLite compatibility
- `lib/services/task_service.dart`: Refactored to use SQLite instead of SharedPreferences
- `lib/main.dart`: Added database initialization and migration

## Benefits of SQLite over SharedPreferences

1. **Better Performance**: Faster queries, especially for large datasets
2. **Data Integrity**: ACID compliance ensures data consistency
3. **Complex Queries**: Support for SQL queries, joins, and indexes
4. **Scalability**: Better handling of large amounts of data
5. **Data Types**: Native support for different data types
6. **Backup/Restore**: Easier to backup and restore database files

## Database Schema

### Tasks Table
```sql
CREATE TABLE tasks(
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  date TEXT NOT NULL,
  isCompleted INTEGER NOT NULL DEFAULT 0
)
```

## Migration Process

The app automatically migrates existing data from SharedPreferences to SQLite on first launch:

1. Checks if migration has already been completed
2. Reads existing tasks from SharedPreferences
3. Converts and inserts them into SQLite database
4. Marks migration as completed
5. Optionally cleans up old SharedPreferences data

## Usage

The TaskService interface remains the same, so no changes are needed in your UI code:

```dart
final taskService = TaskService();

// Add a task
await taskService.addTask(task);

// Get all tasks
final tasks = await taskService.getTasks();

// Update a task
await taskService.updateTask(updatedTask);

// Delete a task
await taskService.deleteTask(taskId);

// Get tasks for specific date
final dateTasks = await taskService.getTasksForDate(DateTime.now());
```

## Testing

Run the test file to verify SQLite integration:
```bash
flutter run lib/test_sqlite.dart
```

## Troubleshooting

If you encounter any issues:

1. **Database not found**: The database is created automatically on first use
2. **Migration issues**: Check the console for migration logs
3. **Data loss**: The migration preserves existing SharedPreferences data
4. **Performance**: SQLite should be faster than SharedPreferences for most operations

## File Locations

- Database file: `[app_data_directory]/todo_database.db`
- The exact path is logged when the database is initialized

Your todo app now has robust, scalable data persistence with SQLite!
