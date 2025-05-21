import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'task_form_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late TaskService _taskService;
  List<Task> _selectedDayTasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _taskService = TaskService();
    _loadTasksForSelectedDay();
  }

  Future<void> _loadTasksForSelectedDay() async {
    setState(() {
      _isLoading = true;
    });

    final tasks = await _taskService.getTasksForDate(_selectedDay);

    setState(() {
      _selectedDayTasks = tasks;
      _isLoading = false;
    });
  }

  Future<Map<DateTime, List<Task>>> _loadAllTasks() async {
    final tasks = await _taskService.getTasks();
    final tasksByDay = <DateTime, List<Task>>{};

    for (final task in tasks) {
      final date = DateTime(task.date.year, task.date.month, task.date.day);

      if (!tasksByDay.containsKey(date)) {
        tasksByDay[date] = [];
      }

      tasksByDay[date]!.add(task);
    }

    return tasksByDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          FutureBuilder<Map<DateTime, List<Task>>>(
            future: _loadAllTasks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasksByDay = snapshot.data ?? {};

              return TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: (day) {
                  final date = DateTime(day.year, day.month, day.day);
                  return tasksByDay[date] ?? [];
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _loadTasksForSelectedDay();
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: const CalendarStyle(
                  markersMaxCount: 3,
                  markerDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Tasks for ${DateFormat.yMMMMd().format(_selectedDay)}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final initialDate = _selectedDay;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                TaskFormScreen(initialDate: initialDate),
                      ),
                    );
                    _loadTasksForSelectedDay();
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                child:
                    _selectedDayTasks.isEmpty
                        ? const Center(child: Text('No tasks for this day'))
                        : ListView.builder(
                          itemCount: _selectedDayTasks.length,
                          itemBuilder: (context, index) {
                            final task = _selectedDayTasks[index];
                            return ListTile(
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) async {
                                  final updatedTask = Task(
                                    id: task.id,
                                    title: task.title,
                                    description: task.description,
                                    date: task.date,
                                    isCompleted: value ?? false,
                                  );

                                  await _taskService.updateTask(updatedTask);
                                  _loadTasksForSelectedDay();
                                },
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
                              subtitle:
                                  task.description != null &&
                                          task.description!.isNotEmpty
                                      ? Text(
                                        task.description!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                      : null,
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              TaskFormScreen(task: task),
                                    ),
                                  );
                                  _loadTasksForSelectedDay();
                                },
                              ),
                            );
                          },
                        ),
              ),
        ],
      ),
    );
  }
}
