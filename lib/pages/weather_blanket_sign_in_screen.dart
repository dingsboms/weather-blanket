import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:weather_blanket/theme/app_colors.dart';
import 'package:weather_blanket/theme/app_theme.dart';

class WeatherBlanketSignInScreen extends StatelessWidget {
  const WeatherBlanketSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This lighter theme is to ensure the Google Sign-In button is blue
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        primarySwatch: Colors.blue,
      ),
      child: SignInScreen(
        providers: [
          GoogleProvider(
              clientId:
                  "88468625362-2efdkl917aiaios0mk2vja912a5jjqkg.apps.googleusercontent.com"),
          EmailAuthProvider()
        ],
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
                  gradient: AppTheme.signInGradient,
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
            child: SizedBox(
              width: constraints.maxWidth * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      gradient: AppTheme.signInGradient,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.signInGradient,
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
      ),
    );
  }
}
