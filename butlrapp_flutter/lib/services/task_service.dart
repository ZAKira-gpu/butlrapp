import 'package:butlrapp_client/butlrapp_client.dart';
import 'package:flutter/material.dart';
import '../main.dart'; // To access the global client

class TaskService extends ChangeNotifier {
  static final TaskService _instance = TaskService._internal();

  factory TaskService() {
    return _instance;
  }

  TaskService._internal();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Fetch all tasks from the server
  Future<void> refreshTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await client.task.getTasks();
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Fetch tasks for a specific date (including recurring projections)
  Future<List<Task>> fetchTasksForDate(DateTime date) async {
    try {
      final tasks = await client.task.getTasksByDate(date);
      return tasks;
    } catch (e) {
      debugPrint('Error fetching tasks for date: $e');
      return [];
    }
  }

  /// Add a new task
  Future<Task?> addTask(Task task) async {
    try {
      // Ensure date is handled in local time context for the UI
      if (task.dueAt != null) {
        task.dueAt = task.dueAt!.toLocal();
      }
      final newTask = await client.task.createTask(task);
      _tasks.insert(0, newTask);
      notifyListeners();
      return newTask;
    } catch (e) {
      debugPrint('Error adding task: $e');
      return null;
    }
  }

  /// Remove a task
  Future<bool> removeTask(int id) async {
    final originalTasks = List<Task>.from(_tasks);
    try {
      // Optimistic update
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();

      final success = await client.task.deleteTask(id);
      if (!success) {
        // Rollback if failed
        _tasks = originalTasks;
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error removing task: $e');
      _tasks = originalTasks;
      notifyListeners();
      return false;
    }
  }

  /// Update a task's completion status or other fields
  Future<Task?> updateTaskStatus(int id, bool completed) async {
    final originalTasks = List<Task>.from(_tasks);
    try {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index == -1) return null;

      // Optimistic update
      _tasks[index] = _tasks[index].copyWith(completed: completed);
      notifyListeners();

      final result = await client.task.updateTask(_tasks[index]);
      
      // Update with server result to be sure (id tags, etc)
      _tasks[index] = result;
      // No need to notify again unless result differs significantly, 
      // but let's be safe:
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('Error updating task: $e');
      _tasks = originalTasks;
      notifyListeners();
      return null;
    }
  }

  /// Update a task's details (title, description, priority, due date)
  Future<Task?> updateTask(Task task) async {
    final originalTasks = List<Task>.from(_tasks);
    try {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index == -1) return null;

      // Optimistic update
      _tasks[index] = task;
      notifyListeners();

      final result = await client.task.updateTask(task);
      
      // Update with server result
      _tasks[index] = result;
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('Error updating task: $e');
      _tasks = originalTasks; // Rollback
      notifyListeners();
      return null;
    }
  }
}
