import 'package:flutter/cupertino.dart';
import 'package:tempestry/pages/configure_new_user.dart/choose_date_range_page.dart';
import 'package:tempestry/pages/configure_new_user.dart/choose_default_location_page.dart';

class ConfigureNewUserPage extends StatefulWidget {
  const ConfigureNewUserPage({super.key});

  @override
  State<ConfigureNewUserPage> createState() => _ConfigureNewUserPageState();
}

class _ConfigureNewUserPageState extends State<ConfigureNewUserPage> {
  late int currentPageIndex;
  @override
  void initState() {
    currentPageIndex = 0;
    super.initState();
  }

  void nextPage() {
    setState(() {
      currentPageIndex += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        leading: currentPageIndex != 0
            ? CupertinoButton(
                child: const Icon(CupertinoIcons.arrow_left),
                onPressed: () => setState(() {
                      currentPageIndex -= 1;
                    }))
            : null,
      ),
      child: switch (currentPageIndex) {
        0 => ChooseDefaultLocationPage(onLocationSelected: () => nextPage()),
        1 => ChooseDateRangePage(onDateRangeSelected: () => nextPage()),
        2 => Placeholder(),
        _ => ErrorWidget(
            "Page not found: $currentPageIndex",
          ),
      },
    );
  }
}
