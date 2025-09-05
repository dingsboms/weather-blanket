import 'package:flutter/cupertino.dart';

/// Tempestry App Colors
/// Inspired by the yarn colors in the app logo
class AppColors {
  // Primary colors from the logo yarn
  static const Color warmOrange = Color(0xFFFF6B35); // Vibrant orange yarn
  static const Color deepBlue = Color(0xFF2E3A87); // Deep blue yarn
  static const Color royalPurple = Color(0xFF6A4C93); // Purple yarn
  static const Color brightPink = Color(0xFFFF006E); // Pink yarn
  static const Color skyBlue = Color(0xFF4ECDC4); // Light blue yarn
  static const Color goldenYellow = Color(0xFFFFBE0B); // Golden yellow yarn

  // Background colors
  static const Color darkBackground =
      Color(0xFF1A1B2E); // Dark navy inspired by logo center
  static const Color lightBackground =
      Color(0xFFF8F9FA); // Light background for contrast
  static const Color cardBackground =
      Color(0xFF16213E); // Slightly lighter than dark background

  // Text colors
  static const Color primaryText = Color(0xFFFFFFFF); // White text
  static const Color secondaryText = Color(0xFFB8BCC8); // Light gray text
  static const Color accentText = Color(0xFFFF6B35); // Orange accent text

  // Weather-specific colors (for temperature ranges)
  static const Color freezing = Color(0xFF6A4C93); // Purple for very cold
  static const Color cold = Color(0xFF2E3A87); // Blue for cold
  static const Color cool = Color(0xFF4ECDC4); // Light blue for cool
  static const Color mild = Color(0xFFFFBE0B); // Yellow for mild
  static const Color warm = Color(0xFFFF6B35); // Orange for warm
  static const Color hot = Color(0xFFFF006E); // Pink for hot

  // UI element colors
  static const Color success = Color(0xFF4ECDC4); // Success state
  static const Color warning = Color(0xFFFFBE0B); // Warning state
  static const Color error = Color(0xFFFF006E); // Error state
  static const Color border = Color(0xFF2A2D47); // Border color
  static const Color shadow = Color(0x1A000000); // Shadow color

  // Gradient combinations
  static const List<Color> primaryGradient = [
    warmOrange,
    brightPink,
  ];

  static const List<Color> coolGradient = [
    skyBlue,
    deepBlue,
  ];

  static const List<Color> warmGradient = [
    goldenYellow,
    warmOrange,
  ];

  // Yarn-inspired gradient combinations
  static const List<Color> yarnGradient = [
    darkBackground,
    deepBlue,
    royalPurple,
    cardBackground,
  ];

  static const List<Color> vibrantGradient = [
    deepBlue,
    royalPurple,
    brightPink,
  ];

  static const List<Color> lightBackgroundGradient = [
    lightBackground,
    skyBlue,
    goldenYellow,
  ];

  // Color scheme for different themes
  static const CupertinoThemeData darkTheme = CupertinoThemeData(
    primaryColor: warmOrange,
    scaffoldBackgroundColor: darkBackground,
    barBackgroundColor: cardBackground,
    textTheme: CupertinoTextThemeData(
      primaryColor: primaryText,
      textStyle: TextStyle(color: primaryText),
    ),
  );

  static const CupertinoThemeData lightTheme = CupertinoThemeData(
    primaryColor: deepBlue,
    scaffoldBackgroundColor: lightBackground,
    barBackgroundColor: CupertinoColors.systemBackground,
    textTheme: CupertinoTextThemeData(
      primaryColor: darkBackground,
      textStyle: TextStyle(color: darkBackground),
    ),
  );

  // Helper method to get weather condition color
  static Color getWeatherConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return goldenYellow;
      case 'cloudy':
      case 'overcast':
        return secondaryText;
      case 'rainy':
      case 'drizzle':
        return skyBlue;
      case 'stormy':
      case 'thunderstorm':
        return deepBlue;
      case 'snowy':
      case 'snow':
        return CupertinoColors.systemBackground;
      case 'windy':
        return cool;
      default:
        return primaryText;
    }
  }
}
