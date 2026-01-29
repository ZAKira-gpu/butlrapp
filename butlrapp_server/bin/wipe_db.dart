import 'package:serverpod/serverpod.dart';
import 'package:butlrapp_server/src/generated/protocol.dart';

void main(List<String> args) async {
  final session = await InternalSession(
    enableLogging: true,
  );

  try {
    print('Deleting all tasks from database...');
    final deleted = await Task.db.deleteWhere(
      session,
      where: (t) => Constant.bool(true),
    );
    print('Deleted ${deleted.length} tasks.');
    
    print('Deleting all chat messages from database...');
    final deletedChat = await ChatMessage.db.deleteWhere(
      session,
      where: (t) => Constant.bool(true),
    );
    print('Deleted ${deletedChat.length} chat messages.');
    
  } catch (e) {
    print('Error: $e');
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
