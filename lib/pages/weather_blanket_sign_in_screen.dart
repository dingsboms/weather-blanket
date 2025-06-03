import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:weather_blanket/theme/app_colors.dart';

class WeatherBlanketSignInScreen extends StatelessWidget {
  const WeatherBlanketSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      resizeToAvoidBottomInset: false,
      styles: const {
        EmailFormStyle(
          signInButtonVariant: ButtonVariant.filled,
          inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.warmOrange),
            ),
          ),
        ),
      },
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
          ],
        ),
      ),
      sideBuilder: (context, constraints) => Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            width: constraints.maxWidth * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
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
                const SizedBox(height: 20),
                Container(
                  width: 300,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
        ),
      ),
    );
  }
}
