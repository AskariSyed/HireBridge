import 'package:flutter/material.dart';
import 'package:hire_bridge/Screens/fcm_message.dart';
import 'package:hire_bridge/Services/fcm_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:hire_bridge/Provider/student_provider.dart';
import 'package:hire_bridge/Model/student.dart'; // Adjust import paths as needed
import 'package:hire_bridge/Screens/fcm_message.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onSignUpTap;

  const LoginScreen({super.key, this.onSignUpTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _regNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading = false;

  final Color primaryBlue = const Color(0xFF004A99);
  final Color greyColor = Colors.grey.shade600;

  @override
  void dispose() {
    _regNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current FCM token from device
      final fcmToken = await initializeFCM();

      final apiUrl = 'http://localhost:5214/api/Student/login';

      final body = jsonEncode({
        "registrationNumber": _regNumberController.text.trim(),
        "password": _passwordController.text,
        "fcmToken": fcmToken, // <-- Send FCM token on login
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login successful')),
        );

        final studentJson = {
          "studentID": data['studentId'],
          "userID": data['userId'],
          "registrationNumber": data['registrationNumber'],
          "name": data['name'],
          "email": data['email'],
          "fcmToken": fcmToken,
        };

        final student = Student.fromJson(studentJson);

        Provider.of<StudentProvider>(
          context,
          listen: false,
        ).setStudent(student);

        // Navigate to FCMMessageScreen to receive and display messages
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FCMMessageScreen()),
        );
      } else {
        // error handling
        String errorMessage = 'Login failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          } else if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e, stacktrace) {
      setState(() {
        _isLoading = false;
      });

      print('Exception during login: $e');
      print('Stacktrace: $stacktrace');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 48 : 24,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo + Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_center,
                            size: 40,
                            color: primaryBlue,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'HireBridge CUI Wah',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Student Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Registration Number
                      TextFormField(
                        controller: _regNumberController,
                        decoration: InputDecoration(
                          labelText: 'Registration Number (FA22-BCS-155)',
                          labelStyle: TextStyle(color: greyColor),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          final regNumberRegex = RegExp(
                            r'^(FA|SP)\d{2}-BCS-\d{3}$',
                          );
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your registration number';
                          }
                          if (!regNumberRegex.hasMatch(value.trim())) {
                            return 'Invalid format. Use FA22-BCS-155';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: greyColor),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: greyColor,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                        obscureText: !_passwordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child:
                              _isLoading
                                  ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                  : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // SignUp link
                      GestureDetector(
                        onTap:
                            widget.onSignUpTap ??
                            () {
                              Navigator.pushNamed(context, '/signup');
                            },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: greyColor, fontSize: 16),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
