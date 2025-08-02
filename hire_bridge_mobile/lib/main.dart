import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hire_bridge/Screens/login.dart';
import 'package:hire_bridge/Screens/signup.dart';
import 'firebase_options.dart';
import 'package:hire_bridge/Services/fcm_services.dart';
import 'package:provider/provider.dart';
import 'package:hire_bridge/Provider/student_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => StudentProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HireBridge SignUp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },

      home: const SignUpScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
