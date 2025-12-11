/// lib/data/task_database.dart
/// DB helper using sqflite. Creates tasks table and provides CRUD operations.

import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';

class TaskDatabase {
  static final TaskDatabase instance = TaskDatabase._init();
  static Database? _database;
  TaskDatabase._init();

  final String tableTasks = 'tasks';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    Directory docDir = await getApplicationDocumentsDirectory();
    String path = join(docDir.path, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableTasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      dueDate TEXT,
      category TEXT,
      priority INTEGER,
      status TEXT,
      isCompleted INTEGER
    )
    ''');
  }

  Future<Task> create(Task task) async {
    final db = await instance.database;
    final id = await db.insert(tableTasks, task.toMap());
    task.id = id;
    return task;
  }

  Future<Task?> readTask(int id) async {
    final db = await instance.database;
    final maps = await db.query(tableTasks, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Task.fromMap(maps.first);
    return null;
  }

  Future<List<Task>> readAllTasks() async {
    final db = await instance.database;
    final result = await db.query(tableTasks, orderBy: 'dueDate IS NULL, dueDate');
    return result.map((m) => Task.fromMap(m)).toList();
  }

  Future<int> update(Task task) async {
    final db = await instance.database;
    return db.update(tableTasks, task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete(tableTasks, where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
