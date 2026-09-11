import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

import '../employee/employee_dashboard.dart';
import '../management/admin/admin_dashboard.dart';
import '../management/asset_manager/asset_manager_dashboard.dart';
import '../management/department_head/department_head_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // false = Employee Portal
  // true = Management Portal
  bool _isManagement = false;

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  static const Color primaryColor =
      Color(0xFF3155D9);

  static const Color darkText =
      Color(0xFF172033);

  static const Color secondaryText =
      Color(0xFF6B7280);

  static const Color borderColor =
      Color(0xFFE4E7EC);

  static const Color backgroundColor =
      Color(0xFFF7F8FC);

  @override
  void initState() {
    super.initState();
    _initGoogleSignIn();
  }

  // ============================================================
  // GOOGLE INITIALIZATION
  // ============================================================

  Future<void> _initGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
            '449981088129-fptar4p18jkmsgk6avhigqintmv0qha3.apps.googleusercontent.com',
      );
    } catch (e) {
      debugPrint(
        'Google Sign-In Initialization Error: $e',
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // EMAIL / PASSWORD LOGIN
  // ============================================================

  Future<void> _loginUser() async {
    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        'Please enter email and password.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        'http://127.0.0.1:8000/api/auth/login',
      );

      // IMPORTANT:
      // User only selects portal.
      // User does NOT select role.
      final body = {
        'email': email,
        'password': password,
        'portal': _isManagement
            ? 'management'
            : 'employee',
      };

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

      debugPrint(
        'Login Status: ${response.statusCode}',
      );

      debugPrint(
        'Login Response: ${response.body}',
      );

      // ========================================================
      // LOGIN SUCCESS
      // ========================================================

      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body);

        final token =
            data['access_token'];

        final role =
            data['role'];

        debugPrint(
          'Login successful',
        );

        debugPrint(
          'Role from backend: $role',
        );

        debugPrint(
          'Token received: ${token != null}',
        );

        if (role == null) {
          _showMessage(
            'Server did not return user role.',
          );
          return;
        }

        // Send complete backend user data
        // to dashboard routing.
        _openDashboardByRole(
          role.toString(),
          data,
        );

        return;
      }

      // ========================================================
      // LOGIN FAILED
      // ========================================================

      try {
        final errorData =
            jsonDecode(response.body);

        _showMessage(
          errorData['detail'] ??
              'Invalid email or password.',
        );
      } catch (_) {
        _showMessage(
          'Login failed. Please try again.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint(
        'Login Error: $e',
      );

      _showMessage(
        'Unable to connect to server. '
        'Please check your backend.',
      );
    }
  }

  // ============================================================
  // ROLE BASED DASHBOARD ROUTING
  // ============================================================

  void _openDashboardByRole(
    String role,
    Map<String, dynamic> userData,
  ) {
    final normalizedRole =
        role.trim().toLowerCase();

    debugPrint(
      'Opening dashboard for role: '
      '$normalizedRole',
    );

    // ==========================================================
    // ADMIN
    // ==========================================================

    if (normalizedRole == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const AdminDashboard(),
        ),
      );

      return;
    }

    // ==========================================================
    // ASSET MANAGER
    // ==========================================================

    if (normalizedRole ==
        'asset manager') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const AssetManagerDashboard(),
        ),
      );

      return;
    }

    // ==========================================================
    // DEPARTMENT HEAD
    // ==========================================================

    if (normalizedRole ==
        'department head') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const DepartmentHeadDashboard(),
        ),
      );

      return;
    }

    // ==========================================================
    // EMPLOYEE
    // ==========================================================

    if (normalizedRole == 'employee') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EmployeeDashboard(
            // Existing employee login
            isNewUser: false,

            // Existing employee's actual data
            userData: userData,
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // UNKNOWN ROLE
    // ==========================================================

    _showMessage(
      'Unknown user role: $role',
    );
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<void> _loginWithGoogle() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ========================================================
      // GOOGLE AUTHENTICATION
      // ========================================================

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken =
          googleAuth.idToken;

      debugPrint(
        'Google Email: ${googleUser.email}',
      );

      debugPrint(
        'Google Name: ${googleUser.displayName}',
      );

      debugPrint(
        'Google ID Token available: '
        '${idToken != null}',
      );

      if (idToken == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          _showMessage(
            'Google authentication token '
            'not received.',
          );
        }

        return;
      }

      // ========================================================
      // SEND GOOGLE TOKEN TO FASTAPI
      // ========================================================

      final url = Uri.parse(
        'http://127.0.0.1:8000/api/auth/google-login',
      );

      final body = {
        'id_token': idToken,
        'portal': _isManagement
            ? 'management'
            : 'employee',
      };

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

      debugPrint(
        'Google Backend Status: '
        '${response.statusCode}',
      );

      debugPrint(
        'Google Backend Response: '
        '${response.body}',
      );

      // ========================================================
      // GOOGLE LOGIN SUCCESS
      // ========================================================

      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body);

        final token =
            data['access_token'];

        final role =
            data['role'];

        debugPrint(
          'Google login successful.',
        );

        debugPrint(
          'Role from backend: $role',
        );

        debugPrint(
          'Token received: ${token != null}',
        );

        if (role == null) {
          _showMessage(
            'Server did not return user role.',
          );
          return;
        }

        // ======================================================
        // GOOGLE EMPLOYEE
        //
        // This is an EXISTING authenticated account.
        // Therefore isNewUser = false.
        // ======================================================

        _openDashboardByRole(
          role.toString(),
          data,
        );

        return;
      }

      // ========================================================
      // GOOGLE LOGIN FAILED
      // ========================================================

      try {
        final errorData =
            jsonDecode(response.body);

        _showMessage(
          errorData['detail'] ??
              'Google login failed.',
        );
      } catch (_) {
        _showMessage(
          'Google login failed.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint(
        'Google Sign-In Error: $e',
      );

      _showMessage(
        'Google Sign-In failed. '
        'Please try again.',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
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
      backgroundColor:
          backgroundColor,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 28,
            ),

            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 470,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // ==================================================
                  // BRAND
                  // ==================================================

                  Row(
                    children: [

                      Container(
                        width: 46,
                        height: 46,

                        decoration:
                            BoxDecoration(
                          color:
                              primaryColor,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            13,
                          ),
                        ),

                        child:
                            const Center(
                          child: Text(
                            'O',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 26,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          Text(
                            'ORGAFLOW',
                            style:
                                TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              letterSpacing:
                                  1.2,
                              color:
                                  darkText,
                            ),
                          ),

                          SizedBox(
                            height: 2,
                          ),

                          Text(
                            'Asset & Resource Management',
                            style:
                                TextStyle(
                              fontSize: 11,
                              color:
                                  secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 38,
                  ),

                  // ==================================================
                  // WELCOME
                  // ==================================================

                  Text(
                    _isManagement
                        ? 'Welcome to Management'
                        : 'Welcome back',

                    style:
                        const TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight.w800,
                      color: darkText,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(
                    height: 9,
                  ),

                  Text(
                    _isManagement
                        ? 'Sign in to manage your organization, assets and resources.'
                        : 'Sign in to view your assigned assets and organization resources.',

                    style:
                        const TextStyle(
                      fontSize: 14.5,
                      color:
                          secondaryText,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ==================================================
                  // PORTAL SWITCHER
                  // ==================================================

                  Container(
                    padding:
                        const EdgeInsets
                            .all(5),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFECEFF6,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        15,
                      ),
                    ),

                    child: Row(
                      children: [

                        Expanded(
                          child:
                              _portalButton(
                            title:
                                'Employee',

                            icon: Icons
                                .person_outline_rounded,

                            selected:
                                !_isManagement,

                            onTap: () {
                              setState(() {
                                _isManagement =
                                    false;
                              });
                            },
                          ),
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Expanded(
                          child:
                              _portalButton(
                            title:
                                'Management',

                            icon: Icons
                                .admin_panel_settings_outlined,

                            selected:
                                _isManagement,

                            onTap: () {
                              setState(() {
                                _isManagement =
                                    true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ==================================================
                  // EMAIL
                  // ==================================================

                  _fieldLabel(
                    'Email address',
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                        _emailController,

                    keyboardType:
                        TextInputType
                            .emailAddress,

                    textInputAction:
                        TextInputAction
                            .next,

                    decoration:
                        _inputDecoration(
                      hint:
                          'you@company.com',
                      icon: Icons
                          .mail_outline_rounded,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ==================================================
                  // PASSWORD
                  // ==================================================

                  _fieldLabel(
                    'Password',
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                        _passwordController,

                    obscureText:
                        _obscurePassword,

                    textInputAction:
                        TextInputAction
                            .done,

                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _loginUser();
                      }
                    },

                    decoration:
                        _inputDecoration(
                      hint:
                          'Enter your password',
                      icon: Icons
                          .lock_outline_rounded,
                    ).copyWith(
                      suffixIcon:
                          IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },

                        icon: Icon(
                          _obscurePassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,

                          color:
                              const Color(
                            0xFF8A91A1,
                          ),

                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 13,
                  ),

                  // ==================================================
                  // REMEMBER + FORGOT
                  // ==================================================

                  Row(
                    children: [

                      SizedBox(
                        width: 22,
                        height: 22,

                        child: Checkbox(
                          value:
                              _rememberMe,

                          activeColor:
                              primaryColor,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              5,
                            ),
                          ),

                          onChanged:
                              (value) {
                            setState(() {
                              _rememberMe =
                                  value ??
                                      false;
                            });
                          },
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      const Text(
                        'Remember me',

                        style:
                            TextStyle(
                          fontSize: 13,
                          color:
                              secondaryText,
                        ),
                      ),

                      const Spacer(),

                      GestureDetector(
                        onTap: () {},

                        child:
                            const Text(
                          'Forgot password?',

                          style:
                              TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight
                                    .w600,
                            color:
                                primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // ==================================================
                  // SIGN IN BUTTON
                  // ==================================================

                  SizedBox(
                    width:
                        double.infinity,
                    height: 54,

                    child:
                        ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : _loginUser,

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            primaryColor,

                        disabledBackgroundColor:
                            const Color(
                          0xFF9AA9E7,
                        ),

                        elevation: 0,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            13,
                          ),
                        ),
                      ),

                      child: _isLoading
                          ? const SizedBox(
                              width: 21,
                              height: 21,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2.2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign In',

                              style:
                                  TextStyle(
                                fontSize:
                                    15.5,
                                fontWeight:
                                    FontWeight
                                        .w700,
                                color:
                                    Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ==================================================
                  // OR DIVIDER
                  // ==================================================

                  Row(
                    children: [

                      const Expanded(
                        child: Divider(
                          color:
                              borderColor,
                          thickness: 1,
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 14,
                        ),

                        child: Text(
                          'OR',

                          style:
                              TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight
                                    .w600,
                            color: Colors
                                .grey
                                .shade500,
                          ),
                        ),
                      ),

                      const Expanded(
                        child: Divider(
                          color:
                              borderColor,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ==================================================
                  // GOOGLE LOGIN
                  // ==================================================

                  SizedBox(
                    width:
                        double.infinity,
                    height: 52,

                    child:
                        OutlinedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : _loginWithGoogle,

                      style:
                          OutlinedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.white,

                        side:
                            const BorderSide(
                          color:
                              borderColor,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            13,
                          ),
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [

                          Container(
                            width: 25,
                            height: 25,

                            decoration:
                                const BoxDecoration(
                              shape:
                                  BoxShape
                                      .circle,
                              color:
                                  Color(
                                0xFFF1F3F4,
                              ),
                            ),

                            child:
                                const Center(
                              child: Text(
                                'G',

                                style:
                                    TextStyle(
                                  fontSize:
                                      15,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                  color:
                                      Color(
                                    0xFF4285F4,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          const Text(
                            'Continue with Google',

                            style:
                                TextStyle(
                              fontSize:
                                  14.5,
                              fontWeight:
                                  FontWeight
                                      .w600,
                              color:
                                  darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ==================================================
                  // SECURITY
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
                          color:
                              Color(
                            0xFF7C8495,
                          ),
                        ),

                        SizedBox(
                          width: 5,
                        ),

                        Text(
                          'Secure organization access',

                          style:
                              TextStyle(
                            fontSize: 11,
                            color:
                                Color(
                              0xFF7C8495,
                            ),
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
            const Duration(
          milliseconds: 180,
        ),

        padding:
            const EdgeInsets.symmetric(
          vertical: 13,
        ),

        decoration:
            BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.transparent,

          borderRadius:
              BorderRadius.circular(
            11,
          ),

          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(
                      0.04,
                    ),
                    blurRadius: 7,
                    offset:
                        const Offset(
                      0,
                      2,
                    ),
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
                  : const Color(
                      0xFF7A8190,
                    ),
            ),

            const SizedBox(
              width: 7,
            ),

            Text(
              title,

              style: TextStyle(
                fontSize: 13.5,

                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,

                color: selected
                    ? primaryColor
                    : const Color(
                        0xFF626978,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FIELD LABEL
  // ============================================================

  Widget _fieldLabel(String text) {
    return Text(
      text,

      style: const TextStyle(
        fontSize: 13.5,
        fontWeight:
            FontWeight.w600,
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

      hintStyle:
          const TextStyle(
        fontSize: 14,
        color:
            Color(0xFFA0A6B2),
      ),

      prefixIcon: Icon(
        icon,
        size: 20,
        color:
            const Color(
          0xFF858C9B,
        ),
      ),

      filled: true,

      fillColor:
          Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          13,
        ),

        borderSide:
            const BorderSide(
          color:
              borderColor,
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          13,
        ),

        borderSide:
            const BorderSide(
          color:
              borderColor,
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          13,
        ),

        borderSide:
            const BorderSide(
          color:
              primaryColor,
          width: 1.4,
        ),
      ),
    );
  }
}