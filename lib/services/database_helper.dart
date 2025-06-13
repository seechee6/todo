import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  // Initialize the database factory for web and desktop
  static void initialize() {
    if (kIsWeb) {
      // Initialize for web specifically
      databaseFactory = databaseFactoryFfiWeb;
    } else if (!Platform.isAndroid && !Platform.isIOS) {
      // Initialize FFI for desktop (Windows, macOS, Linux)
      databaseFactory = databaseFactoryFfi;
    }
    // For Android and iOS, use the default sqflite factory (no initialization needed)
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      print('DatabaseHelper: Initializing database...');
      _database = await _initDatabase().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            'Database initialization timed out',
            const Duration(seconds: 10),
          );
        },
      );
      print('DatabaseHelper: Database initialized successfully');
      return _database!;
    } catch (e) {
      print('DatabaseHelper: Failed to initialize database: $e');
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    try {
      // Get the path to the database
      String path = join(await getDatabasesPath(), 'todo_database.db');

      print('Initializing database at: $path');

      // Open the database
      return await openDatabase(path, version: 1, onCreate: _createDatabase);
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    print('Creating database tables...');
    // Create the tasks table
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
    print('Database tables created successfully');
  }

  // Insert a task into the database
  Future<void> insertTask(Task task) async {
    try {
      print('Inserting task: ${task.title}');
      final db = await database;
      await db.insert(
        'tasks',
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Task inserted successfully');
    } catch (e) {
      print('Error inserting task: $e');
      rethrow;
    }
  }

  // Retrieve all tasks from the database
  Future<List<Task>> getTasks() async {
    try {
      print('Fetching tasks from database...');
      final db = await database;
      final List<Map<String, dynamic>> taskMaps = await db.query('tasks');
      print('Found ${taskMaps.length} tasks in database');

      final tasks = List.generate(taskMaps.length, (i) {
        return Task.fromMap(taskMaps[i]);
      });

      print('Converted ${tasks.length} tasks successfully');
      return tasks;
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  // Update a task in the database
  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete a task from the database
  Future<void> deleteTask(String taskId) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  } // Get tasks for a specific date

  Future<List<Task>> getTasksForDate(DateTime date) async {
    final tasks = await getTasks();

    // Filter tasks by date (comparing year, month, day only)
    return tasks.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
