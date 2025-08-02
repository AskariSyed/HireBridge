import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:hire_bridge/Screens/complete_profile.dart';
import 'package:hire_bridge/Screens/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hire_bridge/Services/fcm_services.dart';
import 'package:provider/provider.dart';
import 'package:hire_bridge/Provider/student_provider.dart';
import 'package:hire_bridge/Model/student.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback? onLoginTap;

  const SignUpScreen({super.key, this.onLoginTap});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  // COMSATS Wah theme colors
  final Color primaryBlue = const Color(0xFF004A99);
  final Color greyColor = Colors.grey.shade600;

  @override
  void dispose() {
    _fullNameController.dispose();
    _regNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() =>
      setState(() => _passwordVisible = !_passwordVisible);

  void _toggleConfirmPasswordVisibility() =>
      setState(() => _confirmPasswordVisible = !_confirmPasswordVisible);
  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final fcmToken = await initializeFCM();
        print('FCM Token: $fcmToken');

        final apiUrl = 'http://localhost:5214/api/Student/signup';
        final body = jsonEncode({
          "name": _fullNameController.text.trim(),
          "registrationNumber": _regNumberController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text,
          "fcmToken": fcmToken,
        });

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: body,
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Registered successfully'),
            ),
          );

          final student = Student(
            studentID: data['studentId'],
            userID: data['userId'],
            name: _fullNameController.text.trim(),
            registrationNumber: _regNumberController.text.trim(),
            email: _emailController.text.trim(),
          );

          // Save student in provider
          Provider.of<StudentProvider>(
            context,
            listen: false,
          ).setStudent(student);

          // Navigate to Complete Profile Screen to fill more info
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => CompleteProfileScreen(
                    studentID: student.studentID,
                    fcmToken: fcmToken ?? '',
                  ),
            ),
          );
        } else {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorData['message'] ?? 'Registration failed'),
            ),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error connecting to server')),
        );
      }
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
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo + Title Row
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
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Screen Title
                      Text(
                        'Student Sign Up',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Full Name
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Please enter your full name'
                                    : null,
                      ),
                      const SizedBox(height: 20),

                      // Registration Number
                      _buildTextField(
                        controller: _regNumberController,
                        label: 'Registration Number (FA22-BCS-155)',
                        inputFormatters: [MaskedInputFormatter('####-###-###')],
                        validator: (value) {
                          final regNumberRegex = RegExp(
                            r'^(FA|SP)\d{2}-BCS-\d{3}$',
                          );
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your registration number';
                          }
                          if (!regNumberRegex.hasMatch(value)) {
                            return 'Invalid format. Use FA22-BCS-155';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: !_passwordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: greyColor,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        obscureText: !_confirmPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: greyColor,
                          ),
                          onPressed: _toggleConfirmPasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            shadowColor: primaryBlue.withOpacity(0.5),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Link
                      GestureDetector(
                        onTap:
                            widget.onLoginTap ??
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: greyColor, fontSize: 16),
                            children: [
                              TextSpan(
                                text: 'Login',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }
}
