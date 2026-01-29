
import 'package:serverpod/serverpod.dart';
import 'package:butlrapp_server/src/generated/protocol.dart';

void main(List<String> args) async {
  // Use InternalSession to avoid starting a full server that conflicts on ports
  final session = InternalSession(
    enableLogging: false,
  );

  print('\n--- Debugging Task Recurrence ---');
  
  try {
    final tasks = await Task.db.find(session);
    
    if (tasks.isEmpty) {
      print('No tasks found in database.');
    } else {
      print('Found ${tasks.length} tasks:');
      for (final task in tasks) {
        print('ID: ${task.id}');
        print('  Title: ${task.title}');
        print('  DueAt: ${task.dueAt}');
        print('  Recurrence: ${task.recurrence ?? "NULL"}');
        print('  Interval: ${task.recurrenceInterval ?? "NULL"}');
        // Check if created today
        final daysDiff = DateTime.now().difference(task.createdAt).inDays;
        print('  Created: ${task.createdAt} ($daysDiff days ago)');
        print('-----------------------------------');
      }
    }
  } catch (e) {
    print('Error querying database: $e');
  } finally {
    await session.close();
  }
}

class InternalSession extends Session {
  InternalSession({bool enableLogging = false}) 
      : super(
          server: Server(
            serializationManager: Protocol(),
            endpoints: Endpoints(),
          ),
          enableLogging: enableLogging,
        );
}
