import 'package:flutter/services.dart';

/// Talks to native Android code over a MethodChannel to show a fully
/// native notification (no flutter_local_notifications or similar).
class NotificationService {
  static const _channel =
      MethodChannel('com.example.flutter_todo_app/notifications');

  Future<void> showTodoNotification({
    required String title,
    required String body,
    String profileName = 'Jane Doe',
  }) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'title': title,
        'body': body,
        'profileName': profileName,
      });
    } on PlatformException catch (e) {
      // In a real app, log this via your error-reporting tool of choice.
      // ignore: avoid_print
      print('Failed to show native notification: ${e.message}');
    }
  }
}
