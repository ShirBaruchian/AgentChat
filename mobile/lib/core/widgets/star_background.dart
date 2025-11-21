import 'package:flutter/material.dart';

/// Reusable star background widget
class StarBackground extends StatelessWidget {
  final Widget child;
  final int starCount;

  const StarBackground({
    super.key,
    required this.child,
    this.starCount = 50,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StarBackgroundPainter(starCount: starCount),
      child: child,
    );
  }
}

class StarBackgroundPainter extends CustomPainter {
  final int starCount;

  StarBackgroundPainter({this.starCount = 50});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < starCount; i++) {
      final x = (i * 37.5) % size.width;
      final y = (i * 23.7) % size.height;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

