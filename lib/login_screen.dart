
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'signup_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';
import 'config/api_config.dart';

import 'employee/employee_dashboard.dart';
import 'management/admin/admin_dashboard.dart';
import 'management/asset_manager/asset_manager_dashboard.dart';
import 'management/department_head/department_head_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String baseUrl = AppConfig.baseUrl;
  static const String googleServerClientId =
      AppConfig.googleServerClientId;
  static const String tokenStorageKey = 'access_token';

  static const Color primaryColor = Color(0xFF3B5BDB);
  static const Color backgroundColor = Color(0xFFEDEFF5);
  static const Color secondaryText = Color(0xFF6B7280);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isManagement = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _googleInitialized = false;

  String? _selectedManagementRole;

  static const Map<String, String> allowedAccounts = {
    'singhsumit23578@gmail.com': 'EMPLOYEE',
    'singhsumit98645@gmail.com': 'ASSET_MANAGER',
    'mehra65749@gmail.com': 'ADMIN',
    'singha96116@gmail.com': 'DEPARTMENT_HEAD',
  };

  @override
  void initState() {
    super.initState();
    _initializeGoogle();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initializeGoogle() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: googleServerClientId,
      );

      if (mounted) {
        setState(() => _googleInitialized = true);
      }
    } catch (e) {
      debugPrint('Google initialization error: $e');
    }
  }

  String _normalizeRole(String role) {
    final value = role
        .trim()
        .toUpperCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    switch (value) {
      case 'ADMIN':
        return 'ADMIN';
      case 'ASSETMANAGER':
      case 'ASSET_MANAGER':
        return 'ASSET_MANAGER';
      case 'DEPARTMENTHEAD':
      case 'DEPARTMENT_HEAD':
        return 'DEPARTMENT_HEAD';
      case 'EMPLOYEE':
        return 'EMPLOYEE';
      default:
        return value;
    }
  }

  String _selectedRole() {
    if (!_isManagement) return 'EMPLOYEE';
    return _selectedManagementRole ?? '';
  }

  bool _validateAccount(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    final allowedRole = allowedAccounts[normalizedEmail];

    if (allowedRole == null) {
      _showMessage(
        'This email is not authorized to access Orgaflow.',
      );
      return false;
    }

    final selectedRole = _selectedRole();

    if (selectedRole.isEmpty) {
      _showMessage('Please select your management role.');
      return false;
    }

    if (allowedRole != selectedRole) {
      _showMessage(
        'This email is not authorized for the selected portal or role.',
      );
      return false;
    }

    return true;
  }

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

  String _extractMessage(dynamic data, int statusCode) {
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) {
        return detail;
      }

      final message = data['message'];
      if (message != null) return message.toString();
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your details.';
      case 401:
        return 'Invalid email or password.';
      case 403:
        return 'You are not authorized for this portal or role.';
      case 404:
        return 'Login API endpoint was not found.';
      case 500:
        return 'Server error. Please check backend logs.';
      default:
        return 'Login failed. HTTP $statusCode';
    }
  }

  Future<bool> _saveSession(dynamic data) async {
    if (data is! Map) return false;

    final token =
        (data['access_token'] ?? data['token'])
                ?.toString()
                .trim() ??
            '';

    if (token.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenStorageKey, token);
    return true;
  }

  void _openDashboardByRole(
    String role,
    Map<String, dynamic> userData,
  ) {
    final normalizedRole = _normalizeRole(role);
    final Widget destination;

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
        destination = EmployeeDashboard(
          isNewUser: false,
          userData: userData,
        );
        break;

      default:
        _showMessage(
          'Unknown account role. Contact the administrator.',
        );
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  Future<void> _processSuccessfulLogin(dynamic data) async {
    if (data is! Map) {
      _showMessage('Invalid response received from server.');
      return;
    }

    final rawUser = data['user'] ?? data;

    if (rawUser is! Map) {
      _showMessage(
        'User information was not received from the server.',
      );
      return;
    }

    final user = Map<String, dynamic>.from(rawUser);
    final email =
        (user['email'] ?? '').toString().trim().toLowerCase();
    final serverRole = _normalizeRole(
      (user['role'] ?? '').toString(),
    );

    final expectedRole = allowedAccounts[email];

    if (expectedRole == null || expectedRole != serverRole) {
      _showMessage(
        'The account email or role does not match the allowed account.',
      );
      return;
    }

    if (serverRole != _selectedRole()) {
      _showMessage(
        'Your account role does not match the selected portal.',
      );
      return;
    }

    final saved = await _saveSession(data);

    if (!saved) {
      _showMessage('No access token received. Please try again.');
      return;
    }

    if (!mounted) return;
    _openDashboardByRole(serverRole, user);
  }

  Future<dynamic> _postJson(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$endpoint'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 25));

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = <String, dynamic>{};
    }

    if (response.statusCode != 200) {
      throw _ApiException(
        _extractMessage(data, response.statusCode),
      );
    }

    return data;
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter your password.');
      return;
    }

    if (!_validateAccount(email)) return;

    setState(() => _isLoading = true);

    try {
      final body = <String, dynamic>{
        'email': email,
        'password': password,
        'portal': _isManagement ? 'management' : 'employee',
      };

      if (_isManagement) {
        body['role'] = _selectedManagementRole;
      }

      final data = await _postJson('/api/auth/login', body);
      await _processSuccessfulLogin(data);
    } on _ApiException catch (e) {
      _showMessage(e.message);
    } on TimeoutException {
      _showMessage('Server timed out. Please try again.');
    } catch (e) {
      debugPrint('Login error: $e');
      _showMessage(
        'Cannot connect to Orgaflow server. Check your internet and API URL.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleLogin() async {
    if (_isLoading) return;

    if (!_googleInitialized) {
      await _initializeGoogle();
    }

    if (!_googleInitialized) {
      _showMessage('Google Sign-In could not be initialized.');
      return;
    }

    if (_isManagement && _selectedManagementRole == null) {
      _showMessage('Please select your management role.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final account = await _googleSignIn.authenticate();
      final googleEmail = account.email.trim().toLowerCase();

      if (!_validateAccount(googleEmail)) {
        try {
          await _googleSignIn.signOut();
        } catch (_) {}
        return;
      }

      final idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        _showMessage(
          'Google ID token was not received. Check your OAuth configuration.',
        );
        return;
      }

      final body = <String, dynamic>{
        'id_token': idToken,
        'portal': _isManagement ? 'management' : 'employee',
      };

      if (_isManagement) {
        body['role'] = _selectedManagementRole;
      }

      final data = await _postJson('/api/auth/google-login', body);

      final rawUser = data is Map ? (data['user'] ?? data) : null;

      if (rawUser is! Map ||
          (rawUser['email'] ?? '')
                  .toString()
                  .trim()
                  .toLowerCase() !=
              googleEmail) {
        _showMessage(
          'Google account does not match the server response.',
        );
        return;
      }

      await _processSuccessfulLogin(data);
    } on _ApiException catch (e) {
      _showMessage(e.message);
    } on TimeoutException {
      _showMessage('Server timed out. Please try again.');
    } catch (e) {
      debugPrint('Google login error: $e');

      final error = e.toString().toLowerCase();

      if (error.contains('cancel')) {
        _showMessage('Google sign-in was cancelled.');
      } else {
        _showMessage(
          'Google sign-in failed. Check Google configuration and backend.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openSignup() {
    if (_isLoading) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
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
              setState(() {
                _isManagement = true;
                _selectedManagementRole = null;
              });
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
              color: selected
                  ? Colors.white
                  : const Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    if (!_isManagement) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: DropdownButtonFormField<String>(
        value: _selectedManagementRole,
        isExpanded: true,
        decoration: _inputDecoration(
          'Select Management Role',
          Icons.admin_panel_settings_outlined,
        ),
        items: const [
          DropdownMenuItem(
            value: 'ASSET_MANAGER',
            child: Text('Asset Manager'),
          ),
          DropdownMenuItem(
            value: 'ADMIN',
            child: Text('Admin'),
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

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: primaryColor),
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
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      enabled: !_isLoading,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      decoration: _inputDecoration(
        'Email address',
        Icons.email_outlined,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      enabled: !_isLoading,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      onSubmitted: (_) => _login(),
      decoration: _inputDecoration(
        'Password',
        Icons.lock_outline_rounded,
      ).copyWith(
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
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              primaryColor.withValues(alpha: 0.5),
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
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _googleLogin,
        icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
        label: const Text(
          'Continue with Google',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF202124),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFDADCE0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TextButton(
          onPressed: _isLoading ? null : _openPrivacyPolicy,
          child: const Text('Privacy Policy'),
        ),
        const Text(
          '•',
          style: TextStyle(color: secondaryText),
        ),
        TextButton(
          onPressed: _isLoading ? null : _openTermsConditions,
          child: const Text('Terms & Conditions'),
        ),
      ],
    );
  }

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
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
                      child: Image.asset(
                        'assets/images/orgaflow_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.business_center_rounded,
                          size: 48,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
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
                  _buildEmailField(),
                  const SizedBox(height: 14),
                  _buildPasswordField(),
                  _buildRoleDropdown(),
                  const SizedBox(height: 20),
                  _buildPrimaryButton(),
                  const SizedBox(height: 22),
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Color(0xFFDDE1E8),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Color(0xFFDDE1E8),
                        ),
                      ),
                    ],
                  ),
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
                      TextButton(
                        onPressed: _isLoading ? null : _openSignup,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildFooterLinks(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApiException implements Exception {
  final String message;

  const _ApiException(this.message);

  @override
  String toString() => message;
}
