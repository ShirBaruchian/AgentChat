/// Application-wide constants
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircular = 999.0;

  // Icon Sizes
  static const double iconSizeXS = 12.0;
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 20.0;
  static const double iconSizeL = 24.0;
  static const double iconSizeXL = 32.0;

  // Avatar Sizes
  static const double avatarSizeS = 24.0;
  static const double avatarSizeM = 32.0;
  static const double avatarSizeL = 40.0;
  static const double avatarSizeXL = 56.0;

  // Animation Durations
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 600);

  // Message Limits
  static const int maxMessageLength = 4000;
  static const int conversationHistoryLimit = 10;

  // UI Constraints
  static const double dropdownMaxWidth = 140.0;
  static const double dropdownMenuMaxWidth = 280.0;
  static const double dropdownMenuMaxHeight = 400.0;
  static const double dropdownItemHeight = 56.0;
}

