import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'task_form_screen.dart';
import 'calendar_screen.dart';
import 'debug_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('HomeScreen: Loading tasks...');
      final tasks = await _taskService.getTasks();
      print('HomeScreen: Loaded ${tasks.length} tasks');

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      print('HomeScreen: Error loading tasks: $e');
      setState(() {
        _tasks = [];
        _isLoading = false;
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading tasks: $e')));
      }
    }
  }

  void _deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
    _loadTasks();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task deleted')));
  }

  void _toggleTaskCompletion(Task task) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      date: task.date,
      isCompleted: !task.isCompleted,
    );

    await _taskService.updateTask(updatedTask);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebugScreen()),
              );
            },
            tooltip: 'Debug Database',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
              _loadTasks();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Loading tasks...'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = false;
                        _tasks = [];
                      });
                    },
                    child: const Text('Skip Loading'),
                  ),
                ],
              )
              : _tasks.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.task_alt, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No tasks yet. Add a task!'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _loadTasks(),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  final formattedDate = DateFormat(
                    'MMM dd, yyyy',
                  ).format(task.date);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) => _toggleTaskCompletion(task),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration:
                              task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      subtitle: Text(formattedDate),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => TaskFormScreen(task: task),
                                ),
                              );
                              _loadTasks();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteTask(task.id),
                          ),
                        ],
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    task.title,
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text('Date: $formattedDate'),
                                  const SizedBox(height: 8.0),
                                  if (task.description != null &&
                                      task.description!.isNotEmpty)
                                    Text(task.description!),
                                  const SizedBox(height: 16.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskFormScreen()),
          );
          _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
