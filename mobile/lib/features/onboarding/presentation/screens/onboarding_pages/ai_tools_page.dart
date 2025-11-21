import 'package:flutter/material.dart';

class AIToolsPage extends StatefulWidget {
  final VoidCallback onContinue;
  
  const AIToolsPage({super.key, required this.onContinue});

  @override
  State<AIToolsPage> createState() => _AIToolsPageState();
}

class _AIToolsPageState extends State<AIToolsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _tools = [
    {
      'title': 'Image Generation',
      'icon': Icons.image,
      'color': Colors.purple,
      'gradient': [Colors.purple, Colors.pink],
    },
    {
      'title': 'Ask the Web',
      'icon': Icons.search,
      'color': const Color(0xFF10B981),
      'gradient': [const Color(0xFF10B981), Colors.green],
    },
    {
      'title': 'Doc Master',
      'icon': Icons.description,
      'color': Colors.blue,
      'gradient': [Colors.blue, Colors.cyan],
    },
    {
      'title': 'YouTube Summary',
      'icon': Icons.play_circle,
      'color': Colors.red,
      'gradient': [Colors.red, Colors.orange],
    },
    {
      'title': 'AI Smart Keyboard',
      'icon': Icons.keyboard,
      'color': Colors.purple,
      'gradient': [Colors.purple, Colors.indigo],
    },
    {
      'title': 'More Tools',
      'icon': Icons.more_horiz,
      'color': Colors.grey,
      'gradient': [Colors.grey, Colors.grey.shade700],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF1A1A1A),
          ],
        ),
      ),
      child: Stack(
        children: [
          _buildStarBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Tools Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _tools.length,
                  itemBuilder: (context, index) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: _buildToolCard(_tools[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Heading and Continue
                FadeTransition(
                  opacity: _animationController,
                  child: Column(
                    children: [
                      const Text(
                        'Great Variety of AI Tools',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(Map<String, dynamic> tool) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: (tool['gradient'] as List<Color>)
              .map((c) => c.withOpacity(0.2))
              .toList(),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (tool['color'] as Color).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (tool['color'] as Color).withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tool['icon'] as IconData,
              color: tool['color'] as Color,
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tool['title'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
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

