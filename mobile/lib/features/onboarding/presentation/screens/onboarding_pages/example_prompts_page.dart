import 'package:flutter/material.dart';

class ExamplePromptsPage extends StatefulWidget {
  final VoidCallback onContinue;
  
  const ExamplePromptsPage({super.key, required this.onContinue});

  @override
  State<ExamplePromptsPage> createState() => _ExamplePromptsPageState();
}

class _ExamplePromptsPageState extends State<ExamplePromptsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimations = List.generate(
      3,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.2,
            0.6 + (index * 0.2),
            curve: Curves.easeOut,
          ),
        ),
      ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Social Media Prompt
                _buildPromptCard(
                  animation: _fadeAnimations[0],
                  category: 'Social Media',
                  icon: Icons.chat_bubble_outline,
                  prompt: 'What trending topics can I tweet about?',
                  position: const Offset(-0.3, 0),
                ),
                const SizedBox(height: 40),
                // Work Prompt
                _buildPromptCard(
                  animation: _fadeAnimations[1],
                  category: 'Work',
                  icon: Icons.laptop,
                  prompt: 'Write a professional cover letter.',
                  position: const Offset(0.3, 0),
                ),
                const SizedBox(height: 40),
                // Communication Prompt
                _buildPromptCard(
                  animation: _fadeAnimations[2],
                  category: 'Communication',
                  icon: Icons.emoji_emotions,
                  prompt: 'Congratulate my friend on her birthday.',
                  position: const Offset(-0.2, 0),
                ),
                const Spacer(flex: 2),
                // Heading and Continue
                FadeTransition(
                  opacity: _fadeAnimations[2],
                  child: Column(
                    children: [
                      const Text(
                        'Get Help',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'with Any Task',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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

  Widget _buildPromptCard({
    required Animation<double> animation,
    required String category,
    required IconData icon,
    required String prompt,
    required Offset position,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: position,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF10B981),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: const Color(0xFF10B981), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                prompt,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
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


