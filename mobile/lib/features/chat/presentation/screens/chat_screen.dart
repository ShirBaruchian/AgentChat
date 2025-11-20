import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/message.dart';
import '../../../../models/agent.dart';

class ChatScreen extends StatefulWidget {
  final Agent? agent;

  const ChatScreen({
    super.key,
    this.agent,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isTyping = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Add welcome message
    if (widget.agent != null) {
      _addMessage(
        'Hello! I\'m ${widget.agent!.name}. ${widget.agent!.description}. How can I help you today?',
        isUser: false,
      );
    } else {
      _addMessage(
        'Hello! I\'m your AI assistant. How can I help you today?',
        isUser: false,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _messages.add(Message(
        id: _uuid.v4(),
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
        agentId: widget.agent?.id,
      ));
    });
    _scrollToBottom();
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    _addMessage(text, isUser: true);
    _messageController.clear();

    // Show typing indicator
    setState(() => _isTyping = true);
    _scrollToBottom();

    // Simulate AI response (replace with actual API call later)
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isTyping = false);

    // Generate mock response based on agent or generic
    String response;
    if (widget.agent != null) {
      response = _generateAgentResponse(text, widget.agent!.name);
    } else {
      response = _generateGenericResponse(text);
    }

    _addMessage(response, isUser: false);
  }

  String _generateAgentResponse(String userMessage, String agentName) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (agentName == 'CEO Coach') {
      if (lowerMessage.contains('leadership') || lowerMessage.contains('team')) {
        return 'Great question! Effective leadership starts with clear communication and setting a vision. What specific leadership challenge are you facing?';
      } else if (lowerMessage.contains('strategy') || lowerMessage.contains('business')) {
        return 'Strategy is about making choices. What business goal are you trying to achieve? I can help you think through the options.';
      }
      return 'That\'s an interesting point. As a CEO coach, I\'d like to understand more about your situation. Can you tell me more about the context?';
    } else if (agentName == 'Creative Writer') {
      if (lowerMessage.contains('story') || lowerMessage.contains('character')) {
        return 'I love working on stories! What genre are you thinking? Let\'s develop some compelling characters together.';
      } else if (lowerMessage.contains('dialogue') || lowerMessage.contains('script')) {
        return 'Dialogue is one of my favorite elements! Good dialogue reveals character and advances the plot. What scene are you working on?';
      }
      return 'Creative writing is all about imagination and craft. What project are you working on? I\'d be happy to help you develop it!';
    } else if (agentName == 'Tech Mentor') {
      if (lowerMessage.contains('code') || lowerMessage.contains('programming')) {
        return 'Programming is both an art and a science! What technology or language are you working with? I can help you think through the problem.';
      } else if (lowerMessage.contains('bug') || lowerMessage.contains('error')) {
        return 'Debugging can be frustrating! Let\'s break down the problem. What error message are you seeing, and what were you trying to do?';
      }
      return 'Technology is constantly evolving! What technical challenge are you facing? I\'m here to help you learn and solve problems.';
    } else if (agentName == 'Life Coach') {
      if (lowerMessage.contains('goal') || lowerMessage.contains('achieve')) {
        return 'Setting and achieving goals is powerful! What goal are you working towards? Let\'s create an action plan together.';
      } else if (lowerMessage.contains('motivation') || lowerMessage.contains('stuck')) {
        return 'Feeling stuck is normal. Let\'s explore what might be holding you back. What would success look like for you?';
      }
      return 'I\'m here to support your personal growth! What area of your life would you like to work on? Let\'s explore it together.';
    }
    
    return _generateGenericResponse(userMessage);
  }

  String _generateGenericResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! How can I assist you today?';
    } else if (lowerMessage.contains('help')) {
      return 'I\'m here to help! What would you like to know or discuss?';
    } else if (lowerMessage.contains('thank')) {
      return 'You\'re welcome! Is there anything else I can help you with?';
    } else if (lowerMessage.contains('bye') || lowerMessage.contains('goodbye')) {
      return 'Goodbye! Feel free to come back anytime if you need assistance.';
    }
    
    return 'That\'s interesting! Can you tell me more about that? I\'d like to understand better so I can help you.';
  }

  @override
  Widget build(BuildContext context) {
    final agentName = widget.agent?.name ?? 'AI Assistant';
    final agentColor = widget.agent != null 
        ? Color(widget.agent!.color) 
        : Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: agentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getAgentIcon(widget.agent?.name),
                color: agentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    agentName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (widget.agent != null)
                    Text(
                      widget.agent!.description,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  // Typing indicator
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index], agentColor);
              },
            ),
          ),
          
          // Input area
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: agentColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.send, color: Colors.white),
                        tooltip: 'Send',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, Color agentColor) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: agentColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getAgentIcon(widget.agent?.name),
                color: agentColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? agentColor
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : null,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getAgentIcon(widget.agent?.name),
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animatedValue = ((value + delay) % 1.0);
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3 + (animatedValue * 0.4)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  IconData _getAgentIcon(String? agentName) {
    switch (agentName) {
      case 'CEO Coach':
        return Icons.business_center;
      case 'Creative Writer':
        return Icons.edit;
      case 'Tech Mentor':
        return Icons.code;
      case 'Life Coach':
        return Icons.favorite;
      default:
        return Icons.chat_bubble_outline;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

