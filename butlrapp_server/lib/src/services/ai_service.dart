import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'package:intl/intl.dart';

/// AI Service for processing natural language task requests using Novita AI (OpenAI-compatible)
/// API docs: https://novita.ai/docs/api-reference/model-apis-llm-create-chat-completion
class AIService {
  final String _apiKey;
  // Official Novita OpenAI-compatible endpoint (v1)
  final String _baseUrl = 'https://api.novita.ai/openai/v1';
  final String _model = 'meta-llama/llama-3.1-8b-instruct';
  
  AIService(this._apiKey);

  /// Process user message and extract task intent and data
  Future<AIResponse> processMessage(String userMessage, Session session, {List<ChatMessage>? history}) async {
    try {
      final prompt = _buildPrompt(userMessage, history);
      
      final messages = <Map<String, String>>[
        {'role': 'system', 'content': 'You are Butlr, an AI task management assistant. Analyze the user\'s message and extract task information.'},
      ];

      // Add history if available
      if (history != null && history.isNotEmpty) {
        for (final msg in history) {
          messages.add({
            'role': msg.isUser ? 'user' : 'assistant',
            'content': msg.content,
          });
        }
      }

      // Add current message
      messages.add({'role': 'user', 'content': prompt});

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.2,
          'max_tokens': 1024, // Required by Novita API
        }),
      );

      if (response.statusCode != 200) {
        session.log('Novita AI API Error: ${response.statusCode} - ${response.body}', level: LogLevel.error);
        // Return user-friendly message for API errors (auth, rate limit, etc.)
        return AIResponse(
          intent: TaskIntent.unknown,
          message: "I'm having trouble connecting to the AI service. Please check that your API key is configured correctly and try again.",
          taskData: null,
        );
      }

      final data = jsonDecode(response.body);
      final messageObj = data['choices']?[0]?['message'];
      // Novita may return content as string or in reasoning_content for some models
      final responseText = (messageObj?['content'] ?? messageObj?['reasoning_content']) as String? ?? '';
      
      // Parse the AI response to extract task data and intent
      return _parseAIResponse(session, responseText, userMessage);
    } catch (e, stack) {
      session.log('AI Service Error: $e\n$stack', level: LogLevel.error);
      return AIResponse(
        intent: TaskIntent.unknown,
        message: "I encountered an error processing your request. Please try again.",
        taskData: null,
      );
    }
  }

  String _buildPrompt(String userMessage, List<ChatMessage>? history) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    
    return '''Current date: $today
Current time: ${DateFormat('HH:mm').format(now)}

User message: "$userMessage"

Respond in this EXACT JSON format:
{
  "intent": "create|list|update|delete|query|unknown",
  "message": "Your conversational response to the user",
  "task": {
    "title": "task title",
    "description": "optional description",
    "priority": "low|medium|high",
    "dueDate": "YYYY-MM-DD or null",
    "dueTime": "HH:mm or null",
    "recurrence": "daily|weekly|monthly|yearly|null",
    "recurrenceInterval": "integer (default 1)"
  }
}

Rules:
- THINK LIKE A HUMAN ASSISTANT. Infer intent from context even if vague.
- "tomorrow dentist" -> intent: create
- "anything for tomorrow?" -> intent: query
- "remind of it" -> use history to find "it" -> intent: create
- "do I have tasks?" -> intent: query
- "what are they?" -> intent: query

- IMPORTANT: Use chat history to resolve pronouns like "it", "that", "those".
- INFER priority intelligently:
    - Keywords like "medicine", "doctor", "urgent", "important", "deadline", "exam" -> HIGH priority.
    - Routine chores -> MEDIUM or LOW.
- RECURRENCE Parsing:
    - "every day" / "daily" -> recurrence: "daily"
    - "every week" -> recurrence: "weekly"
    - "every month" -> recurrence: "monthly"
- Parse relative dates: "tomorrow", "next week", "friday".
- Be conversational and friendly.
- CRITICAL FOR QUERIES: You do NOT have access to the user's database. When intent is 'query', DO NOT say "You have no tasks" or "You have 3 tasks". Just say "Here is your schedule:" or "Let me check that for you."

Return ONLY valid JSON, no markdown or extra text.''';
  }

  AIResponse _parseAIResponse(Session session, String responseText, String originalMessage) {
    try {
      // Clean up markdown code blocks if present
      String cleanText = responseText;
      if (cleanText.contains('```')) {
        cleanText = cleanText.replaceAll('```json', '').replaceAll('```', '').trim();
      }
      
      final data = jsonDecode(cleanText);
      
      final intentStr = data['intent'] as String? ?? 'unknown';
      final message = data['message'] as String? ?? 'Got it!';
      final taskMap = data['task'] as Map<String, dynamic>?;
      
      TaskIntent intent = TaskIntent.values.firstWhere(
        (e) => e.name == intentStr,
        orElse: () => TaskIntent.unknown,
      );

      TaskData? taskData;
      if (taskMap != null && (intent == TaskIntent.create || intent == TaskIntent.update)) {
        taskData = TaskData(
          title: taskMap['title'] as String? ?? '',
          description: taskMap['description'] as String?,
          priority: _parsePriority(taskMap['priority'] as String?),
          dueDate: _parseDate(taskMap['dueDate'] as String?),
          dueTime: taskMap['dueTime'] as String?,
          recurrence: taskMap['recurrence'] as String?,
          recurrenceInterval: taskMap['recurrenceInterval'] as int? ?? 1,
        );
      }

      return AIResponse(
        intent: intent,
        message: message,
        taskData: taskData,
      );
    } catch (e) {
      session.log('AI Response parsing error: $e', level: LogLevel.warning);
      return _fallbackParsing(originalMessage);
    }
  }

  AIResponse _fallbackParsing(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Improved fallback for queries
    if (lowerMessage.contains('tasks') || 
        lowerMessage.contains('schedule') || 
        lowerMessage.contains('do i have') ||
        (lowerMessage.contains('what') && lowerMessage.contains('doing'))) {
      return AIResponse(
        intent: TaskIntent.query,
        message: "Let me check your schedule.",
        taskData: null,
      );
    }

    return AIResponse(
      intent: TaskIntent.unknown,
      message: "I'm not sure what you'd like me to do. Try saying 'Remind me to...' or 'What are my tasks?'",
      taskData: null,
    );
  }

  TaskPriority _parsePriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr == 'null' || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}

/// AI Response structure
class AIResponse {
  final TaskIntent intent;
  final String message;
  final TaskData? taskData;

  AIResponse({
    required this.intent,
    required this.message,
    this.taskData,
  });
}

/// Task intent classification
enum TaskIntent {
  create,
  list,
  update,
  delete,
  query,
  unknown,
}

/// Extracted task data from AI
class TaskData {
  final String title;
  final String? description;
  final TaskPriority priority;
  final DateTime? dueDate;
  final String? dueTime;
  final String? recurrence;
  final int? recurrenceInterval;

  TaskData({
    required this.title,
    this.description,
    required this.priority,
    this.dueDate,
    this.dueTime,
    this.recurrence,
    this.recurrenceInterval,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime,
      'recurrence': recurrence,
      'recurrenceInterval': recurrenceInterval,
    };
  }

  factory TaskData.fromJson(Map<String, dynamic> json) {
    return TaskData(
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      dueTime: json['dueTime'] as String?,
      recurrence: json['recurrence'] as String?,
      recurrenceInterval: json['recurrenceInterval'] as int?,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
