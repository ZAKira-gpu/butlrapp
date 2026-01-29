import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Endpoint for task CRUD operations
class TaskEndpoint extends Endpoint {
  
  /// Create a new task
  Future<Task> createTask(Session session, Task task) async {
    // Set creation timestamp
    task.createdAt = DateTime.now();
    
    // Insert into database
    return await Task.db.insertRow(session, task);
  }

  /// Get all tasks for the current user
  Future<List<Task>> getTasks(Session session) async {
    // For now, get all tasks. In production, filter by user ID
    final tasks = await Task.db.find(
      session,
      orderBy: (t) => t.dueAt,
    );
    
    return tasks;
  }

  /// Get tasks for a specific date (including recurring instances)
  Future<List<Task>> getTasksByDate(Session session, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    // 1. Get standard tasks for this specific date
    final specificTasks = await Task.db.find(
      session,
      where: (t) => 
        (t.dueAt >= startOfDay) & (t.dueAt < endOfDay),
      orderBy: (t) => t.dueAt,
    );
    
    // 2. Get ALL recurring tasks that started BEFORE or ON this day
    final recurringTasks = await Task.db.find(
      session,
      where: (t) => 
        (t.recurrence.notEquals(null)) & (t.dueAt < endOfDay),
    );
    print('DEBUG SCHEDULE: Date=$date Specific=${specificTasks.length} Recurring=${recurringTasks.length}');
    
    // 3. Filter recurring tasks that SHOULD appear on this date
    final virtualTasks = <Task>[];
    
    for (final task in recurringTasks) {
       // Skip if already in specificTasks (to avoid duplicates if the recurring task literally started today)
       if (specificTasks.any((t) => t.id == task.id)) continue;
       
       if (_matchesRecurrence(task, startOfDay)) {
          // Clone the task but set the virtual due date to today
          // We set ID to null or negative to indicate it's a virtual instance if needed, 
          // or keep it same so user can edit the "parent". 
          // For simple completion toggling, keeping the same ID might be tricky unless we create a separate "Completion" table.
          // For now, let's just show it.
          final newTask = task.copyWith(
             dueAt: DateTime(
               startOfDay.year, 
               startOfDay.month, 
               startOfDay.day, 
               task.dueAt?.hour ?? 9, 
               task.dueAt?.minute ?? 0
             ),
          );
          virtualTasks.add(newTask);
       }
    }
    
    return [...specificTasks, ...virtualTasks];
  }

  bool _matchesRecurrence(Task task, DateTime targetDate) {
    if (task.dueAt == null) return false;
    final start = DateTime(task.dueAt!.year, task.dueAt!.month, task.dueAt!.day);
    final diff = targetDate.difference(start).inDays;
    
    if (diff < 0) return false; // Target is before start date
    
    switch (task.recurrence!.toLowerCase()) {
      case 'daily':
        return true; // daily tasks match every day after start
      case 'weekly':
        return diff % 7 == 0; // matches same day of week
      case 'monthly':
        return task.dueAt!.day == targetDate.day; // matches same day of month
      case 'yearly':
        return task.dueAt!.month == targetDate.month && task.dueAt!.day == targetDate.day;
      default:
        return false;
    }
  }

  /// Get incomplete tasks
  Future<List<Task>> getIncompleteTasks(Session session) async {
    final tasks = await Task.db.find(
      session,
      where: (t) => t.completed.equals(false),
      orderBy: (t) => t.dueAt,
    );
    
    return tasks;
  }

  /// Update an existing task
  Future<Task> updateTask(Session session, Task task) async {
    await Task.db.updateRow(session, task);
    
    session.log('Task updated: ${task.title}');
    return task;
  }

  /// Delete a task
  Future<bool> deleteTask(Session session, int taskId) async {
    final result = await Task.db.deleteWhere(
      session,
      where: (t) => t.id.equals(taskId),
    );
    
    session.log('Task deleted: ID $taskId');
    return result.isNotEmpty;
  }

  /// Mark task as completed
  Future<Task?> completeTask(Session session, int taskId) async {
    final task = await Task.db.findById(session, taskId);
    
    if (task == null) return null;
    
    final updatedTask = task.copyWith(completed: true);
    await Task.db.updateRow(session, updatedTask);
    
  session.log('Task completed: ${task.title}');
    return updatedTask;
  }

  /// Clear all tasks and chat messages
  Future<bool> clearAll(Session session) async {
    try {
      await Task.db.deleteWhere(session, where: (t) => Constant.bool(true));
      await ChatMessage.db.deleteWhere(session, where: (t) => Constant.bool(true));
      return true;
    } catch (e) {
      session.log('Error clearing database: $e', level: LogLevel.error);
      return false;
    }
  }
}
