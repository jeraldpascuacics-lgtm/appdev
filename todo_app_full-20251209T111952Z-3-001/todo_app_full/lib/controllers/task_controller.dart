/// lib/controllers/task_controller.dart
/// Controller bridging Views and Model/DB. All business logic belongs here.

import '../models/task.dart';
import '../data/task_database.dart';

class TaskController {
  Future<Task> addTask(Task task) async {
    return await TaskDatabase.instance.create(task);
  }

  Future<List<Task>> getAllTasks() async {
    return await TaskDatabase.instance.readAllTasks();
  }

  Future<int> updateTask(Task task) async {
    return await TaskDatabase.instance.update(task);
  }

  Future<int> deleteTask(int id) async {
    return await TaskDatabase.instance.delete(id);
  }

  Future<int> toggleComplete(Task task) async {
    task.isCompleted = !task.isCompleted;
    task.status = task.isCompleted ? TaskStatus.completed : TaskStatus.ongoing;
    return await updateTask(task);
  }
}
