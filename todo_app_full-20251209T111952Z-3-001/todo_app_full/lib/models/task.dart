/// lib/models/task.dart
/// MODEL: Task data class. All fields here to make DB integration easy.
/// Fields: id, title, description, dueDate, category, priority, status, isCompleted
import 'package:flutter/foundation.dart';

enum TaskStatus { notStarted, ongoing, completed }

class Task {
  int? id;
  String title;
  String? description;
  DateTime? dueDate;
  String? category;
  int priority; // 0 low,1 medium,2 high
  TaskStatus status;
  bool isCompleted;

  Task({
    this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.category,
    this.priority = 1,
    this.status = TaskStatus.notStarted,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'category': category,
      'priority': priority,
      'status': describeEnum(status),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      category: map['category'] as String?,
      priority: map['priority'] as int? ?? 1,
      status: map['status'] != null ? _statusFromString(map['status'] as String) : TaskStatus.notStarted,
      isCompleted: (map['isCompleted'] as int?) == 1,
    );
  }

  static TaskStatus _statusFromString(String s) {
    switch (s) {
      case 'ongoing':
        return TaskStatus.ongoing;
      case 'completed':
        return TaskStatus.completed;
      default:
        return TaskStatus.notStarted;
    }
  }
}
