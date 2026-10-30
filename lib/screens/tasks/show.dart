import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tasker/components/app_bar.dart';
import 'package:tasker/models/task_model.dart';
import 'package:tasker/providers/task_provider.dart';

class TaskShow extends StatelessWidget {
  const TaskShow({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final TaskModel? task = provider.getTaskById(taskId);

    if (task == null) {
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text(task.priority),
                backgroundColor: _priorityColor(context, task.priority),
              ),
              const SizedBox(width: 8),
              Chip(
                avatar: Icon(
                  task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 18,
                ),
                label: Text(task.isCompleted ? 'Completed' : 'Pending'),
              ),
            ],
          ),
          if (task.dueDate != null) ...[
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month),
              title: const Text('Due date'),
              subtitle: Text(
                '${task.dueDate!.year}-'
                '${task.dueDate!.month.toString().padLeft(2, '0')}-'
                '${task.dueDate!.day.toString().padLeft(2, '0')}',
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(task.description.isEmpty ? 'No description.' : task.description),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/tasks/$taskId/edit'),
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(BuildContext context, String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade100;
      case 'low':
        return Colors.green.shade100;
      default:
        return Colors.orange.shade100;
    }
  }
}
