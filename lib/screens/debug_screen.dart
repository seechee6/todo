import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Loading debug information...\n';
    });
    try {
      final taskService = TaskService();

      _debugInfo += 'Fetching tasks from TaskService...\n';
      final tasks = await taskService.getTasks();

      _debugInfo += 'Tasks found: ${tasks.length}\n';
      for (int i = 0; i < tasks.length; i++) {
        _debugInfo +=
            'Task ${i + 1}: ${tasks[i].title} (${tasks[i].isCompleted ? 'Completed' : 'Pending'})\n';
      }

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo += 'Error: $e\n';
        _isLoading = false;
      });
    }
  }

  Future<void> _addTestTask() async {
    final taskService = TaskService();
    final testTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Test Task ${DateTime.now().millisecondsSinceEpoch}',
      description: 'This is a test task created from debug screen',
      date: DateTime.now(),
      isCompleted: false,
    );

    try {
      await taskService.addTask(testTask);
      _debugInfo += 'Test task added successfully\n';
      _loadDebugInfo();
    } catch (e) {
      setState(() {
        _debugInfo += 'Error adding test task: $e\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Screen'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _loadDebugInfo,
                  child: const Text('Refresh'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTestTask,
                  child: const Text('Add Test Task'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Debug Information:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _debugInfo,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tasks in Database:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_tasks.isEmpty)
                        const Text('No tasks found in database')
                      else
                        ...(_tasks
                            .map(
                              (task) => Card(
                                child: ListTile(
                                  title: Text(task.title),
                                  subtitle: Text(
                                    '${task.description ?? 'No description'}\nDate: ${task.date.toString()}',
                                  ),
                                  trailing: Icon(
                                    task.isCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color:
                                        task.isCompleted
                                            ? Colors.green
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            )
                            .toList()),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
