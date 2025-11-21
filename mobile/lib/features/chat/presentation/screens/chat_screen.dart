import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../../../models/message.dart';
import '../../../../models/agent.dart';
import '../../../../models/ai_provider.dart';
import '../../../../models/provider_agent.dart';
import '../../../../services/api_service.dart';
import '../../../../services/auth_service.dart';

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
  late final ApiService _apiService;
  String? _errorMessage;
  ProviderAgent? _selectedAgent;
  List<ProviderAgent> _allAgents = []; // All available agents from all providers
  bool _isLoadingProviderAgents = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    // Load provider agents from API
    _loadProviderAgents();
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

  /// Load provider agents from the API service
  Future<void> _loadProviderAgents() async {
    setState(() {
      _isLoadingProviderAgents = true;
    });

    try {
      // Fetch all provider agents from the API
      final agents = await _apiService.getProviderAgents();
      
      // Set all agents and select the first one (or auto if available)
      setState(() {
        _allAgents = agents;
        // Select auto agent if available, otherwise select the first one
        _selectedAgent = agents.firstWhere(
          (agent) => agent.id == 'auto' || agent.isDefault,
          orElse: () => agents.isNotEmpty ? agents.first : ProviderAgent(
            id: 'auto',
            name: 'Auto Select',
            description: 'Automatically chooses the best model',
            provider: AIProvider.auto,
            modelId: 'auto',
            isDefault: true,
          ),
        );
        _isLoadingProviderAgents = false;
      });
    } catch (e) {
      print('Failed to load provider agents from API: $e');
      // Fall back to hardcoded agents if API fails
      final fallbackAgents = ProviderAgent.getDefaultAgents();
      setState(() {
        _allAgents = fallbackAgents;
        _selectedAgent = fallbackAgents.firstWhere(
          (agent) => agent.id == 'auto' || agent.isDefault,
          orElse: () => fallbackAgents.first,
        );
        _isLoadingProviderAgents = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  void _addMessage(String text, {required bool isUser, String? provider, String? modelId}) {
    setState(() {
      _messages.add(Message(
        id: _uuid.v4(),
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
        agentId: widget.agent?.id,
        provider: provider,
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

    // Get current user
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    
    if (user == null) {
      _showError('Please sign in to send messages');
      return;
    }
    
    // Get user ID (works with both MockUser and Firebase User)
    final userId = user.uid;

    // Add user message
    _addMessage(text, isUser: true);
    _messageController.clear();

    // Show typing indicator
    setState(() {
      _isTyping = true;
      _errorMessage = null;
    });
    _scrollToBottom();

    try {
      // Get agent ID (use default if no agent selected)
      final agentId = widget.agent?.id ?? 'default';
      
      // Build conversation history for context
      final conversationHistory = _messages
          .where((m) => m.agentId == agentId)
          .take(10)
          .map((m) => m.isUser
              ? {'user_message': m.text}
              : {'response': m.text})
          .toList();

      // Call backend API
      final modelId = _selectedAgent?.modelId ?? 'auto';
      final provider = _selectedAgent?.provider != null ? _selectedAgent!.provider : null;
      final response = await _apiService.sendMessage(
        userId: userId,
        agentId: agentId,
        message: text,
        conversationHistory: conversationHistory,
        provider: provider,
        modelId: modelId,
      );

      setState(() => _isTyping = false);
      _addMessage(
        response,
        isUser: false,
        provider: _selectedAgent?.provider != null ? _selectedAgent!.provider.apiValue : null,
        modelId: _selectedAgent?.modelId,
      );
    } catch (e) {
      setState(() {
        _isTyping = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      
      // Show error message to user
      _addMessage(
        'Sorry, I encountered an error: $_errorMessage. Please try again.',
        isUser: false,
      );
      
      // Also show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Failed to send message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final agentName = widget.agent?.name ?? 'AI Assistant';
    final agentColor = widget.agent != null && widget.agent!.color != null
        ? Color(widget.agent!.color!)
        : const Color(0xFF10B981);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    agentColor.withOpacity(0.3),
                    agentColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: agentColor.withOpacity(0.5),
                  width: 1,
                ),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (widget.agent != null)
                    Text(
                      widget.agent!.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Agent dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildAgentDropdown(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Star background
          _buildStarBackground(),
          Column(
            children: [
              // Messages list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 8,
                    // Add padding if provider selector is visible
                  ),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      // Typing indicator
                      return _buildTypingIndicator(agentColor);
                    }
                    return _buildMessageBubble(_messages[index], agentColor);
                  },
                ),
              ),
              
              // Input area
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
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
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[800],
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
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                agentColor,
                                agentColor.withOpacity(0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: agentColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
        ],
      ),
    );
  }

  Widget _buildStarBackground() {
    return CustomPaint(
      painter: StarBackgroundPainter(),
      child: Container(),
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    agentColor.withOpacity(0.3),
                    agentColor.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: agentColor.withOpacity(0.5),
                  width: 1,
                ),
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
                gradient: isUser
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          agentColor,
                          agentColor.withOpacity(0.8),
                        ],
                      )
                    : null,
                color: isUser ? null : Colors.grey[900],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        width: 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? agentColor.withOpacity(0.3)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: 8,
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
                      color: isUser ? Colors.white : Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: isUser
                              ? Colors.white.withOpacity(0.7)
                              : Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                      if (!isUser && message.provider != null) ...[
                        const SizedBox(width: 8),
                        Builder(
                          builder: (context) {
                            final provider = aiProviderFromString(message.provider!);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(provider.color).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Color(provider.color).withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                provider.icon,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[700]!,
                    Colors.grey[800]!,
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey[600]!.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(Color agentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  agentColor.withOpacity(0.3),
                  agentColor.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: agentColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Icon(
              _getAgentIcon(widget.agent?.name),
              color: agentColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0, agentColor),
                const SizedBox(width: 4),
                _buildTypingDot(1, agentColor),
                const SizedBox(width: 4),
                _buildTypingDot(2, agentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index, Color agentColor) {
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
            color: agentColor.withOpacity(0.3 + (animatedValue * 0.5)),
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

  Widget _buildAgentDropdown() {
    if (_isLoadingProviderAgents || _allAgents.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white70,
          ),
        ),
      );
    }

    final selectedAgent = _selectedAgent ?? _allAgents.first;
    final providerColor = Color(selectedAgent.provider.color);

    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: providerColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: providerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: DropdownButton<ProviderAgent>(
        value: selectedAgent,
        isDense: true,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: Icon(Icons.arrow_drop_down, color: providerColor, size: 18),
        dropdownColor: Colors.grey[900],
        menuMaxHeight: 400,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        items: _allAgents.map((agent) {
          final agentProviderColor = Color(agent.provider.color);
          final isSelected = agent.id == selectedAgent.id;
          return DropdownMenuItem<ProviderAgent>(
            value: agent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: agentProviderColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: agentProviderColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        agent.provider.icon,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          agent.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          agent.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.check_circle,
                      color: agentProviderColor,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (ProviderAgent? newAgent) {
          if (newAgent != null) {
            setState(() {
              _selectedAgent = newAgent;
            });
          }
        },
        selectedItemBuilder: (BuildContext context) {
          return _allAgents.map((agent) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    agent.provider.icon,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      agent.name,
                      style: TextStyle(
                        color: providerColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
      ),
    );
  }
}

class StarBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = (i * 37.5) % size.width;
      final y = (i * 23.7) % size.height;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

