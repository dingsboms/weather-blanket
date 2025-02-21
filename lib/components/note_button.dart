// Note Button Widget
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_blanket/models/weather_data.dart';

class NoteButton extends StatelessWidget {
  final String userId;
  final WeatherForecast item;

  const NoteButton({super.key, required this.userId, required this.item});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showNoteDialog(context),
      icon: Icon(item.knittingNote == "" ? Icons.note_add : Icons.note),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(CupertinoColors.white),
        foregroundColor: WidgetStateProperty.all(CupertinoColors.activeBlue),
        padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      ),
    );
  }

  void _showNoteDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        // Text editing controllers to manage input
        final TextEditingController noteController = TextEditingController();

        noteController.text = item.knittingNote;

        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 400, // Increased height to accommodate form
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Write a note',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                CupertinoTextField(
                  controller: noteController,
                  padding: const EdgeInsets.all(12),
                  minLines: 5, // This will make it 5 lines tall minimum
                  maxLines: 10, // This allows it to grow up to 10 lines
                  style: const TextStyle(
                    color: CupertinoColors.black, // This fixes the text color
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton.filled(
                      child: const Text('Submit'),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(userId)
                            .collection("days")
                            .doc(item.docId)
                            .set({"knitting_note": noteController.text},
                                SetOptions(merge: true));

                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
