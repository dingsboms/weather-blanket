import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:tempestry/models/weather_data.dart';
import 'package:tempestry/theme/app_colors.dart';

// Knitting Checkbox Widget
class KnittingCheckbox extends StatefulWidget {
  final String userId;
  final WeatherForecast item;

  const KnittingCheckbox({super.key, required this.userId, required this.item});

  @override
  State<KnittingCheckbox> createState() => _KnittingCheckboxState();
}

class _KnittingCheckboxState extends State<KnittingCheckbox> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.light),
      child: CupertinoCheckbox(
        checkColor: AppColors.darkBackground,
        fillColor:
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryText;
          }

          return AppColors.primaryText;
        }),
        value: widget.item.isKnitted,
        onChanged: (val) => _updateKnittingStatus(val),
      ),
    );
  }

  void _updateKnittingStatus(bool? val) {
    if (val != null) {
      setState(() {
        FirebaseFirestore.instance
            .collection("users")
            .doc(widget.userId)
            .collection("days")
            .doc(widget.item.docId)
            .set({"is_knitted": val}, SetOptions(merge: true));
      });
    }
  }
}
