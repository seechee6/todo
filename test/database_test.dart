import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/models/task.dart';
import 'package:todo/services/database_helper.dart';
import 'package:todo/services/task_service.dart';

void main() {
  group('SQLite Database Tests', () {
    late DatabaseHelper dbHelper;
    late TaskService taskService;

    setUp(() async {
      WidgetsFlutterBinding.ensureInitialized();
      dbHelper = DatabaseHelper();
      taskService = TaskService();
    });

    test('Database initialization', () async {
      // This should not throw an exception
      final db = await dbHelper.database;
      expect(db, isNotNull);
    });

    test('Insert and retrieve task', () async {
      final task = Task(
        id: 'test-1',
        title: 'Test Task',
        description: 'This is a test task',
        date: DateTime.now(),
        isCompleted: false,
      );

      // Insert task
      await taskService.addTask(task);

      // Retrieve tasks
      final tasks = await taskService.getTasks();

      expect(tasks.length, greaterThan(0));
      expect(tasks.any((t) => t.id == 'test-1'), isTrue);
    });

    test('Update task', () async {
      final task = Task(
        id: 'test-2',
        title: 'Test Task 2',
        description: 'This is another test task',
        date: DateTime.now(),
        isCompleted: false,
      );

      // Insert task
      await taskService.addTask(task);

      // Update task
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        date: task.date,
        isCompleted: true,
      );

      await taskService.updateTask(updatedTask);

      // Retrieve and verify
      final tasks = await taskService.getTasks();
      final retrievedTask = tasks.firstWhere((t) => t.id == 'test-2');

      expect(retrievedTask.isCompleted, isTrue);
    });

    test('Delete task', () async {
      final task = Task(
        id: 'test-3',
        title: 'Test Task 3',
        description: 'This task will be deleted',
        date: DateTime.now(),
        isCompleted: false,
      );

      // Insert task
      await taskService.addTask(task);

      // Verify it exists
      var tasks = await taskService.getTasks();
      expect(tasks.any((t) => t.id == 'test-3'), isTrue);

      // Delete task
      await taskService.deleteTask(task.id);

      // Verify it's gone
      tasks = await taskService.getTasks();
      expect(tasks.any((t) => t.id == 'test-3'), isFalse);
    });
  });
}
