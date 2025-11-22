import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Celtic knot logo widget - uses image asset if available, otherwise draws programmatically
class CelticKnotLogo extends StatelessWidget {
  final double size;
  final Color color;
  
  const CelticKnotLogo({
    super.key,
    this.size = 120,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // Try to load image asset first, fallback to custom painter
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/celtic_knot_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to custom painter if image not found
          return CustomPaint(
            painter: CelticKnotPainter(color: color),
          );
        },
      ),
    );
  }
}

class CelticKnotPainter extends CustomPainter {
  final Color color;
  
  CelticKnotPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.42;
    final middleRadius = size.width * 0.25;
    final innerRadius = size.width * 0.12;
    
    // Draw the complete interlacing knot pattern
    // This creates a 6-fold symmetric Celtic knot with outer lobes, inner loops, and central star
    
    // Draw 6 outer lobes (shield/heart shapes pointing outward)
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6;
      final lobeCenter = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      
      // Create outer lobe path (heart/shield shape)
      final lobePath = Path();
      final lobeSize = size.width * 0.18;
      
      // Draw the outer curve of the lobe
      final rect = Rect.fromCenter(
        center: lobeCenter,
        width: lobeSize,
        height: lobeSize * 1.2,
      );
      
      // Create a heart-like shape pointing outward
      lobePath.moveTo(
        lobeCenter.dx,
        lobeCenter.dy - lobeSize * 0.6,
      );
      
      // Left curve
      lobePath.cubicTo(
        lobeCenter.dx - lobeSize * 0.3,
        lobeCenter.dy - lobeSize * 0.3,
        lobeCenter.dx - lobeSize * 0.5,
        lobeCenter.dy + lobeSize * 0.2,
        lobeCenter.dx - lobeSize * 0.2,
        lobeCenter.dy + lobeSize * 0.6,
      );
      
      // Bottom point
      lobePath.lineTo(lobeCenter.dx, lobeCenter.dy + lobeSize * 0.7);
      
      // Right curve
      lobePath.cubicTo(
        lobeCenter.dx + lobeSize * 0.2,
        lobeCenter.dy + lobeSize * 0.6,
        lobeCenter.dx + lobeSize * 0.5,
        lobeCenter.dy + lobeSize * 0.2,
        lobeCenter.dx + lobeSize * 0.3,
        lobeCenter.dy - lobeSize * 0.3,
      );
      
      lobePath.close();
      
      canvas.drawPath(lobePath, paint);
    }
    
    // Draw 6 inner loops (teardrop/heart shapes around center)
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6 + math.pi / 6;
      final loopCenter = Offset(
        center.dx + middleRadius * math.cos(angle),
        center.dy + middleRadius * math.sin(angle),
      );
      
      // Draw inner loop (teardrop shape)
      final loopPath = Path();
      final loopSize = size.width * 0.1;
      
      loopPath.addOval(
        Rect.fromCenter(
          center: loopCenter,
          width: loopSize,
          height: loopSize * 1.3,
        ),
      );
      
      canvas.drawPath(loopPath, paint);
    }
    
    // Draw central 6-pointed star/pinwheel
    final starPath = Path();
    final starRadius = size.width * 0.08;
    
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6 - math.pi / 2;
      final x = center.dx + starRadius * math.cos(angle);
      final y = center.dy + starRadius * math.sin(angle);
      
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();
    
    canvas.drawPath(starPath, paint);
    
    // Draw connecting/interlacing lines between elements
    final connectorPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04;
    
    // Connect outer lobes to inner loops
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6;
      final outerPoint = Offset(
        center.dx + (outerRadius - size.width * 0.1) * math.cos(angle),
        center.dy + (outerRadius - size.width * 0.1) * math.sin(angle),
      );
      
      final innerAngle = angle + math.pi / 6;
      final innerPoint = Offset(
        center.dx + (middleRadius + size.width * 0.05) * math.cos(innerAngle),
        center.dy + (middleRadius + size.width * 0.05) * math.sin(innerAngle),
      );
      
      final connectorPath = Path();
      connectorPath.moveTo(outerPoint.dx, outerPoint.dy);
      connectorPath.quadraticBezierTo(
        center.dx + (outerRadius * 0.6) * math.cos(angle + math.pi / 12),
        center.dy + (outerRadius * 0.6) * math.sin(angle + math.pi / 12),
        innerPoint.dx,
        innerPoint.dy,
      );
      
      canvas.drawPath(connectorPath, connectorPaint);
    }
    
    // Connect inner loops to center
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6 + math.pi / 6;
      final loopPoint = Offset(
        center.dx + (middleRadius - size.width * 0.05) * math.cos(angle),
        center.dy + (middleRadius - size.width * 0.05) * math.sin(angle),
      );
      
      final connectorPath = Path();
      connectorPath.moveTo(loopPoint.dx, loopPoint.dy);
      connectorPath.lineTo(center.dx, center.dy);
      
      canvas.drawPath(connectorPath, connectorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
