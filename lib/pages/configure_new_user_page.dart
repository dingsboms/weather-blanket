import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:tempestry/theme/gradient_background.dart';

class ConfigureNewUserPage extends StatelessWidget {
  const ConfigureNewUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: CupertinoPageScaffold(
          child: Center(
              child: CupertinoButton(
                  onPressed: () => context.go("/settings"),
                  child: Text("Home")))),
    );
  }
}
