import 'package:flutter/cupertino.dart';

class TabScreen {
  final String title;
  final Widget screen;

  TabScreen({
    required this.title,
    required this.screen,
  });
}

class TabSelector extends StatefulWidget {
  final List<TabScreen> tabScreens;
  const TabSelector({super.key, required this.tabScreens});

  @override
  State<TabSelector> createState() => _TabSelectorState();
}

class _TabSelectorState extends State<TabSelector> {
  late Widget _selectedScreen;

  @override
  void initState() {
    super.initState();
    _selectedScreen = widget.tabScreens.first.screen;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoSegmentedControl(
            onValueChanged: (String value) {
              setState(() {
                final selectedTab = widget.tabScreens.firstWhere(
                  (e) => e.title == value,
                  orElse: () => widget.tabScreens.first,
                );

                setState(() {
                  _selectedScreen = selectedTab.screen;
                });
              });
            },
            children: Map.fromEntries(widget.tabScreens.map((e) => MapEntry(
                e.title,
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e.title),
                ))))),
        _selectedScreen
      ],
    );
  }
}
