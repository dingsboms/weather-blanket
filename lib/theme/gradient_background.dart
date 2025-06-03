// filepath: /Users/richardmax/Programming/weather-blanket/lib/theme/gradient_background.dart
import 'package:flutter/cupertino.dart';
import 'app_gradients.dart';

/// A reusable gradient background widget for consistent theming
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
    this.useMainGradient = true,
  });

  final Widget child;
  final BoxDecoration? gradient;
  final bool useMainGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: gradient ??
          (useMainGradient
              ? AppGradients.mainBackground
              : AppGradients.vibrantBackground),
      child: child,
    );
  }
}

/// A gradient scaffold that works with Cupertino design
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.child,
    this.navigationBar,
    this.gradient,
    this.useMainGradient = true,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  final ObstructingPreferredSizeWidget? navigationBar;
  final BoxDecoration? gradient;
  final bool useMainGradient;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      gradient: gradient,
      useMainGradient: useMainGradient,
      child: CupertinoPageScaffold(
        navigationBar: navigationBar,
        backgroundColor: CupertinoColors.transparent,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        child: child,
      ),
    );
  }
}
