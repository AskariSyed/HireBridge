import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> initializeFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  String? token = await messaging.getToken();
  print('FCM Token: $token');

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print('FCM Token refreshed: $newToken');
    // Optionally send to backend
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('App opened via notification: ${message.data}');
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground notification: ${message.notification?.title}');
  });

  return token; // return token to caller
}
