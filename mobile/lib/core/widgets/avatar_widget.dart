import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Reusable avatar widget
class AvatarWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool showBorder;

  const AvatarWidget({
    super.key,
    required this.icon,
    required this.color,
    this.size = AppConstants.avatarSizeM,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: color.withOpacity(0.5),
                width: 1,
              )
            : null,
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.56, // Icon is ~56% of avatar size
      ),
    );
  }
}

