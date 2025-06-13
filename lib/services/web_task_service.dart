import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class WebTaskService {
  static const String _tasksKey = 'tasks';

  // Check if we should use web fallback
  static bool get shouldUseWebFallback => kIsWeb;

  // Fetch all tasks from SharedPreferences (web fallback)
  Future<List<Task>> getTasks() async {
    try {
      print('WebTaskService: Fetching tasks from SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_tasksKey) ?? [];

      final tasks =
          tasksJson.map((taskJson) {
            return Task.fromMap(jsonDecode(taskJson));
          }).toList();

      print('WebTaskService: Fetched ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      print('WebTaskService: Error fetching tasks: $e');
      return <Task>[];
    }
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    try {
      print('WebTaskService: Adding task: ${task.title}');
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_tasksKey) ?? [];

      tasksJson.add(jsonEncode(task.toMap()));
      await prefs.setStringList(_tasksKey, tasksJson);
      print('WebTaskService: Task added successfully');
    } catch (e) {
      print('WebTaskService: Error adding task: $e');
      rethrow;
    }
  }

  // Update an existing task
  Future<void> updateTask(Task updatedTask) async {
    try {
      print('WebTaskService: Updating task: ${updatedTask.title}');
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_tasksKey) ?? [];

      final tasksList =
          tasksJson.map((taskJson) {
            final task = Task.fromMap(jsonDecode(taskJson));
            if (task.id == updatedTask.id) {
              return jsonEncode(updatedTask.toMap());
            }
            return taskJson;
          }).toList();

      await prefs.setStringList(_tasksKey, tasksList);
      print('WebTaskService: Task updated successfully');
    } catch (e) {
      print('WebTaskService: Error updating task: $e');
      rethrow;
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      print('WebTaskService: Deleting task: $taskId');
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_tasksKey) ?? [];

      final filteredTasks =
          tasksJson.where((taskJson) {
            final task = Task.fromMap(jsonDecode(taskJson));
            return task.id != taskId;
          }).toList();

      await prefs.setStringList(_tasksKey, filteredTasks);
      print('WebTaskService: Task deleted successfully');
    } catch (e) {
      print('WebTaskService: Error deleting task: $e');
      rethrow;
    }
  }

  // Get tasks for a specific date
  Future<List<Task>> getTasksForDate(DateTime date) async {
    final tasks = await getTasks();

    // Filter tasks by date (comparing year, month, day only)
    return tasks.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();
  }
}
