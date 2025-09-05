import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

/// Extension methods for easy access to themed widgets and styles
extension TempestryTheme on BuildContext {
  /// Quick access to theme colors
  AppColors get colors => AppColors();

  /// Get weather condition color
  Color weatherColor(String condition) =>
      AppColors.getWeatherConditionColor(condition);
}

/// Themed text styles for consistent typography
class AppTextStyles {
  // Large titles
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  // Section titles
  static const TextStyle title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  // Card titles
  static const TextStyle headline = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  // Subheadings
  static const TextStyle subheadline = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  // Body text
  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );

  // Secondary body text
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
  );

  // Caption text
  static const TextStyle caption = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
  );

  // Small text
  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
  );

  // Accent text
  static const TextStyle accent = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.accentText,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  // Navigation titles
  static const TextStyle navTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  // Temperature display
  static const TextStyle temperature = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w300,
    color: AppColors.primaryText,
  );

  // Weather condition text
  static const TextStyle weatherCondition = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryText,
  );
}

/// Themed spacing constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Themed border radius constants
class AppBorderRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double circle = 100.0;
}

/// Common themed widgets for consistent UI
class ThemedWidgets {
  /// Primary action button
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CupertinoActivityIndicator(color: AppColors.primaryText)
            : Text(text, style: AppTextStyles.button),
      ),
    );
  }

  /// Secondary action button
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CupertinoActivityIndicator(color: AppColors.primaryText)
            : Text(text, style: AppTextStyles.button),
      ),
    );
  }

  /// Themed card container
  static Widget card({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
