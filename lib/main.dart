// import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:drawo_app/drawing_app.dart';
import 'package:drawo_app/core/service_locator.dart' as service_locator;
import 'package:drawo_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  service_locator.call();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupLocalNotifications();
  runApp(const DrawingApp());
  // DevicePreview(
  //   enabled: true,
  //   builder: (context) {
  //     return const DrawingApp();
  //   },
  // );
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
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >()
      ?.requestPermissions(alert: true, badge: true, sound: true);
}

Future<void> showNotification(String title, String body) async {
  try {
    final int id = DateTime.now().millisecondsSinceEpoch % 100000;
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          subtitle: 'Drawing App',
        ),
      ),
    );
  } catch (e) {
    debugPrint('Error to show notification: $e');
  }
}
