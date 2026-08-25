import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
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

  // Backend par Signup request bhejne ka function with strict checks
  Future<void> _registerUser() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 1. Check if any mandatory field is empty
    if (firstName.isEmpty || 
        lastName.isEmpty || 
        email.isEmpty || 
        phone.isEmpty || 
        password.isEmpty || 
        confirmPassword.isEmpty) {
      _showErrorSnackBar('Please fill in all mandatory fields!');
      return;
    }

    // 2. Strict Advanced Email Format Validation using RegEx
    // Yeh ensure karega ki email ka format bilkul standard aur real ho (e.g., user@domain.com)
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      _showErrorSnackBar('Please enter a valid, real email address (e.g., name@gmail.com)');
      return;
    }

    // 3. Phone number validation (10 digits check)
    if (phone.length < 10) {
      _showErrorSnackBar('Please enter a valid 10-digit phone number!');
      return;
    }

    // 4. Check password length & strength
    if (password.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters long!');
      return;
    }

    // 5. Check if passwords match
    if (password != confirmPassword) {
      _showErrorSnackBar('Passwords do not match!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // NOTE: Android Emulator ke liye 'http://10.0.2.2:8000/api/auth/signup' use karein.
      // Web ya Windows ke liye 'http://127.0.0.1:8000/api/auth/signup' theek hai.
      final url = Uri.parse('http://127.0.0.1:8000/api/auth/signup');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': '$firstName $lastName'.trim(),
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      } else {
        final errorData = jsonDecode(response.body);
        if (!mounted) return;
        _showErrorSnackBar(errorData['detail'] ?? 'Registration failed!');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      _showErrorSnackBar('Connection error! Please check if backend is running.');
    }
  }

  // Helper function for UI Error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
              const Text('Create your Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              const Text('Start managing resources in one place.', style: TextStyle(fontSize: 16, color: Color(0xFF666666), height: 1.4)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('First Name *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
                        const SizedBox(height: 8),
                        TextField(controller: _firstNameController, decoration: _inputDecoration('JOHN')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Last Name *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
                        const SizedBox(height: 8),
                        TextField(controller: _lastNameController, decoration: _inputDecoration('DAS')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Email *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
              const SizedBox(height: 8),
              TextField(controller: _emailController, decoration: _inputDecoration('name@company.com')),
              const SizedBox(height: 20),
              const Text('Phone *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
              const SizedBox(height: 8),
              TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: _inputDecoration('+91 9996565457')),
              const SizedBox(height: 20),
              const Text('Password *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
              const SizedBox(height: 8),
              TextField(controller: _passwordController, obscureText: true, decoration: _inputDecoration('••••••••')),
              const SizedBox(height: 20),
              const Text('Confirm Password *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
              const SizedBox(height: 8),
              TextField(controller: _confirmPasswordController, obscureText: true, decoration: _inputDecoration('••••••••')),
              const SizedBox(height: 32),
              
              // CREATE ACCOUNT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Sign In', style: TextStyle(fontSize: 14, color: Color(0xFF3B5BDB), fontWeight: FontWeight.w600)),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B5BDB))),
    );
  }
}