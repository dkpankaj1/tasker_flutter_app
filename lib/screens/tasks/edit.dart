import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tasker/components/app_bar.dart';
import 'package:tasker/models/task_model.dart';
import 'package:tasker/providers/task_provider.dart';

class TaskEdit extends StatefulWidget {
  const TaskEdit({super.key, required this.taskId});

  final int taskId;

  @override
  State<TaskEdit> createState() => _TaskEditState();
}

class _TaskEditState extends State<TaskEdit> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  String _priority = 'Medium';

  DateTime? _dueDate;

  bool _isCompleted = false;

  bool _isSaving = false;

  TaskModel? _task;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadTask();
  }

  void _loadTask() {
    final provider = context.read<TaskProvider>();
    final task = provider.getTaskById(widget.taskId);

    if (task != null) {
      _task = task;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _priority = task.priority;
      _dueDate = task.dueDate;
      _isCompleted = task.isCompleted;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (selectedDate != null) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    final task = _task;
    if (task == null) return;

    setState(() {
      _isSaving = true;
    });

    final updatedTask = task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
      isCompleted: _isCompleted,
      updatedAt: DateTime.now(),
    );

    try {
      await context.read<TaskProvider>().updateTask(updatedTask);

      if (!mounted) return;

      context.replace('/tasks/${widget.taskId}/show');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to update task.')));
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_task == null) {
      return Scaffold(
        appBar: MyAppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Task not found.'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => context.go('/tasks'),
                child: const Text('Back to tasks'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: MyAppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _selectDueDate,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                _dueDate == null
                    ? 'Select due date'
                    : 'Due: ${_dueDate!.year}-'
                          '${_dueDate!.month.toString().padLeft(2, '0')}-'
                          '${_dueDate!.day.toString().padLeft(2, '0')}',
              ),
            ),
            const SizedBox(height: 16),
            DropdownMenu(
              initialSelection: _priority,
              onSelected: (String? value) {
                if (value != null) {
                  setState(() {
                    _priority = value;
                  });
                }
              },
              dropdownMenuEntries: [
                DropdownMenuEntry(value: "Low", label: "Low"),
                DropdownMenuEntry(value: "Medium", label: "Medium"),
                DropdownMenuEntry(value: "High", label: "High"),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Completed'),
              value: _isCompleted,
              onChanged: (value) {
                setState(() {
                  _isCompleted = value;
                });
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              onPressed: _isSaving ? null : _saveTask,
              child: _isSaving ? const Text("Saving...") : const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
