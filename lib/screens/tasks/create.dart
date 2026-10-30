import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasker/components/app_bar.dart';
import 'package:tasker/models/task_model.dart';
import 'package:tasker/providers/task_provider.dart';
import 'package:provider/provider.dart';

class TaskCreate extends StatefulWidget {
  const TaskCreate({super.key});

  @override
  State<TaskCreate> createState() => _TaskCreateState();
}

class _TaskCreateState extends State<TaskCreate> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  String _priority = 'Medium';

  DateTime? _dueDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
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

    setState(() {
      _isSaving = true;
    });

    final now = DateTime.now();
    final task = TaskModel(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
      isCompleted: false,
      dueDate: _dueDate,
      createdAt: now,
      updatedAt: now,
    );

    try {
      final provider = context.read<TaskProvider>();
      await provider.addTask(task);

      if (!mounted) return;

      context.replace('tasks');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to save task.')));
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(10),
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

            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // change value as needed
                ),
              ),
              onPressed: _isSaving ? null : _saveTask,
              child: _isSaving ? Text("Saving...") : Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
