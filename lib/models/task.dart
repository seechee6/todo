class Task {
  String id;
  String title;
  String? description;
  DateTime date;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.isCompleted = false,
  });
  // Convert a Task into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0, // SQLite stores booleans as integers
    };
  }

  // Create a Task from a Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      isCompleted: map['isCompleted'] == 1, // Convert integer back to boolean
    );
  }

  // Implement toString to make it easier to see information about
  // each task when using the print statement.
  @override
  String toString() {
    return 'Task{id: $id, title: $title, description: $description, date: $date, isCompleted: $isCompleted}';
  }
}
