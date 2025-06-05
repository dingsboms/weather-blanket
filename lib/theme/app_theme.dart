import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

/// App Theme Configuration
/// Provides centralized theme management for the Weather Blanket app
class AppTheme {
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
}
