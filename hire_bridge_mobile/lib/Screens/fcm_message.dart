import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMMessageScreen extends StatefulWidget {
  const FCMMessageScreen({Key? key}) : super(key: key);

  @override
  State<FCMMessageScreen> createState() => _FCMMessageScreenState();
}

class _FCMMessageScreenState extends State<FCMMessageScreen> {
  final List<RemoteMessage> _messages = [];

  @override
  void initState() {
    super.initState();

    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _messages.insert(0, message);
      });

      // Show SnackBar with notification content if available
      final notification = message.notification;
      if (notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${notification.title ?? "No Title"}: ${notification.body ?? "No Body"}',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    // Optionally: handle background & terminated state notifications elsewhere
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Messages'),
        backgroundColor: const Color(0xFF004A99), // Your primaryBlue
      ),
      body:
          _messages.isEmpty
              ? const Center(child: Text('No messages received yet.'))
              : ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final notification = msg.notification;
                  final data = msg.data;

                  return ListTile(
                    title: Text(notification?.title ?? 'No Title'),
                    subtitle: Text(notification?.body ?? data.toString()),
                    isThreeLine: true,
                    leading: const Icon(Icons.message),
                  );
                },
              ),
    );
  }
}
