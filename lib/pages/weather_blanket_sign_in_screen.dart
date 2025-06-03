import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:weather_blanket/components/login_images.dart';
import 'package:weather_blanket/theme/app_colors.dart';
import 'package:weather_blanket/theme/app_gradients.dart';

class WeatherBlanketSignInScreen extends StatelessWidget {
  const WeatherBlanketSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: AppGradients.signInBackground,
        child: Theme(
          data: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: MaterialColor(
              AppColors.warmOrange.toARGB32(),
              <int, Color>{
                50: AppColors.warmOrange.withValues(alpha: 0.1),
                100: AppColors.warmOrange.withValues(alpha: 0.2),
                200: AppColors.warmOrange.withValues(alpha: 0.3),
                300: AppColors.warmOrange.withValues(alpha: 0.4),
                400: AppColors.warmOrange.withValues(alpha: 0.5),
                500: AppColors.warmOrange,
                600: AppColors.warmOrange.withValues(alpha: 0.7),
                700: AppColors.warmOrange.withValues(alpha: 0.8),
                800: AppColors.warmOrange.withValues(alpha: 0.9),
                900: AppColors.warmOrange,
              },
            ),
            scaffoldBackgroundColor: Colors.transparent,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.primaryText,
                backgroundColor: AppColors.warmOrange,
                textStyle: const TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryText,
                side: const BorderSide(color: AppColors.warmOrange),
                textStyle: const TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: AppColors.primaryText),
              bodyMedium: TextStyle(color: AppColors.primaryText),
              titleLarge: TextStyle(color: AppColors.primaryText),
              titleMedium: TextStyle(color: AppColors.primaryText),
            ),
          ),
          child: SignInScreen(
            headerBuilder: (context, constraints, shrinkOffset) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.warmOrange,
                          AppColors.brightPink,
                          AppColors.royalPurple,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warmOrange.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/WeatherBlanketLogo.png',
                        height: 120,
                        width: 120,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.warmOrange.withValues(alpha: 0.1),
                          AppColors.brightPink.withValues(alpha: 0.1),
                          AppColors.royalPurple.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.warmOrange.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      "Create a Weather-Blanket!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Color.fromARGB(80, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            sideBuilder: (context, constraints) => Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
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
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brightPink.withValues(alpha: 0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/WeatherBlanketLogo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            footerBuilder: (context, action) => const LoginImages(),
          ),
        ),
      ),
    );
  }
}
