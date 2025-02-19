import 'package:cloud_functions/cloud_functions.dart';

// Initialize Firebase Functions
final functions = FirebaseFunctions.instance;

// Call your function
Future<void> callMyFunction() async {
  final today = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  try {
    // Call the function by its exported name ('testCall' in your case)
    final result =
        await functions.httpsCallable('testCall').call({'date': today});

    print('Result: ${result.data}');
  } catch (e) {
    print('Error: $e');
  }
}
