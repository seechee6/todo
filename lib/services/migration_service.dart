import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'database_helper.dart';

class MigrationService {
  static const String _tasksKey = 'tasks';
  static const String _migrationKey = 'data_migrated_to_sqlite';
  static Future<void> migrateDataIfNeeded() async {
    try {
      print('Checking if migration is needed...');
      final prefs = await SharedPreferences.getInstance();

      // Check if migration has already been done
      if (prefs.getBool(_migrationKey) == true) {
        print('Migration already completed, skipping...');
        return; // Migration already completed
      }

      // Get existing tasks from SharedPreferences
      final tasksJson = prefs.getStringList(_tasksKey) ?? [];

      if (tasksJson.isEmpty) {
        print('No existing data to migrate');
        // No data to migrate, just mark as migrated
        await prefs.setBool(_migrationKey, true);
        return;
      }

      print(
        'Migrating ${tasksJson.length} tasks from SharedPreferences to SQLite...',
      );

      final dbHelper = DatabaseHelper();

      // Convert JSON strings back to Task objects and insert into SQLite
      for (final taskJson in tasksJson) {
        try {
          final taskMap = jsonDecode(taskJson);
          final task = Task.fromMap(taskMap);
          await dbHelper.insertTask(task);
        } catch (e) {
          print('Error migrating task: $e');
          // Continue with other tasks even if one fails
        }
      }

      // Mark migration as completed
      await prefs.setBool(_migrationKey, true);

      // Optionally, clear the old data from SharedPreferences
      await prefs.remove(_tasksKey);

      print('Migration completed successfully!');
    } catch (e) {
      print('Error during migration: $e');
    }
  }
}
