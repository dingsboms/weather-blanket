import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

/// Tempestry App Gradients
/// Beautiful gradient combinations inspired by yarn colors
class AppGradients {
  /// Main app background gradient - subtle and elegant
  static const BoxDecoration mainBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.darkBackground,
        AppColors.deepBlue,
        AppColors.royalPurple,
        AppColors.cardBackground,
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    ),
  );

  /// Vibrant background gradient - more colorful and energetic
  static const BoxDecoration vibrantBackground = BoxDecoration(
    gradient: LinearGradient(
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
    ),
  );

  /// Light theme gradient
  static const BoxDecoration lightBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.lightBackground,
        AppColors.skyBlue,
        AppColors.warmOrange,
        AppColors.goldenYellow,
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    ),
  );

  /// Warm gradient for special screens
  static const BoxDecoration warmBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.warmOrange,
        AppColors.brightPink,
        AppColors.royalPurple,
        AppColors.deepBlue,
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    ),
  );

  /// Sign-in specific gradient - welcoming and vibrant
  static const BoxDecoration signInBackground = BoxDecoration(
    gradient: LinearGradient(
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
    ),
  );

  /// Button gradients
  static const BoxDecoration primaryButton = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.warmOrange,
        AppColors.brightPink,
      ],
    ),
  );

  static const BoxDecoration secondaryButton = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.skyBlue,
        AppColors.deepBlue,
      ],
    ),
  );

  /// Card gradients
  static const BoxDecoration cardGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.cardBackground,
        AppColors.darkBackground,
      ],
    ),
  );

  /// Logo border gradient for special effects
  static const BoxDecoration logoBorder = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.warmOrange,
        AppColors.brightPink,
        AppColors.royalPurple,
      ],
      stops: [0.0, 0.5, 1.0],
    ),
  );

  /// Side image gradient for the sign-in screen
  static const BoxDecoration sideImageGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.skyBlue,
        AppColors.warmOrange,
        AppColors.brightPink,
        AppColors.royalPurple,
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    ),
  );

  /// Get a custom gradient decoration
  static BoxDecoration custom({
    required List<Color> colors,
    List<double>? stops,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: begin,
        end: end,
        colors: colors,
        stops: stops,
      ),
      borderRadius: borderRadius,
      boxShadow: boxShadow,
    );
  }
}
