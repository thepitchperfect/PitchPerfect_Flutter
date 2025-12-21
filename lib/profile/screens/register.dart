import 'dart:convert'; // [FIX 1] Required for jsonEncode
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pitch_perfect_flutter/profile/screens/login.dart'; // Adjust import path

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  String get _baseUrl {
    if (kIsWeb) {
      return "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";
    }
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    }
    return "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            color: Colors.white,
            surfaceTintColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Register',
                    style: GoogleFonts.orbitron(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 30.0),

                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username',
                    hint: 'Enter your username',
                  ),
                  const SizedBox(height: 16.0),

                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                  ),
                  const SizedBox(height: 16.0),

                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16.0),

                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    isObscure: true,
                  ),
                  const SizedBox(height: 16.0),

                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    isObscure: true,
                  ),
                  const SizedBox(height: 32.0),

                  // --- Register Button ---
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            String username = _usernameController.text;
                            String fullName = _fullNameController.text;
                            String email = _emailController.text;
                            String password = _passwordController.text;
                            String confirmPassword =
                                _confirmPasswordController.text;

                            // 1. Validation
                            if (username.isEmpty ||
                                password.isEmpty ||
                                fullName.isEmpty ||
                                email.isEmpty) {
                              _showDialog(
                                'Validation Error',
                                'All fields are required.',
                              );
                              return;
                            }

                            if (password != confirmPassword) {
                              _showDialog(
                                'Validation Error',
                                'Passwords do not match.',
                              );
                              return;
                            }

                            setState(() => _isLoading = true);

                            try {
                              // [FIX 2] Use jsonEncode to convert the Map to a JSON String
                              final response = await request.postJson(
                                "$_baseUrl/auth/register/",
                                jsonEncode({
                                  'username': username,
                                  'full_name': fullName,
                                  'email': email,
                                  'password1': password,
                                  'password2': confirmPassword,
                                }),
                              );

                              if (!context.mounted) return;

                              if (response['status'] == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Account created successfully! Please login.",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              } else {
                                _showDialog(
                                  'Registration Failed',
                                  response['message'] ?? "Unknown error",
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                // This catches the HTML error if it still happens
                                _showDialog(
                                  'Connection Error',
                                  "Could not connect to server.\nError: $e",
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setState(() => _isLoading = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFFFE8800),
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Account'),
                  ),

                  const SizedBox(height: 24.0),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.lato(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                        children: const [
                          TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Log In",
                            style: TextStyle(
                              color: Color(0xFFFE8800),
                              fontWeight: FontWeight.bold,
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
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.grey[800]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFFFE8800)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
      ),
    );
  }
}
