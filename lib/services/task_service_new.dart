import 'package:flutter/foundation.dart';
import '../models/task.dart';
import 'database_helper.dart';
import 'web_task_service.dart';

class TaskService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final WebTaskService _webTaskService = WebTaskService();

  // Choose the appropriate service based on platform
  bool get _useWebFallback => kIsWeb;

  // Fetch all tasks
  Future<List<Task>> getTasks() async {
    try {
      print('TaskService: Fetching tasks...');

      if (_useWebFallback) {
        // Use SharedPreferences for web as fallback
        return await _webTaskService.getTasks();
      } else {
        // Use SQLite for mobile/desktop
        final tasks = await _databaseHelper.getTasks().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print(
              'TaskService: SQLite getTasks() timed out, falling back to SharedPreferences',
            );
            return _webTaskService.getTasks();
          },
        );
        print('TaskService: Fetched ${tasks.length} tasks');
        return tasks;
      }
    } catch (e) {
      print('TaskService: Error fetching tasks: $e, trying web fallback');
      // Fallback to SharedPreferences if SQLite fails
      return await _webTaskService.getTasks();
    }
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    if (_useWebFallback) {
      await _webTaskService.addTask(task);
    } else {
      try {
        await _databaseHelper.insertTask(task);
      } catch (e) {
        print('TaskService: SQLite insert failed, using web fallback: $e');
        await _webTaskService.addTask(task);
      }
    }
  }

  // Update an existing task
  Future<void> updateTask(Task updatedTask) async {
    if (_useWebFallback) {
      await _webTaskService.updateTask(updatedTask);
    } else {
      try {
        await _databaseHelper.updateTask(updatedTask);
      } catch (e) {
        print('TaskService: SQLite update failed, using web fallback: $e');
        await _webTaskService.updateTask(updatedTask);
      }
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    if (_useWebFallback) {
      await _webTaskService.deleteTask(taskId);
    } else {
      try {
        await _databaseHelper.deleteTask(taskId);
      } catch (e) {
        print('TaskService: SQLite delete failed, using web fallback: $e');
        await _webTaskService.deleteTask(taskId);
      }
    }
  }

  // Get tasks for a specific date
  Future<List<Task>> getTasksForDate(DateTime date) async {
    if (_useWebFallback) {
      return await _webTaskService.getTasksForDate(date);
    } else {
      try {
        return await _databaseHelper.getTasksForDate(date);
      } catch (e) {
        print(
          'TaskService: SQLite getTasksForDate failed, using web fallback: $e',
        );
        return await _webTaskService.getTasksForDate(date);
      }
    }
  }
}
