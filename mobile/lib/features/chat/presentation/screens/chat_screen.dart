import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../../../models/message.dart';
import '../../../../models/agent.dart';
import '../../../../models/ai_provider.dart';
import '../../../../models/provider_agent.dart';
import '../../../../services/api_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/usage_service.dart';
import '../../../../services/subscription_service.dart';
import '../../../../core/widgets/message_bubble.dart';
import '../../../../core/widgets/typing_indicator.dart';
import '../../../../core/widgets/agent_dropdown.dart';
import '../../../../core/widgets/star_background.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../subscription/presentation/screens/subscription_screen.dart';

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

    // Note: Token check and consumption happens on the backend
    // We'll sync token status after the message is sent
    // Frontend check is just for UX (showing warning before sending)
    final usageService = context.read<UsageService>();
    final subscriptionService = context.read<SubscriptionService>();
    
    // Show warning if tokens are low (but still allow sending - backend will enforce)
    if (!subscriptionService.isPremiumActive && !usageService.hasTokensRemaining) {
      _showTokenExhaustedDialog(context);
      return;
    }
    
    // Get user ID (Firebase Anonymous Auth provides this automatically)
    final userId = await usageService.getUserId();

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
      
      // Sync token status with backend after successful message
      final usageService = Provider.of<UsageService>(context, listen: false);
      await usageService.syncWithBackend();
    } catch (e) {
      setState(() {
        _isTyping = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      
      // Check if it's a token exhaustion error
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('token') || errorStr.contains('429')) {
        // Sync with backend to get latest token status
        final usageService = context.read<UsageService>();
        await usageService.syncWithBackend();
        
        // Show token exhaustion dialog
        _showTokenExhaustedDialog(context);
      } else {
        // Show error message to user
        _addMessage(
          'Sorry, I encountered an error: $_errorMessage. Please try again.',
          isUser: false,
        );
        
        // Also show snackbar
        _showError(_errorMessage ?? 'Failed to send message');
      }
    }
  }
  
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
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
    final usageService = context.watch<UsageService>();
    final subscriptionService = context.watch<SubscriptionService>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: Row(
          children: [
            AvatarWidget(
              icon: IconHelper.getAgentIcon(widget.agent?.name),
              color: agentColor,
              size: AppConstants.avatarSizeL,
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    agentName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.agent != null)
                    Text(
                      widget.agent!.description,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Token count (if not premium)
          if (!subscriptionService.isPremiumActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingS),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                  vertical: AppConstants.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: usageService.hasTokensRemaining
                      ? AppTheme.primaryColor.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
                  border: Border.all(
                    color: usageService.hasTokensRemaining
                        ? AppTheme.primaryColor
                        : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt,
                      color: usageService.hasTokensRemaining
                          ? AppTheme.primaryColor
                          : Colors.orange,
                      size: AppConstants.iconSizeS,
                    ),
                    const SizedBox(width: AppConstants.spacingXS),
                    Text(
                      '${usageService.tokensRemaining}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: usageService.hasTokensRemaining
                            ? AppTheme.primaryColor
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Agent dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingS),
            child: AgentDropdown(
              selectedAgent: _selectedAgent,
              allAgents: _allAgents,
              isLoading: _isLoadingProviderAgents,
              onChanged: (agent) {
                setState(() {
                  _selectedAgent = agent;
                });
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Star background
          StarBackground(
            child: Container(),
          ),
          Column(
            children: [
              // Messages list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(
                    left: AppConstants.spacingL,
                    right: AppConstants.spacingL,
                    top: AppConstants.spacingS,
                    bottom: AppConstants.spacingS,
                  ),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      // Typing indicator
                      return TypingIndicator(
                        agentColor: agentColor,
                        agentIcon: IconHelper.getAgentIcon(widget.agent?.name),
                      );
                    }
                    return MessageBubble(
                      message: _messages[index],
                      agentColor: agentColor,
                      agentIcon: IconHelper.getAgentIcon(widget.agent?.name),
                    );
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
                    padding: const EdgeInsets.all(AppConstants.spacingS),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: AppTextStyles.caption.copyWith(
                                color: Colors.white.withOpacity(0.5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[800],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spacingXL,
                                vertical: 10,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingS),
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

  void _showTokenExhaustedDialog(BuildContext context) {
    // Navigate directly to subscription screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SubscriptionScreen(),
      ),
    );
  }
}


