import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tasker/components/app_bar.dart';
import 'package:tasker/components/app_drawer.dart';
import 'package:tasker/components/bottom_nav.dart';
import 'package:tasker/providers/task_provider.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  Future<void> confirmDelete(BuildContext context, int? id) async {
    await showDialog(
      context: context,
      builder: (BuildContext builder) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this task?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (id != null) {
                  context.read<TaskProvider>().deleteTask(id);
                }
                Navigator.pop(context, true);
              },
              child: const Text('delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      drawer: AppDrawer(),
      bottomNavigationBar: MyBottomNavigation(),
      floatingActionButton: IconButton(
        onPressed: () {
          context.push("/tasks/create");
        },
        icon: Icon(Icons.add, color: Colors.white),
        style: IconButton.styleFrom(backgroundColor: Colors.deepPurple),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 8),
                  FilledButton(onPressed: provider.loadTasks, child: const Text('Retry')),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5),
            itemCount: provider.tasks.length,
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              final taskId = task.id;

              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.isCompleted ? 'Completed' : 'Pending'),
                onTap: () {
                  if (taskId != null) {
                    context.push('/tasks/$taskId/show');
                  }
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        if (taskId != null) {
                          context.push('/tasks/$taskId/edit');
                        }
                      },
                      color: Colors.white,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        if (taskId != null) {
                          confirmDelete(context, taskId);
                        }
                      },
                      color: Colors.white,
                    ),
                  ],
                ),
                tileColor: Colors.deepPurple.shade500,
                textColor: Colors.white,
                selectedTileColor: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
