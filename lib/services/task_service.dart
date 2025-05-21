import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService {
  static const String _tasksKey = 'tasks';

  // Fetch all tasks
  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];

    return tasksJson.map((taskJson) {
      return Task.fromMap(jsonDecode(taskJson));
    }).toList();
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];

    tasksJson.add(jsonEncode(task.toMap()));
    await prefs.setStringList(_tasksKey, tasksJson);
  }

  // Update an existing task
  Future<void> updateTask(Task updatedTask) async {
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
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];

    final filteredTasks =
        tasksJson.where((taskJson) {
          final task = Task.fromMap(jsonDecode(taskJson));
          return task.id != taskId;
        }).toList();

    await prefs.setStringList(_tasksKey, filteredTasks);
  }

  // Get tasks for a specific date
  Future<List<Task>> getTasksForDate(DateTime date) async {
    final tasks = await getTasks();
    return tasks.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();
  }
}
