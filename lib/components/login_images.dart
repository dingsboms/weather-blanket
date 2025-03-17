import 'package:flutter/cupertino.dart';

class LoginImages extends StatelessWidget {
  const LoginImages({super.key});

  @override
  Widget build(BuildContext context) {
    const double heghtWidth = 160;
    String filePrefix = "assets/images/";

    const imageFileNames = [
      "1HomeScreen.png",
      "2EditDate.png",
      "3EditDateAutocomplete.png",
      "4EditTime.png",
      "5MakeANote.png",
      "6Intervals.png",
      "7EditColor.png",
      "8FullView.png"
    ];

    List<Widget> widgetChildren = [];
    List<Widget> rowChildren = [];

    for (int i = 0; i < imageFileNames.length; i++) {
      var imageFileName = imageFileNames[i];
      var imageFilePath = filePrefix + imageFileName;

      rowChildren.add(Image.asset(
        imageFilePath,
        width: heghtWidth,
        height: heghtWidth,
      ));

      if (i % 2 != 0) {
        widgetChildren.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowChildren,
        ));
        rowChildren = [];
      }
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.center, children: widgetChildren);
  }
}
