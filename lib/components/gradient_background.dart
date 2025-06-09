import 'package:flutter/cupertino.dart';
import 'package:tempestry/theme/app_gradients.dart';

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

/// A gradient scaffold that replaces CupertinoPageScaffold for gradient backgrounds
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    this.navigationBar,
    required this.child,
    this.gradient,
    this.useMainGradient = true,
    this.resizeToAvoidBottomInset = true,
  });

  final ObstructingPreferredSizeWidget? navigationBar;
  final Widget child;
  final BoxDecoration? gradient;
  final bool useMainGradient;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: navigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: CupertinoColors.transparent,
      child: GradientBackground(
        gradient: gradient,
        useMainGradient: useMainGradient,
        child: child,
      ),
    );
  }
}
