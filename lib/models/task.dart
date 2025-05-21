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

  // Convert a Task into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Create a Task from a Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      isCompleted: map['isCompleted'],
    );
  }
}
