import 'package:flutter/foundation.dart';
import 'package:tasker/models/task_model.dart';
import '../repositories/task_repository.dart';

enum TaskFilter { all, pending, completed }

class TaskProvider extends ChangeNotifier {
  final TaskRepository repository;

  TaskProvider(this.repository);

  List<TaskModel> _tasks = [];

  TaskFilter _filter = TaskFilter.all;

  String _searchQuery = '';

  bool _isLoading = false;

  String? _error;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  TaskModel? getTaskById(int id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  TaskFilter get filter => _filter;

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<TaskModel> get filteredTasks {
    return _tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = switch (_filter) {
        TaskFilter.all => true,
        TaskFilter.pending => !task.isCompleted,
        TaskFilter.completed => task.isCompleted,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      _tasks = await repository.getAllTasks();
    } catch (e) {
      _error = 'Failed to load tasks.';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  void setFilter(TaskFilter filter) {
    _filter = filter;

    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;

    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    final id = await repository.addTask(task);

    _tasks = [task.copyWith(id: id), ..._tasks];

    notifyListeners();
  }

  Future<void> updateTask(TaskModel task) async {
    await repository.updateTask(task);

    _tasks = _tasks.map((existingTask) {
      return existingTask.id == task.id ? task : existingTask;
    }).toList();

    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await repository.deleteTask(id);

    _tasks.removeWhere((task) => task.id == id);

    notifyListeners();
  }

  Future<void> toggleTask(TaskModel task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted, updatedAt: DateTime.now());

    await updateTask(updatedTask);
  }
}
