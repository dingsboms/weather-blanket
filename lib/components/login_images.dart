import 'package:flutter/cupertino.dart';

class LoginImages extends StatelessWidget {
  const LoginImages({super.key});

  @override
  Widget build(BuildContext context) {
    double heghtWidth = 250;

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/1HomeScreen.png",
            width: heghtWidth,
            height: heghtWidth,
          ),
          Image.asset(
            "assets/images/2EditDate.png",
            width: heghtWidth,
            height: heghtWidth,
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/3EditDateAutocomplete.png",
            width: heghtWidth,
            height: heghtWidth,
          ),
          Image.asset(
            "assets/images/4EditTime.png",
            width: heghtWidth,
            height: heghtWidth,
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/5MakeANote.png",
            width: heghtWidth,
            height: heghtWidth,
          ),
          Image.asset(
            "assets/images/6Intervals.png",
            width: heghtWidth,
            height: heghtWidth,
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/7EditColor.png",
            width: heghtWidth,
            height: heghtWidth,
          ),
          Image.asset(
            "assets/images/8FullView.png",
            width: heghtWidth,
            height: heghtWidth,
          )
        ],
      )
    ]);
  }
}
