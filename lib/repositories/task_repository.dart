import 'package:tasker/models/task_model.dart';

import '../database/database_helper.dart';

class TaskRepository {
  final DatabaseHelper databaseHelper;

  TaskRepository(this.databaseHelper);

  Future<List<TaskModel>> getAllTasks() async {
    final rows = await databaseHelper.getTasks();

    return rows.map(TaskModel.fromMap).toList();
  }

  Future<int> addTask(TaskModel task) async {
    final data = task.toMap();

    data.remove('id');

    return databaseHelper.insertTask(data);
  }

  Future<int> updateTask(TaskModel task) async {
    if (task.id == null) {
      throw ArgumentError('Cannot update a task without an ID.');
    }

    final data = task.toMap();

    data.remove('id');

    return databaseHelper.updateTask(task.id!, data);
  }

  Future<int> deleteTask(int id) {
    return databaseHelper.deleteTask(id);
  }
}
