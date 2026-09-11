import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../employee/employee_dashboard.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController =
      TextEditingController();

  final TextEditingController _lastNameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // REGISTER USER
  // ============================================================

  Future<void> _registerUser() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // ------------------------------------------------------------
    // 1. EMPTY FIELD CHECK
    // ------------------------------------------------------------

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorSnackBar(
        'Please fill in all mandatory fields!',
      );
      return;
    }

    // ------------------------------------------------------------
    // 2. EMAIL VALIDATION
    // ------------------------------------------------------------

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      _showErrorSnackBar(
        'Please enter a valid email address '
        '(e.g., name@gmail.com)',
      );
      return;
    }

    // ------------------------------------------------------------
    // 3. PHONE VALIDATION
    // ------------------------------------------------------------

    final cleanPhone = phone.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (cleanPhone.length != 10) {
      _showErrorSnackBar(
        'Please enter a valid 10-digit phone number!',
      );
      return;
    }

    // ------------------------------------------------------------
    // 4. PASSWORD LENGTH
    // ------------------------------------------------------------

    if (password.length < 6) {
      _showErrorSnackBar(
        'Password must be at least 6 characters long!',
      );
      return;
    }

    // ------------------------------------------------------------
    // 5. PASSWORD MATCH
    // ------------------------------------------------------------

    if (password != confirmPassword) {
      _showErrorSnackBar(
        'Passwords do not match!',
      );
      return;
    }

    // ------------------------------------------------------------
    // START LOADING
    // ------------------------------------------------------------

    setState(() {
      _isLoading = true;
    });

    try {
      // ==========================================================
      // BACKEND URL
      // ==========================================================

      // Android Emulator:
      // http://10.0.2.2:8000/api/auth/signup
      //
      // Windows/Web:
      // http://127.0.0.1:8000/api/auth/signup
      //
      // Real Phone:
      // Use your computer's local IP address instead of
      // 127.0.0.1 when backend is running on your PC.

      final url = Uri.parse(
        'http://127.0.0.1:8000/api/auth/signup',
      );

      // ==========================================================
      // SEND SIGNUP REQUEST
      // ==========================================================

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': '$firstName $lastName'.trim(),
          'email': email,
          'phone': cleanPhone,
          'password': password,
        }),
      );

      // Stop loading

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // ==========================================================
      // SUCCESS
      // ==========================================================

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        if (!mounted) return;

        // ========================================================
        // NEW USER → EMPLOYEE DASHBOARD
        //
        // isNewUser = true means:
        // NewEmployeeHome will be shown.
        //
        // Existing employee data will NOT be used here.
        // ========================================================

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDashboard(
              isNewUser: true,

              // Only newly registered user's data
              userData: {
                'name': '$firstName $lastName'.trim(),
                'email': email,
                'phone': cleanPhone,

                // Explicitly mark this as a new employee
                'is_new_user': true,

                // New users are employees
                'role': 'Employee',
              },
            ),
          ),
          (route) => false,
        );

        return;
      }

      // ==========================================================
      // REGISTRATION FAILED
      // ==========================================================

      String errorMessage = 'Registration failed!';

      try {
        final errorData = jsonDecode(response.body);

        if (errorData is Map<String, dynamic>) {
          final detail = errorData['detail'];

          if (detail != null) {
            errorMessage = detail.toString();
          }
        }
      } catch (_) {
        // If response is not valid JSON,
        // keep default error message.
      }

      if (!mounted) return;

      _showErrorSnackBar(
        errorMessage,
      );
    } catch (e) {
      // ==========================================================
      // CONNECTION ERROR
      // ==========================================================

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showErrorSnackBar(
        'Connection error! Please check if backend is running.',
      );
    }
  }

  // ============================================================
  // ERROR SNACKBAR
  // ============================================================

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,

      hintText: hint,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0E0),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0E0),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF3B5BDB),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // BACK BUTTON
              // ==================================================

              IconButton(
                padding: EdgeInsets.zero,

                constraints: const BoxConstraints(),

                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF1A1A1A),
                ),

                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // TITLE
              // ==================================================

              const Text(
                'Create your Account',

                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Start managing resources in one place.',

                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 32),

              // ==================================================
              // FIRST NAME + LAST NAME
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'First Name *',

                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF444444),
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: _firstNameController,

                          textCapitalization:
                              TextCapitalization.words,

                          decoration:
                              _inputDecoration('JOHN'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'Last Name *',

                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF444444),
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: _lastNameController,

                          textCapitalization:
                              TextCapitalization.words,

                          decoration:
                              _inputDecoration('DAS'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==================================================
              // EMAIL
              // ==================================================

              const Text(
                'Email *',

                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF444444),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _emailController,

                keyboardType:
                    TextInputType.emailAddress,

                decoration:
                    _inputDecoration('name@company.com'),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // PHONE
              // ==================================================

              const Text(
                'Phone *',

                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF444444),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _phoneController,

                keyboardType:
                    TextInputType.phone,

                maxLength: 10,

                decoration:
                    _inputDecoration('9996565457')
                        .copyWith(
                  counterText: '',
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // PASSWORD
              // ==================================================

              const Text(
                'Password *',

                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF444444),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _passwordController,

                obscureText: true,

                decoration:
                    _inputDecoration('••••••••'),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // CONFIRM PASSWORD
              // ==================================================

              const Text(
                'Confirm Password *',

                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF444444),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller:
                    _confirmPasswordController,

                obscureText: true,

                decoration:
                    _inputDecoration('••••••••'),
              ),

              const SizedBox(height: 32),

              // ==================================================
              // CREATE ACCOUNT BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _registerUser,

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF3B5BDB),

                    disabledBackgroundColor:
                        const Color(0xFF9AA9E8),

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 18,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    elevation: 0,
                  ),

                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,

                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Account',

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // SIGN IN
              // ==================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  const Text(
                    'Already have an account? ',

                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: const Text(
                      'Sign In',

                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3B5BDB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}