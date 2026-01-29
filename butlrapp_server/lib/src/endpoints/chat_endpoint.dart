import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/ai_service.dart';

class ChatEndpoint extends Endpoint {
  
  /// Create a new chat session
  Future<ChatSession> createSession(Session session, String title) async {
    final newSession = ChatSession(
      title: title,
      createdAt: DateTime.now(),
    );
    await ChatSession.db.insertRow(session, newSession);
    return newSession;
  }

  /// Get all chat sessions
  Future<List<ChatSession>> getSessions(Session session) async {
    return await ChatSession.db.find(
      session,
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Delete a chat session
  Future<bool> deleteSession(Session session, int id) async {
    try {
      // First delete messages
      await ChatMessage.db.deleteWhere(session, where: (t) => t.chatSessionId.equals(id));
      // Then delete session
      await ChatSession.db.deleteWhere(session, where: (t) => t.id.equals(id));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Process an incoming message
  Future<ChatResponse> processMessage(Session session, String text, {int? sessionId}) async {
    try {
      // Manage Session
      int activeSessionId;
      if (sessionId == null) {
        // Create new session if none provided
        final title = text.length > 30 ? '${text.substring(0, 30)}...' : text;
        final newSession = ChatSession(
          title: title,
          createdAt: DateTime.now(),
        );
        final insertedSession = await ChatSession.db.insertRow(session, newSession);
        if (insertedSession.id == null) throw Exception('Failed to create session: ID is null');
        activeSessionId = insertedSession.id!;
      } else {
        activeSessionId = sessionId;
      }

      // Create user message
      final userMessage = ChatMessage(
        content: text,
        isUser: true,
        timestamp: DateTime.now(),
        chatSessionId: activeSessionId,
      );
      await ChatMessage.db.insertRow(session, userMessage);

      // Get recent history for context (last 10 messages from THIS session)
      final history = await getChatHistory(session, activeSessionId, limit: 10);
      
      // Use AI to understand the message
      // NOTE: Current AI implementation uses raw chat history which doesn't have session separation 
      // if we pass 'history' list.
      
      final aiService = _getAiService(session);
      // We pass the fetched history which is correctly filtered by session
      final aiResponse = await aiService.processMessage(text, session, history: history);

      // Save AI response with JSON metadata
      final botMessage = ChatMessage(
        content: aiResponse.message,
        isUser: false,
        timestamp: DateTime.now(),
        chatSessionId: activeSessionId,
        metadata: aiResponse.taskData != null ? jsonEncode(aiResponse.taskData!.toJson()) : null,
      );
      await ChatMessage.db.insertRow(session, botMessage);
      
      // Handle Intent (Task creation/listing)
      List<Task>? tasks;

      if (aiResponse.intent == TaskIntent.create && aiResponse.taskData != null) {
         final date = aiResponse.taskData!.dueDate ?? DateTime.now();
         DateTime dueAt = date;
         
         // Parse Time if available
         if (aiResponse.taskData!.dueTime != null) {
            print('DEBUG TIME: Raw dueTime=${aiResponse.taskData!.dueTime}');
            try {
              final parts = aiResponse.taskData!.dueTime!.split(':');
              if (parts.length == 2) {
                final hour = int.parse(parts[0]);
                final minute = int.parse(parts[1]);
                dueAt = DateTime(date.year, date.month, date.day, hour, minute);
                print('DEBUG TIME: Constructed dueAt=$dueAt isUtc=${dueAt.isUtc}');
              }
            } catch (e) {
              print('DEBUG TIME: Parsing failed: $e');
            }
          }
         
         print('DEBUG RECURRENCE: Raw=${aiResponse.taskData!.recurrence} Interval=${aiResponse.taskData!.recurrenceInterval}');
         
         final newTask = Task(
           title: aiResponse.taskData!.title,
           description: aiResponse.taskData!.description,
           completed: false,
           priority: aiResponse.taskData!.priority,
           dueAt: dueAt,
           createdAt: DateTime.now(),
           recurrence: aiResponse.taskData!.recurrence,
           recurrenceInterval: aiResponse.taskData!.recurrenceInterval,
         );
         
         await Task.db.insertRow(session, newTask);
         tasks = [newTask];
      } else if (aiResponse.intent == TaskIntent.list || aiResponse.intent == TaskIntent.query) {
         // Return upcoming tasks
         tasks = await Task.db.find(
           session,
           where: (t) => t.completed.equals(false), 
           orderBy: (t) => t.dueAt,
           limit: 5,
         );
      }

      return ChatResponse(
        message: aiResponse.message,
        intent: aiResponse.intent.name,
        tasks: tasks,
        sessionId: activeSessionId,
      );

    } catch (e) {
      session.log('Chat processing error: $e', level: LogLevel.error);
      return ChatResponse(
        message: "I'm having trouble processing that request. Please try again.",
        intent: 'error',
      );
    }
  }
  
  // Helper to get history for a specific session
  Future<List<ChatMessage>> getChatHistory(Session session, int sessionId, {int limit = 10}) async {
    // Get the LATEST {limit} messages
    final history = await ChatMessage.db.find(
      session,
      where: (t) => t.chatSessionId.equals(sessionId),
      orderBy: (t) => t.timestamp,
      orderDescending: true, // Get recent ones first
      limit: limit,
    );
    // Return them in chronological order
    return history.reversed.toList();
  }

  AIService _getAiService(Session session) {
    final apiKey = session.serverpod.getPassword('novitaApiKey') ?? 'sk_ibfw8oxL29xDBrz-qlHvEtbZAULOsu4qKz9sW1jCFL4';
    return AIService(apiKey);
  }
}
