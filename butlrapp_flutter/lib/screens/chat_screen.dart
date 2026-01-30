import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:butlrapp_client/butlrapp_client.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main.dart';
// import 'package:butlr/models/message.dart'; // We'll need to define this or use client models
// import 'package:butlr/services/ai_service.dart'; // To be implemented
// import 'package:butlr/services/task_service.dart'; // To be implemented
import '../../widgets/task_bubble.dart';
import '../../widgets/custom_drawer.dart';
import '../services/task_service.dart';
// import 'package:butlr/screens/settings_screen.dart'; // To be implemented

// Mocks removed - using real Serverpod client

enum MessageSender { user, ai }
enum MessageType { text, taskConfirmation, taskList, planSuggestion }

class Message {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final MessageType type;
  final List<Task>? relatedTasks;

  Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.type = MessageType.text,
    this.relatedTasks,
  });
}

class ChatScreen extends StatefulWidget {
  final int? sessionId;
  const ChatScreen({super.key, this.sessionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController(); 
  final ScrollController _scrollController = ScrollController();
  
  // Dependencies
  // We use the global 'client' defined in main.dart
  
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechReady = false;
  bool _isListening = false;
  String _lastCommitted = '';

  final List<Message> _messages = [];
  bool _isTyping = false;
  int? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _currentSessionId = widget.sessionId;
    
    if (_currentSessionId != null) {
      _loadChatHistory();
    } else {
      // Initial Greeting for new chat
      _messages.add(Message(
        id: 'init',
        text: "Hello, I'm Butlr. I can help you manage your tasks. Try saying 'Remind me to call Mom tomorrow'.",
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        type: MessageType.text,
      ));
    }
  }

  Future<void> _loadChatHistory() async {
    setState(() {
      _isTyping = true;
      _messages.clear();
    });

    try {
      final history = await client.chat.getChatHistory(_currentSessionId!, limit: 50);
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.addAll(history.map((m) {
            final metadata = m.metadata;
            List<Task>? tasks;
            MessageType type = MessageType.text;

            if (metadata != null && metadata.isNotEmpty) {
              try {
                final data = jsonDecode(metadata);
                // Simple heuristic: if it looks like TaskData, it's a confirmation
                if (data['title'] != null) {
                   tasks = [_mapMetadataToTask(data)];
                   type = MessageSender.ai == (m.isUser ? MessageSender.user : MessageSender.ai) 
                       ? MessageType.taskConfirmation : MessageType.text;
                   // Wait, if it has metadata but isn't user, it's likely a confirmation or list
                   if (!m.isUser) type = MessageType.taskConfirmation;
                }
              } catch (_) {}
            }

            return Message(
              id: m.id.toString(),
              text: m.content,
              sender: m.isUser ? MessageSender.user : MessageSender.ai,
              timestamp: m.timestamp,
              type: type,
              relatedTasks: tasks,
            );
          }));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    SystemSound.play(SystemSoundType.click);

    setState(() {
      _messages.add(Message(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
        type: MessageType.text,
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    // AI Processing via Serverpod
    try {
      final response = await client.chat.processMessage(text, sessionId: _currentSessionId);
      
      if (mounted) {
        setState(() {
          _currentSessionId = response.sessionId; // Update with new session ID if it was created
          _isTyping = false;
          _messages.add(Message(
            id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
            text: response.message,
            sender: MessageSender.ai,
            timestamp: DateTime.now(),
            type: _mapIntentToMessageType(response.intent),
            relatedTasks: response.tasks,
          ));
        });
        
        // Refresh tasks if something might have changed
        if (response.intent != 'unknown' && response.intent != 'error') {
          await TaskService().refreshTasks();
        }

        // Specifically for queries, we want to SHOW the tasks in the chat
        if (response.intent == 'query' || response.intent == 'list') {
           final tasks = TaskService().tasks.where((t) => !t.completed).take(5).toList();
           
           if (tasks.isNotEmpty) {
             setState(() {
                final lastMsgIndex = _messages.length - 1;
                _messages[lastMsgIndex] = Message(
                  id: _messages[lastMsgIndex].id,
                  text: _messages[lastMsgIndex].text,
                  sender: _messages[lastMsgIndex].sender,
                  timestamp: _messages[lastMsgIndex].timestamp,
                  type: MessageType.taskList,
                  relatedTasks: tasks,
                );
             });
           }
        }
        
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(Message(
            id: 'err_${DateTime.now().millisecondsSinceEpoch}',
            text: "I'm having trouble connecting to my brain. Is the server running?",
            sender: MessageSender.ai,
            timestamp: DateTime.now(),
            type: MessageType.text,
          ));
        });
        _scrollToBottom();
      }
    }
  }

  MessageType _mapIntentToMessageType(String intent) {
    switch (intent) {
      case 'create':
        return MessageType.taskConfirmation;
      case 'list':
      case 'query':
        return MessageType.taskList;
      default:
        return MessageType.text;
    }
  }

  Task _mapMetadataToTask(Map<String, dynamic> data) {
    return Task(
      title: data['title'] ?? 'Untitled Task',
      description: data['description'],
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueAt: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
      completed: false,
      createdAt: DateTime.now(),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _listen() async {
    if (_isTyping) return;

    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    if (!_speechReady) {
      _speechReady = await _speech.initialize(
        onError: (e) {
          if (mounted) {
            setState(() => _isListening = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Speech error: ${e.errorMsg}')),
            );
          }
        },
        onStatus: (status) {
          if (mounted && status == 'notListening' && _isListening) {
            setState(() => _isListening = false);
          }
        },
      );
      if (!_speechReady && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available. Check mic permission.'),
          ),
        );
        return;
      }
    }

    _lastCommitted = _controller.text;
    setState(() => _isListening = true);

    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        final text = result.recognizedWords;
        if (text.isEmpty) return;
        final base = _lastCommitted.isEmpty ? '' : '$_lastCommitted ';
        if (result.finalResult) {
          _lastCommitted = base + text;
          _controller.text = _lastCommitted;
        } else {
          _controller.text = base + text;
        }
        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
        setState(() {});
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  void _resetChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF313A64)),
            SizedBox(width: 12),
            Text('New Chat'),
          ],
        ),
        content: const Text(
          'Start a new conversation? Your current chat will be saved to history.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentSessionId = null; // Clear session for new chat
                _messages.clear();
                _messages.add(Message(
                  id: 'init_${DateTime.now().millisecondsSinceEpoch}',
                  text: "Hello! I'm Butlr. How can I help you today?",
                  sender: MessageSender.ai,
                  timestamp: DateTime.now(),
                  type: MessageType.text,
                ));
              });
              _scrollToBottom();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF313A64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('New Chat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: SvgPicture.asset('assets/nav.svg', width: 28, height: 28),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 28),
                    onPressed: _resetChat,
                  ),
                  const Spacer(),
                  
                ],
              ),
            ),
            
            // Chat List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageItem(message);
                },
              ),
            ),
            
            // Input Area
            if (_isTyping)
               Padding(
                 padding: const EdgeInsets.only(left: 24, bottom: 8),
                 child: Align(
                   alignment: Alignment.centerLeft,
                   child: Text('Butlr is thinking...', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                 ),
               ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(Message message) {
    final isUser = message.sender == MessageSender.user;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF313A64) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: isUser ? const Radius.circular(24) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF2D3142),
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (!isUser && message.relatedTasks != null && message.relatedTasks!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...message.relatedTasks!.map((task) => Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TaskBubble(task: task),
                    )),
                  ],
                ],
              ),
            ),
        ],
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Talk and ask to butlr...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        filled: false,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none, 
                      color: _isListening ? Colors.red : Colors.blueGrey[700], 
                      size: 26
                    ),
                    onPressed: _listen, 
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: SvgPicture.asset(
              'assets/send.svg',
              width: 52,
              height: 52,
            ),
          ),
        ],
      ),
    );
  }
}
