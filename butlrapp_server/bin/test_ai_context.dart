import 'package:butlrapp_server/src/services/ai_service.dart';
import 'package:butlrapp_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

// Mock Session for logging
class MockSession extends Session {
  MockSession() : super(
    server: Server(
      serializationManager: Protocol(), 
      endpoints: Endpoints(),
      serverId: 'test',
      runMode: 'test',
    ),
    enableLogging: true,
  );
  
  @override
  void log(String message, {LogLevel? level, Object? exception, StackTrace? stackTrace}) {
    print('[${level ?? LogLevel.info}] $message');
    if (exception != null) print('Exception: $exception');
  }
}

void main() async {
  // Use the key from config or environment
  final apiKey = 'sk_ibfw8oxL29xDBrz-qlHvEtbZAULOsu4qKz9sW1jCFL4'; 
  final service = AIService(apiKey);
  final session = MockSession();

  // 1. Simulate the first message: "tomorrow dentist at 5 pm"
  // The user said this first, and it failed (returned unknown).
  // Let's see what the AI RETURNS for this single message first.
  print('--- Test 1: Single Message ---');
  final msg1 = "tomorrow dentist at 5 pm";
  final res1 = await service.processMessage(msg1, session);
  print('Intent: ${res1.intent}');
  print('Message: ${res1.message}');
  if (res1.taskData != null) {
      print('Task: ${res1.taskData!.title}, Priority: ${res1.taskData!.priority}');
  }

  // 2. Simulate the history and the follow-up "remind of it"
  print('\n--- Test 2: History Context ---');
  final history = [
    ChatMessage(content: "tomorrow dentist at 5 pm", isUser: true, timestamp: DateTime.now().subtract(Duration(minutes: 1))),
    ChatMessage(content: res1.message, isUser: false, timestamp: DateTime.now().subtract(Duration(seconds: 30))),
  ];
  
  final msg2 = "remind of it";
  final res2 = await service.processMessage(msg2, session, history: history);
  
  print('User: $msg2');
  print('Intent: ${res2.intent}');
  print('Message: ${res2.message}');
    if (res2.taskData != null) {
      print('Task: ${res2.taskData!.title}, Priority: ${res2.taskData!.priority}');
  }
}
