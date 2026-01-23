import 'package:device_preview/device_preview.dart';
import 'package:drawo_app/drawing_app.dart';
import 'package:drawo_app/core/service_locator.dart' as service_locator;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  service_locator.call();
  await Firebase.initializeApp();
  DevicePreview(
    enabled: true,
    builder: (context) {
      return const DrawingApp();
    },
  );
  runApp(const DrawingApp());
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> setupLocalNotifications() async {
  const ios = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(iOS: ios),
  );
}

Future<void> showNotification(String title, String body) async {
  try {
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(subtitle: 'Notification'),
      ),
    );
  } catch (e) {
    debugPrint('Error to show notification: $e');
  }
}
