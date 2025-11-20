import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../models/agent.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Agents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user?.email ?? 'User'}!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose an AI agent to start chatting',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          // Agent list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAgentCard(
                  context,
                  title: 'CEO Coach',
                  description: 'Get expert business advice and leadership guidance',
                  icon: Icons.business_center,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildAgentCard(
                  context,
                  title: 'Creative Writer',
                  description: 'Collaborate on stories, scripts, and creative projects',
                  icon: Icons.edit,
                  color: Colors.purple,
                ),
                const SizedBox(height: 12),
                _buildAgentCard(
                  context,
                  title: 'Tech Mentor',
                  description: 'Get help with programming and technical questions',
                  icon: Icons.code,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _buildAgentCard(
                  context,
                  title: 'Life Coach',
                  description: 'Personal development and life advice',
                  icon: Icons.favorite,
                  color: Colors.pink,
                ),
              ],
            ),
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
        icon: const Icon(Icons.add),
        label: const Text('New Chat'),
      ),
    );
  }

  Widget _buildAgentCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          final agent = Agent(
            id: title.toLowerCase().replaceAll(' ', '_'),
            name: title,
            description: description,
            icon: icon.toString(),
            color: color.value,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(agent: agent),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

