import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController(text: 'sumit@assetflow.com');
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B5BDB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('O', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Text('ORGAFLOW', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              const Text('Sign in to manage and track your organization’s assets.', style: TextStyle(fontSize: 16, color: Color(0xFF666666), height: 1.4)),
              const SizedBox(height: 40),
              const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: _inputDecoration('Enter your email'),
              ),
              const SizedBox(height: 24),
              const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration('Enter your password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF888888)),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: const Color(0xFF3B5BDB),
                        onChanged: (value) => setState(() => _rememberMe = value!),
                      ),
                      const Text('Remember me', style: TextStyle(fontSize: 14, color: Color(0xFF444444))),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text('Forgot password?', style: TextStyle(fontSize: 14, color: Color(0xFF3B5BDB), fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // SIGN IN BUTTON -> Navigates to Dashboard
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don’t have an account? ', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    child: const Text('Sign Up', style: TextStyle(fontSize: 14, color: Color(0xFF3B5BDB), fontWeight: FontWeight.w600)),
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