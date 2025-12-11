/// lib/views/home_page.dart
/// VIEW: Home page shows list of tasks and calendar view toggle.
/// Uses TaskController to load and modify tasks.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';
import 'add_task_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskController _controller = TaskController();
  List<Task> _tasks = [];
  bool _loading = true;
  bool _calendarView = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  Future<void> _refreshTasks() async {
    setState(() => _loading = true);
    _tasks = await _controller.getAllTasks();
    setState(() => _loading = false);
  }

  Future<void> _deleteTask(int id) async {
    await _controller.deleteTask(id);
    await _refreshTasks();
  }

  Future<void> _toggleComplete(Task t) async {
    await _controller.toggleComplete(t);
    await _refreshTasks();
  }

  Map<DateTime, List<Task>> _groupTasksByDate() {
    Map<DateTime, List<Task>> map = {};
    for (var t in _tasks) {
      if (t.dueDate != null) {
        final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
        map.putIfAbsent(d, () => []).add(t);
      }
    }
    return map;
  }

  List<Task> _tasksForDay(DateTime day) {
    final map = _groupTasksByDate();
    return map[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Widget _buildTaskTile(Task t) {
    final dueStr = t.dueDate == null ? 'No date' : DateFormat.yMMMd().format(t.dueDate!);
    final priorityStr = t.priority == 2 ? 'High' : (t.priority == 1 ? 'Medium' : 'Low');

    return Card(
      child: ListTile(
        leading: IconButton(
          icon: Icon(t.isCompleted ? Icons.check_box : Icons.check_box_outline_blank),
          onPressed: () => _toggleComplete(t),
        ),
        title: Text(
          t.title,
          style: TextStyle(decoration: t.isCompleted ? TextDecoration.lineThrough : TextDecoration.none),
        ),
        subtitle: Text('$dueStr • $priorityStr • ${t.category ?? "No category"}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddTaskPage(task: t)));
                if (res == true) _refreshTasks();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(t),
            ),
          ],
        ),
        onTap: () => _toggleComplete(t),
      ),
    );
  }

  void _confirmDelete(Task t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Delete "${t.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTask(t.id!);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_tasks.isEmpty) return const Center(child: Text('No tasks yet. Tap + to add.'));

    return RefreshIndicator(
      onRefresh: _refreshTasks,
      child: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (_, i) => _buildTaskTile(_tasks[i]),
      ),
    );
  }

  Widget _buildCalendarView() {
    final tasksByDate = _groupTasksByDate();
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          focusedDay: _focusedDay,
          selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
          onDaySelected: (selected, focused) {
            setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            });
          },
          eventLoader: (day) => tasksByDate[DateTime(day.year, day.month, day.day)] ?? [],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: _tasksForDay(_selectedDay ?? _focusedDay)
                .map((t) => ListTile(
                      title: Text(t.title),
                      subtitle: Text(t.description ?? ''),
                      trailing: IconButton(
                        icon: Icon(t.isCompleted ? Icons.check_box : Icons.check_box_outline_blank),
                        onPressed: () => _toggleComplete(t),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do MVC Complete'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              if (res == true) _refreshTasks(); // refresh in case settings changed theme etc.
            },
          ),
          IconButton(
            icon: Icon(_calendarView ? Icons.list : Icons.calendar_today),
            onPressed: () => setState(() => _calendarView = !_calendarView),
          ),
        ],
      ),
      body: _calendarView ? _buildCalendarView() : _buildListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskPage()));
          if (res == true) _refreshTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
