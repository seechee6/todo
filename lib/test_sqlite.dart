import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../models/task.dart';
import '../services/database_helper.dart';

void main() async {
  // Avoid errors caused by flutter upgrade.
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();

  // Create a test task
  final task = Task(
    id: '1',
    title: 'Test SQLite Task',
    description: 'This is a test task to verify SQLite integration',
    date: DateTime.now(),
    isCompleted: false,
  );

  print('Testing SQLite integration...');

  // Insert the task
  await dbHelper.insertTask(task);
  print('Task inserted successfully');

  // Retrieve all tasks
  final tasks = await dbHelper.getTasks();
  print('Retrieved ${tasks.length} tasks:');
  for (final t in tasks) {
    print('  $t');
  }

  // Update the task
  final updatedTask = Task(
    id: task.id,
    title: task.title,
    description: task.description,
    date: task.date,
    isCompleted: true,
  );

  await dbHelper.updateTask(updatedTask);
  print('Task updated successfully');

  // Retrieve tasks again
  final updatedTasks = await dbHelper.getTasks();
  print('After update:');
  for (final t in updatedTasks) {
    print('  $t');
  }

  // Delete the task
  await dbHelper.deleteTask(task.id);
  print('Task deleted successfully');

  // Verify deletion
  final finalTasks = await dbHelper.getTasks();
  print('Final task count: ${finalTasks.length}');

  print('SQLite integration test completed successfully!');
}
