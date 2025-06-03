import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

/// App Theme Configuration
/// Provides centralized theme management for the Weather Blanket app
class AppTheme {
  /// Beautiful gradient backgrounds inspired by yarn colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.darkBackground,
      AppColors.deepBlue,
      AppColors.royalPurple,
      AppColors.cardBackground,
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.warmOrange,
      AppColors.brightPink,
      AppColors.royalPurple,
      AppColors.deepBlue,
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  /// Sign-in specific gradient - more vibrant and welcoming
  static const LinearGradient signInGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.deepBlue,
      AppColors.royalPurple,
      AppColors.brightPink,
      AppColors.warmOrange,
      AppColors.goldenYellow,
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );

  /// Main app theme (dark theme with yarn colors)
  static CupertinoThemeData get main => const CupertinoThemeData(
        primaryColor: AppColors.warmOrange,
        scaffoldBackgroundColor: AppColors.darkBackground,
        barBackgroundColor: AppColors.cardBackground,
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.primaryText,
          textStyle: TextStyle(
            color: AppColors.primaryText,
            fontFamily: '.SF Pro Text',
          ),
          navTitleTextStyle: TextStyle(
            color: AppColors.primaryText,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          navLargeTitleTextStyle: TextStyle(
            color: AppColors.primaryText,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  /// Get appropriate text color for background
  static Color getTextColor(Color backgroundColor) {
    // Calculate luminance to determine if background is light or dark
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? AppColors.darkBackground : AppColors.primaryText;
  }

  /// Get contrast color for a given color
  static Color getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? AppColors.darkBackground : AppColors.primaryText;
  }

  /// Common button styles
  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get secondaryButtonDecoration => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      );

  /// Common card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      );

  /// Input field decoration
  static BoxDecoration get inputDecoration => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      );

  /// Success decoration
  static BoxDecoration get successDecoration => BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.success,
          width: 1,
        ),
      );

  /// Warning decoration
  static BoxDecoration get warningDecoration => BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.warning,
          width: 1,
        ),
      );

  /// Error decoration
  static BoxDecoration get errorDecoration => BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.error,
          width: 1,
        ),
      );

  /// Creates a gradient container decoration
  static BoxDecoration gradientDecoration({
    LinearGradient? gradient,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      borderRadius: borderRadius,
    );
  }
}
