import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

import 'signup_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ============================================================
  // STATE
  // ============================================================

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // false = Employee Portal
  // true  = Management Portal
  bool _isManagement = false;

  String _selectedRole = 'ADMIN';

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFF3155D9);
  static const Color darkText = Color(0xFF172033);
  static const Color secondaryText = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE4E7EC);
  static const Color backgroundColor = Color(0xFFF7F8FC);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
            '449981088129-fptar4p18jkmsgk6avhigqintmv0qha3.apps.googleusercontent.com',
      );
    } catch (e) {
      debugPrint('Google Sign-In Initialization Error: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // EMAIL LOGIN
  // ============================================================

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        'http://127.0.0.1:8000/api/auth/login',
      );

      final body = {
        'email': email,
        'password': password,
        'portal': _isManagement ? 'management' : 'employee',
      };

      if (_isManagement) {
        body['role'] = _selectedRole;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        debugPrint('Login successful');
        debugPrint('Access Token: ${data['access_token']}');
        debugPrint(
          'Portal: ${_isManagement ? 'management' : 'employee'}',
        );

        if (_isManagement) {
          debugPrint('Selected Role: $_selectedRole');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardScreen(),
          ),
        );
      } else {
        try {
          final errorData = jsonDecode(response.body);

          _showMessage(
            errorData['detail'] ?? 'Invalid email or password.',
          );
        } catch (_) {
          _showMessage('Login failed. Please try again.');
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to connect to server. Please check your backend.',
      );
    }
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint('Google Email: ${googleUser.email}');
      debugPrint('Google Name: ${googleUser.displayName}');
      debugPrint('Google ID Token: ${googleAuth.idToken}');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('Google Sign-In failed.');
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 28,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 470,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ==================================================
                  // BRAND
                  // ==================================================

                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                        child: const Center(
                          child: Text(
                            'O',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORGAFLOW',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: darkText,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Asset & Resource Management',
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 38),

                  // ==================================================
                  // WELCOME TEXT
                  // ==================================================

                  Text(
                    _isManagement
                        ? 'Welcome to Management'
                        : 'Welcome back',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    _isManagement
                        ? 'Sign in to manage your organization, assets and resources.'
                        : 'Sign in to view your assigned assets and organization resources.',
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: secondaryText,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // PORTAL SWITCHER
                  // ==================================================

                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEFF6),
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _portalButton(
                            title: 'Employee',
                            icon: Icons.person_outline_rounded,
                            selected: !_isManagement,
                            onTap: () {
                              setState(() {
                                _isManagement = false;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: _portalButton(
                            title: 'Management',
                            icon: Icons
                                .admin_panel_settings_outlined,
                            selected: _isManagement,
                            onTap: () {
                              setState(() {
                                _isManagement = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // ROLE SELECTOR
                  // ==================================================

                  AnimatedSwitcher(
                    duration:
                        const Duration(milliseconds: 220),
                    child: _isManagement
                        ? Padding(
                            padding:
                                const EdgeInsets.only(top: 16),
                            child: _roleSelector(),
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // EMAIL
                  // ==================================================

                  _fieldLabel('Email address'),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    textInputAction:
                        TextInputAction.next,
                    decoration: _inputDecoration(
                      hint: 'you@company.com',
                      icon: Icons
                          .mail_outline_rounded,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // PASSWORD
                  // ==================================================

                  _fieldLabel('Password'),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction:
                        TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _loginUser();
                      }
                    },
                    decoration: _inputDecoration(
                      hint: 'Enter your password',
                      icon: Icons
                          .lock_outline_rounded,
                    ).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                          color: const Color(0xFF8A91A1),
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  // ==================================================
                  // REMEMBER + FORGOT
                  // ==================================================

                  Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(5),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _rememberMe =
                                  value ?? false;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        'Remember me',
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryText,
                        ),
                      ),

                      const Spacer(),

                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // SIGN IN BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : _loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        disabledBackgroundColor:
                            const Color(0xFF9AA9E7),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 21,
                              height: 21,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight:
                                    FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // DIVIDER
                  // ==================================================

                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: borderColor,
                          thickness: 1,
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                Colors.grey.shade500,
                          ),
                        ),
                      ),

                      const Expanded(
                        child: Divider(
                          color: borderColor,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // GOOGLE BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _loginWithGoogle,
                      style:
                          OutlinedButton.styleFrom(
                        backgroundColor:
                            Colors.white,
                        side: const BorderSide(
                          color: borderColor,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            decoration:
                                const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF1F3F4),
                            ),
                            child: const Center(
                              child: Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w700,
                                  color:
                                      Color(0xFF4285F4),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          const Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight:
                                  FontWeight.w600,
                              color: darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // SIGN UP
                  // ==================================================

                  Center(
                    child: RichText(
                      text: TextSpan(
                        text:
                            "Don't have an account? ",
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: secondaryText,
                        ),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const SignupScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Create account',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight:
                                      FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // SECURITY NOTE
                  // ==================================================

                  Center(
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons
                              .verified_user_outlined,
                          size: 14,
                          color: Color(0xFF7C8495),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Secure organization access',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Color(0xFF7C8495),
                          ),
                        ),
                      ],
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

  // ============================================================
  // PORTAL BUTTON
  // ============================================================

  Widget _portalButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(11),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.04),
                    blurRadius: 7,
                    offset:
                        const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 19,
              color: selected
                  ? primaryColor
                  : const Color(0xFF7A8190),
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: selected
                    ? primaryColor
                    : const Color(0xFF626978),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ROLE SELECTOR
  // ============================================================

  Widget _roleSelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFEFF2FF),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons
                  .admin_panel_settings_outlined,
              color: primaryColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Management role',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: secondaryText,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _roleDisplayName(
                    _selectedRole,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                    color: darkText,
                  ),
                ),
              ],
            ),
          ),

          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRole,
              icon: const Icon(
                Icons
                    .keyboard_arrow_down_rounded,
                color: secondaryText,
              ),
              borderRadius:
                  BorderRadius.circular(12),
              items: const [
                DropdownMenuItem(
                  value: 'ADMIN',
                  child: Text('Admin'),
                ),
                DropdownMenuItem(
                  value: 'ASSET_MANAGER',
                  child: Text(
                    'Asset Manager',
                  ),
                ),
                DropdownMenuItem(
                  value: 'DEPARTMENT_HEAD',
                  child: Text(
                    'Department Head',
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedRole = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ROLE NAME
  // ============================================================

  String _roleDisplayName(String role) {
    switch (role) {
      case 'ASSET_MANAGER':
        return 'Asset Manager';

      case 'DEPARTMENT_HEAD':
        return 'Department Head';

      case 'ADMIN':
      default:
        return 'Admin';
    }
  }

  // ============================================================
  // FIELD LABEL
  // ============================================================

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: darkText,
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xFFA0A6B2),
      ),
      prefixIcon: Icon(
        icon,
        size: 20,
        color: const Color(0xFF858C9B),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.4,
        ),
      ),
    );
  }
}
