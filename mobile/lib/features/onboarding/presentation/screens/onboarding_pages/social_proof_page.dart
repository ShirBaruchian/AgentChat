import 'package:flutter/material.dart';

class SocialProofPage extends StatefulWidget {
  final VoidCallback onContinue;
  
  const SocialProofPage({super.key, required this.onContinue});

  @override
  State<SocialProofPage> createState() => _SocialProofPageState();
}

class _SocialProofPageState extends State<SocialProofPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
          _buildGlobeBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top - 
                    MediaQuery.of(context).padding.bottom - 80,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Floating emoji reactions
                  FadeTransition(
                    opacity: _animationController,
                    child: SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 20,
                            left: 20,
                            child: _buildEmojiBubble('⭐⭐⭐⭐⭐', Colors.green),
                          ),
                          Positioned(
                            top: 40,
                            right: 30,
                            child: _buildEmojiBubble('❤️', Colors.red),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 40,
                            child: _buildEmojiBubble('👍', Colors.amber),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 20,
                            child: _buildEmojiBubble('⭐⭐⭐⭐⭐', Colors.green.shade700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Review Card
                  FadeTransition(
                    opacity: _animationController,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Perfect',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'It is amazing app for fun and useful generating content, creating great ideas! This AI chatbot saves me in sad evenings',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Heading and Continue
                  FadeTransition(
                    opacity: _animationController,
                    child: Column(
                      children: [
                        const Text(
                          'Join 60+ Million',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Happy Users',
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiBubble(String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _buildGlobeBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: GlobePainter(),
        child: Container(),
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

class GlobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 100);
    final radius = size.width * 0.4;

    // Draw globe grid
    final paint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i < 10; i++) {
      final y = center.dy - radius + (i * radius * 2 / 9);
      canvas.drawLine(
        Offset(center.dx - radius, y),
        Offset(center.dx + radius, y),
        paint,
      );
    }

    for (int i = 0; i < 10; i++) {
      final x = center.dx - radius + (i * radius * 2 / 9);
      canvas.drawLine(
        Offset(x, center.dy - radius),
        Offset(x, center.dy + radius),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

