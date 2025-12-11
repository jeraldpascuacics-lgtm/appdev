/// lib/views/add_task_page.dart
/// VIEW: Add/Edit Task page. Contains form fields for title, description,
/// due date, category, priority, and status. Calls TaskController for persistence.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../controllers/task_controller.dart';

class AddTaskPage extends StatefulWidget {
  final Task? task;
  const AddTaskPage({super.key, this.task});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TaskController _controller = TaskController();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _dueDate;
  String? _category;
  int _priority = 1;
  TaskStatus _status = TaskStatus.notStarted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate;
    _category = widget.task?.category;
    _priority = widget.task?.priority ?? 1;
    _status = widget.task?.status ?? TaskStatus.notStarted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    Task t = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDate: _dueDate,
      category: _category,
      priority: _priority,
      status: _status,
      isCompleted: _status == TaskStatus.completed || widget.task?.isCompleted == true,
    );

    if (widget.task == null) {
      await _controller.addTask(t);
    } else {
      await _controller.updateTask(t);
    }

    Navigator.pop(context, true);
  }

  Future<void> _pickDueDate() async {
    DateTime initial = _dueDate ?? DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _dueDate == null ? 'No date' : DateFormat.yMMMd().format(_dueDate!);

    return Scaffold(
      appBar: AppBar(title: Text(widget.task == null ? 'Add Task' : 'Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter title' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 2,
                maxLines: 5,
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category (optional)'),
                onChanged: (v) => _category = v,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _priority,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Low')),
                  DropdownMenuItem(value: 1, child: Text('Medium')),
                  DropdownMenuItem(value: 2, child: Text('High')),
                ],
                onChanged: (v) => setState(() => _priority = v ?? 1),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<TaskStatus>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: TaskStatus.notStarted, child: Text('Not started')),
                  DropdownMenuItem(value: TaskStatus.ongoing, child: Text('Ongoing')),
                  DropdownMenuItem(value: TaskStatus.completed, child: Text('Completed')),
                ],
                onChanged: (v) => setState(() => _status = v ?? TaskStatus.notStarted),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Due date: $dateStr'),
                trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDueDate),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveTask, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
