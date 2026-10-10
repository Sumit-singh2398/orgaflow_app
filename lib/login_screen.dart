
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'signup_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

import 'employee/employee_dashboard.dart';
import 'management/admin/admin_dashboard.dart';
import 'management/asset_manager/asset_manager_dashboard.dart';
import 'management/department_head/department_head_dashboard.dart';

// ============================================================
// GOOGLE FOUR-COLOUR LOGO
// ============================================================

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 23});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: GoogleLogoPainter(),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.39;
    final stroke = size.width * 0.18;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    // Red
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.35, 1.38, false, paint);

    // Yellow
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -0.92, 1.42, false, paint);

    // Green
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.57, 1.43, false, paint);

    // Blue
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, 2.08, 1.82, false, paint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..isAntiAlias = true;

    canvas.drawRect(
      Rect.fromLTWH(
        center.dx + radius * 0.05,
        center.dy - stroke / 2,
        radius * 1.05,
        stroke,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GoogleLogoPainter oldDelegate) => false;
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // BACKEND CONFIGURATION

  static const String baseUrl = 'http://127.0.0.1:8000';

  static const String googleServerClientId =
      '449981088129-fptar4p18jkmsgk6avhigqintmv0qha3.apps.googleusercontent.com';

  static const String tokenStorageKey = 'access_token';

  // COLORS

  static const Color primaryColor = Color(0xFF3B5BDB);
  static const Color backgroundColor = Color(0xFFEDEFF5);
  static const Color secondaryText = Color(0xFF6B7280);

  // CONTROLLERS

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  // STATE

  bool _isManagement = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _selectedManagementRole;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  void initState() {
    super.initState();
    _initializeGoogle();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(
      const AssetImage('assets/images/orgaflow_logo.png'),
      context,
    );
  }

  Future<void> _initializeGoogle() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: googleServerClientId,
      );

      debugPrint('Google Sign-In initialized successfully');
    } catch (e) {
      debugPrint('Google initialization error: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // MESSAGES AND SESSION
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<bool> _saveSession(dynamic data) async {
    if (data is! Map) return false;

    final token =
        (data['access_token'] ?? data['token'])?.toString().trim() ?? '';

    if (token.isEmpty) {
      debugPrint('No access token returned by backend');
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenStorageKey, token);
      return true;
    } catch (e) {
      debugPrint('Session save error: $e');
      return false;
    }
  }

  String _normalizeRole(String role) {
    return role
        .trim()
        .toUpperCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  String _extractBackendMessage(dynamic data, int statusCode) {
    if (data is Map) {
      final detail = data['detail'];

      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }

      if (detail is Map) return detail.toString();

      if (detail is List) {
        return detail.map((e) => e.toString()).join(', ');
      }

      final message = data['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }

      final error = data['error'];
      if (error != null && error.toString().trim().isNotEmpty) {
        return error.toString();
      }
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request.';
      case 401:
        return 'Authentication failed. Check your credentials.';
      case 403:
        return 'You are not authorized for this portal or role.';
      case 404:
        return 'Authentication endpoint not found.';
      case 500:
        return 'Server error. Check FastAPI logs.';
      default:
        return 'Request failed. HTTP $statusCode';
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openSignup() {
    if (_isLoading) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignupScreen(),
      ),
    );
  }

  void _openPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(),
      ),
    );
  }

  void _openTermsConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TermsConditionsScreen(),
      ),
    );
  }

  void _openDashboardByRole(
    String role,
    Map<String, dynamic> userData,
  ) {
    final normalizedRole = _normalizeRole(role);

    late final Widget destination;

    switch (normalizedRole) {
      case 'ADMIN':
        destination = const AdminDashboard();
        break;

      case 'ASSET_MANAGER':
        destination = const AssetManagerDashboard();
        break;

      case 'DEPARTMENT_HEAD':
        destination = const DepartmentHeadDashboard();
        break;

      case 'EMPLOYEE':
      default:
        destination = EmployeeDashboard(
          isNewUser: false,
          userData: userData,
        );
        break;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  // ============================================================
  // EMAIL AND PASSWORD LOGIN
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter your password.');
      return;
    }

    if (_isManagement && _selectedManagementRole == null) {
      _showMessage('Please select your management role.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> requestBody = {
        'email': email,
        'password': password,
        'portal': _isManagement ? 'management' : 'employee',
      };

      if (_isManagement) {
        requestBody['role'] = _selectedManagementRole;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      dynamic data;

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {};
      }

      if (response.statusCode == 200) {
        final rawUser = data is Map ? (data['user'] ?? data) : {};

        if (rawUser is! Map) {
          _showMessage('Invalid user data received from server.');
          return;
        }

        final userData = Map<String, dynamic>.from(rawUser);

        final saved = await _saveSession(data);

        if (!saved) {
          _showMessage(
            'Login succeeded, but no session token was returned.',
          );
          return;
        }

        if (!mounted) return;

        _openDashboardByRole(
          (userData['role'] ?? 'EMPLOYEE').toString(),
          userData,
        );
      } else {
        _showMessage(
          _extractBackendMessage(data, response.statusCode),
        );
      }
    } on TimeoutException {
      _showMessage('Server connection timed out. Please try again.');
    } catch (e) {
      debugPrint('Login error: $e');

      _showMessage(
        'Cannot connect to Orgaflow server. Check FastAPI and your connection.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================================
  // GOOGLE SIGN-IN
  // ============================================================

  Future<void> _googleLogin() async {
    if (_isLoading) return;

    if (_isManagement && _selectedManagementRole == null) {
      _showMessage('Please select your management role.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final account = await _googleSignIn.authenticate();

      final idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        _showMessage('Google authentication token was not received.');
        return;
      }

      final Map<String, dynamic> requestBody = {
        'id_token': idToken,
        'portal': _isManagement ? 'management' : 'employee',
      };

      if (_isManagement) {
        requestBody['role'] = _selectedManagementRole;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/google-login'),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      dynamic data;

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {};
      }

      if (response.statusCode == 200) {
        final rawUser = data is Map ? (data['user'] ?? data) : {};

        if (rawUser is! Map) {
          _showMessage('Invalid user data received from server.');
          return;
        }

        final userData = Map<String, dynamic>.from(rawUser);

        final saved = await _saveSession(data);

        if (!saved) {
          _showMessage(
            'Google login succeeded, but no session token was returned.',
          );
          return;
        }

        if (!mounted) return;

        _openDashboardByRole(
          (userData['role'] ?? 'EMPLOYEE').toString(),
          userData,
        );
      } else {
        _showMessage(
          _extractBackendMessage(data, response.statusCode),
        );
      }
    } on TimeoutException {
      _showMessage('Server connection timed out. Please try again.');
    } catch (e) {
      debugPrint('Google login error: $e');

      final error = e.toString().toLowerCase();

      if (error.contains('cancel')) {
        _showMessage('Google sign-in was cancelled.');
      } else {
        _showMessage(
          'Google sign-in failed or the Orgaflow server is unreachable.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================================
  // REUSABLE UI
  // ============================================================

  Widget _buildLogo() {
    return Container(
      width: 84,
      height: 84,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/orgaflow_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return const ColoredBox(
              color: primaryColor,
              child: Icon(
                Icons.business_center_rounded,
                color: Colors.white,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortalToggle() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          _portalOption(
            title: 'Employee',
            selected: !_isManagement,
            onTap: () {
              setState(() {
                _isManagement = false;
                _selectedManagementRole = null;
              });
            },
          ),
          _portalOption(
            title: 'Management',
            selected: _isManagement,
            onTap: () {
              setState(() => _isManagement = true);
            },
          ),
        ],
      ),
    );
  }

  Widget _portalOption({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: _isLoading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      enabled: !_isLoading,
      obscureText: obscureText,
      keyboardType: hint == 'Email'
          ? TextInputType.emailAddress
          : TextInputType.text,
      textInputAction:
          hint == 'Email' ? TextInputAction.next : TextInputAction.done,
      onSubmitted: hint == 'Password' ? (_) => _login() : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryColor, size: 21),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE3E7EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE3E7EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildManagementRoleDropdown() {
    if (!_isManagement) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedManagementRole,
        decoration: InputDecoration(
          hintText: 'Select Management Role',
          prefixIcon: const Icon(
            Icons.admin_panel_settings_outlined,
            color: primaryColor,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE3E7EF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE3E7EF)),
          ),
        ),
        items: const [
          DropdownMenuItem(
            value: 'ADMIN',
            child: Text('Admin'),
          ),
          DropdownMenuItem(
            value: 'ASSET_MANAGER',
            child: Text('Asset Manager'),
          ),
          DropdownMenuItem(
            value: 'DEPARTMENT_HEAD',
            child: Text('Department Head'),
          ),
        ],
        onChanged: _isLoading
            ? null
            : (value) {
                setState(() => _selectedManagementRole = value);
              },
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172B4D).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: _isLoading ? null : _googleLogin,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF202124),
          disabledForegroundColor: secondaryText,
          side: const BorderSide(color: Color(0xFFDADCE0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: primaryColor,
                ),
              )
            else
              const GoogleLogo(size: 23),
            const SizedBox(width: 12),
            Text(
              _isLoading ? 'Connecting to Google...' : 'Continue with Google',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFDDE1E8))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: TextStyle(
              color: secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFDDE1E8))),
      ],
    );
  }

  // ============================================================
  // SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 28,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const SizedBox(height: 4),

                  _buildLogo(),

                  const SizedBox(height: 22),

                  const Text(
                    'Welcome to Orgaflow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: Color(0xFF172033),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Manage your organization with ease',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryText,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildPortalToggle(),

                  const SizedBox(height: 22),

                  _buildTextField(
                    controller: _emailController,
                    hint: 'Email',
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 14),

                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: secondaryText,
                      ),
                    ),
                  ),

                  _buildManagementRoleDropdown(),

                  const SizedBox(height: 20),

                  _buildLoginButton(),

                  const SizedBox(height: 20),

                  _buildDivider(),

                  const SizedBox(height: 18),

                  _buildGoogleButton(),

                  const SizedBox(height: 24),

                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 13.5,
                          color: secondaryText,
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : _openSignup,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _openPrivacyPolicy,
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 9),
                        child: Text(
                          '•',
                          style: TextStyle(color: secondaryText),
                        ),
                      ),
                      GestureDetector(
                        onTap: _openTermsConditions,
                        child: const Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    '© 2026 Orgaflow',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: secondaryText,
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
}
