import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/api_service.dart';
import '../../../../models/agent.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiService _apiService = ApiService();
  List<Agent> _agents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    // Only show loading indicator if we don't have any agents yet
    if (_agents.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Always fetch fresh agents from the backend
      final agents = await _apiService.getAgents();
      setState(() {
        _agents = agents;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
      
      // Show error snackbar only if we don't have cached agents
      if (mounted && _agents.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load agents: $_errorMessage'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadAgents,
            ),
          ),
        );
      } else if (mounted) {
        // If we have cached agents, show a less intrusive error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh agents: $_errorMessage'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: const Text(
          'AI Agents',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () {
              // Navigate to settings
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () async {
              await authService.signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Star background
          _buildStarBackground(),
          Column(
            children: [
              // Welcome banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF10B981).withOpacity(0.2),
                      const Color(0xFF6366F1).withOpacity(0.2),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user?.email?.split('@')[0] ?? 'User'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose an AI agent to start chatting',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Agent list
              Expanded(
                child: _isLoading && _agents.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF10B981),
                        ),
                      )
                    : _errorMessage != null && _agents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                const Text(
                                  'Failed to load agents',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _errorMessage ?? 'Unknown error',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadAgents,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _agents.isEmpty
                            ? RefreshIndicator(
                                onRefresh: _loadAgents,
                                color: const Color(0xFF10B981),
                                child: SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.6,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'No agents available',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Pull down to refresh',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadAgents,
                                color: const Color(0xFF10B981),
                                child: ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _agents.length,
                                  itemBuilder: (context, index) {
                                    final agent = _agents[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: index < _agents.length - 1 ? 12 : 0,
                                      ),
                                      child: _buildAgentCardFromModel(context, agent),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Open chat without specific agent
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Chat',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStarBackground() {
    return CustomPaint(
      painter: StarBackgroundPainter(),
      child: Container(),
    );
  }

  Widget _buildAgentCardFromModel(BuildContext context, Agent agent) {
    // Parse icon from string (e.g., "Icons.business_center")
    IconData iconData = _parseIcon(agent.icon ?? 'Icons.chat_bubble_outline');
    Color color = Color(agent.color ?? 0xFF10B981);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(agent: agent),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.3),
                        color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Icon(iconData, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        agent.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _parseIcon(String iconString) {
    // Map icon strings to actual IconData
    final iconMap = {
      'Icons.business_center': Icons.business_center,
      'Icons.edit': Icons.edit,
      'Icons.code': Icons.code,
      'Icons.favorite': Icons.favorite,
      'Icons.chat_bubble_outline': Icons.chat_bubble_outline,
    };
    return iconMap[iconString] ?? Icons.chat_bubble_outline;
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

