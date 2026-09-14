import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

import 'signup_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

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
  // ============================================================
  // CONFIGURATION
  // ============================================================

  // Physical Android phone + USB:
  //
  // adb reverse --remove-all
  // adb reverse tcp:8000 tcp:8000
  //
  // Phone 127.0.0.1:8000 -> PC 127.0.0.1:8000
  static const String baseUrl = 'http://127.0.0.1:8000';

  static const String googleServerClientId =
      '449981088129-fptar4p18jkmsgk6avhigqintmv0qha3.apps.googleusercontent.com';

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFF3B5BDB);
  static const Color backgroundColor = Color(0xFFEDEFF5);
  static const Color secondaryText = Color(0xFF6B7280);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool _isManagement = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _selectedManagementRole;

  // ============================================================
  // GOOGLE
  // ============================================================

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  void initState() {
    super.initState();
    _initializeGoogle();
  }

  Future<void> _initializeGoogle() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: googleServerClientId,
      );

      debugPrint(
        'Google Sign-In initialized successfully',
      );
    } catch (e) {
      debugPrint(
        'Google initialization error: $e',
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // SIGN UP
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

  // ============================================================
  // PRIVACY POLICY
  // ============================================================

  void _openPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(),
      ),
    );
  }

  // ============================================================
  // TERMS & CONDITIONS
  // ============================================================

  void _openTermsConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TermsConditionsScreen(),
      ),
    );
  }

  // ============================================================
  // NORMALIZE ROLE
  // ============================================================

  String _normalizeRole(String role) {
    return role
        .trim()
        .toUpperCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  // ============================================================
  // EMAIL / PASSWORD LOGIN
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // ------------------------------------------------------------
    // Validation
    // ------------------------------------------------------------

    if (email.isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter your password.');
      return;
    }

    if (_isManagement &&
        _selectedManagementRole == null) {
      _showMessage(
        'Please select your management role.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // Request
      // ----------------------------------------------------------

      final Map<String, dynamic> requestBody = {
        'email': email,
        'password': password,

        // Backend uses this only to know which portal
        // the user is trying to enter.
        'portal': _isManagement
            ? 'management'
            : 'employee',
      };

      // Role is required only for management login.
      //
      // IMPORTANT:
      // This does NOT grant the role.
      // Backend must compare this with users.role.
      if (_isManagement) {
        requestBody['role'] =
            _selectedManagementRole;
      }

      debugPrint(
        'LOGIN REQUEST: ${jsonEncode(requestBody)}',
      );

      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/api/auth/login',
            ),
            headers: const {
              'Content-Type':
                  'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      debugPrint(
        'LOGIN RESPONSE: '
        '${response.statusCode} '
        '${response.body}',
      );

      dynamic data;

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {};
      }

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response.statusCode == 200) {
        final rawUser =
            data is Map
                ? (data['user'] ?? data)
                : {};

        if (rawUser is! Map) {
          _showMessage(
            'Invalid user data received from server.',
          );
          return;
        }

        final userData =
            Map<String, dynamic>.from(
          rawUser,
        );

        final role = _normalizeRole(
          (userData['role'] ??
                  'EMPLOYEE')
              .toString(),
        );

        debugPrint(
          'LOGIN SUCCESS',
        );
        debugPrint(
          'ACTUAL USER ROLE: $role',
        );

        if (!mounted) return;

        _openDashboardByRole(
          role,
          userData,
        );

        return;
      }

      // ----------------------------------------------------------
      // BACKEND ERROR
      // ----------------------------------------------------------

      final message =
          _extractBackendMessage(
        data,
        response.statusCode,
      );

      _showMessage(message);
    } on http.ClientException catch (e) {
      debugPrint(
        'HTTP CLIENT ERROR: $e',
      );

      _showMessage(
        'Cannot connect to Orgaflow server. '
        'Check FastAPI and adb reverse.',
      );
    } catch (e) {
      debugPrint(
        'LOGIN ERROR: $e',
      );

      final error = e.toString();

      if (error.contains(
            'Connection refused',
          ) ||
          error.contains(
            'SocketException',
          )) {
        _showMessage(
          'Cannot connect to Orgaflow server. '
          'Make sure FastAPI is running and '
          'USB reverse is enabled.',
        );
      } else if (error.contains(
        'TimeoutException',
      )) {
        _showMessage(
          'Server connection timed out. '
          'Please try again.',
        );
      } else {
        _showMessage(
          'Login failed. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<void> _googleLogin() async {
    if (_isManagement &&
        _selectedManagementRole == null) {
      _showMessage(
        'Please select your management role.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // STEP 1: GOOGLE SIGN IN
      // ----------------------------------------------------------

      debugPrint(
        'Starting Google Sign-In...',
      );

      final account =
          await _googleSignIn.authenticate();

      debugPrint(
        'Google account selected: '
        '${account.email}',
      );

      // ----------------------------------------------------------
      // STEP 2: GET GOOGLE ID TOKEN
      // ----------------------------------------------------------

      final authentication =
          account.authentication;

      final idToken =
          authentication.idToken;

      if (idToken == null ||
          idToken.isEmpty) {
        debugPrint(
          'Google ID token is null or empty.',
        );

        _showMessage(
          'Google authentication token '
          'was not received.',
        );

        return;
      }

      debugPrint(
        'Google ID token received successfully.',
      );

      // ----------------------------------------------------------
      // STEP 3: PREPARE FASTAPI REQUEST
      // ----------------------------------------------------------

      final Map<String, dynamic> requestBody = {
        'id_token': idToken,

        // Employee or Management
        'portal': _isManagement
            ? 'management'
            : 'employee',
      };

      // For management:
      //
      // Backend must compare this selected role
      // with users.role.
      //
      // Example:
      // selected = ADMIN
      // database = ADMIN
      // -> allowed
      //
      // selected = ADMIN
      // database = EMPLOYEE
      // -> 403
      if (_isManagement) {
        requestBody['role'] =
            _selectedManagementRole;
      }

      debugPrint(
        'GOOGLE REQUEST PORTAL: '
        '${requestBody['portal']}',
      );

      if (_isManagement) {
        debugPrint(
          'GOOGLE REQUEST ROLE: '
          '${requestBody['role']}',
        );
      }

      // ----------------------------------------------------------
      // STEP 4: SEND TOKEN TO FASTAPI
      // ----------------------------------------------------------

      debugPrint(
        'Sending Google token to FastAPI...',
      );

      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/api/auth/google-login',
            ),
            headers: const {
              'Content-Type':
                  'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      debugPrint(
        'GOOGLE BACKEND RESPONSE: '
        '${response.statusCode} '
        '${response.body}',
      );

      dynamic data;

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {};
      }

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response.statusCode == 200) {
        final rawUser =
            data is Map
                ? (data['user'] ?? data)
                : {};

        if (rawUser is! Map) {
          _showMessage(
            'Invalid user data received '
            'from server.',
          );
          return;
        }

        final userData =
            Map<String, dynamic>.from(
          rawUser,
        );

        // IMPORTANT:
        // Role comes from backend/database.
        final role = _normalizeRole(
          (userData['role'] ??
                  'EMPLOYEE')
              .toString(),
        );

        debugPrint(
          'GOOGLE LOGIN SUCCESS',
        );

        debugPrint(
          'ACTUAL DATABASE ROLE: $role',
        );

        if (!mounted) return;

        _openDashboardByRole(
          role,
          userData,
        );

        return;
      }

      // ----------------------------------------------------------
      // BACKEND ERROR
      // ----------------------------------------------------------

      final message =
          _extractBackendMessage(
        data,
        response.statusCode,
      );

      debugPrint(
        'GOOGLE BACKEND ERROR: $message',
      );

      _showMessage(message);
    } on http.ClientException catch (e) {
      debugPrint(
        'GOOGLE HTTP CLIENT ERROR: $e',
      );

      _showMessage(
        'Google login succeeded, but '
        'Orgaflow server could not be reached.',
      );
    } catch (e) {
      debugPrint(
        'GOOGLE LOGIN ERROR: $e',
      );

      final error = e.toString();

      if (error.contains(
            'Connection refused',
          ) ||
          error.contains(
            'SocketException',
          )) {
        _showMessage(
          'Google login succeeded, but '
          'Orgaflow server could not be reached.',
        );
      } else if (error.contains(
            'canceled',
          ) ||
          error.contains(
            'cancelled',
          )) {
        _showMessage(
          'Google sign-in was cancelled.',
        );
      } else {
        _showMessage(
          'Google login failed. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // BACKEND MESSAGE
  // ============================================================

  String _extractBackendMessage(
    dynamic data,
    int statusCode,
  ) {
    if (data is Map) {
      final detail = data['detail'];

      if (detail != null) {
        if (detail is String &&
            detail.trim().isNotEmpty) {
          return detail;
        }

        if (detail is Map) {
          return detail.toString();
        }

        if (detail is List) {
          return detail
              .map(
                (e) => e.toString(),
              )
              .join(', ');
        }
      }

      final message = data['message'];

      if (message != null &&
          message.toString().trim().isNotEmpty) {
        return message.toString();
      }

      final error = data['error'];

      if (error != null &&
          error.toString().trim().isNotEmpty) {
        return error.toString();
      }
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request.';

      case 401:
        return 'Authentication failed.';

      case 403:
        return 'You are not authorized for this portal or role.';

      case 404:
        return 'Orgaflow authentication endpoint not found.';

      case 500:
        return 'Orgaflow server error. Check FastAPI logs.';

      default:
        return 'Request failed. HTTP $statusCode';
    }
  }

  // ============================================================
  // DASHBOARD ROUTING
  // ============================================================

  void _openDashboardByRole(
    String role,
    Map<String, dynamic> userData,
  ) {
    final normalizedRole =
        _normalizeRole(role);

    debugPrint(
      'Opening dashboard for role: '
      '$normalizedRole',
    );

    Widget destination;

    switch (normalizedRole) {
      case 'ADMIN':
        destination =
            const AdminDashboard();
        break;

      case 'ASSET_MANAGER':
        destination =
            const AssetManagerDashboard();
        break;

      case 'DEPARTMENT_HEAD':
        destination =
            const DepartmentHeadDashboard();
        break;

      case 'EMPLOYEE':
      default:
        destination =
            EmployeeDashboard(
          isNewUser: false,
          userData: userData,
        );
        break;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => destination,
      ),
      (route) => false,
    );
  }

  // ============================================================
  // PORTAL TOGGLE
  // ============================================================

  Widget _buildPortalToggle() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _isManagement = false;
                        _selectedManagementRole =
                            null;
                      });
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: !_isManagement
                      ? primaryColor
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Employee',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                    color: !_isManagement
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _isManagement = true;
                      });
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: _isManagement
                      ? primaryColor
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Management',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                    color: _isManagement
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType:
          hint == 'Email'
              ? TextInputType.emailAddress
              : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: primaryColor,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color: primaryColor,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MANAGEMENT ROLE DROPDOWN
  // ============================================================

  Widget _buildManagementRoleDropdown() {
    if (!_isManagement) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding:
          const EdgeInsets.only(top: 14),
      child:
          DropdownButtonFormField<String>(
        initialValue:
            _selectedManagementRole,
        decoration: InputDecoration(
          hintText:
              'Select Management Role',
          prefixIcon:
              const Icon(
            Icons
                .admin_panel_settings_outlined,
            color: primaryColor,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                BorderSide.none,
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide:
                BorderSide.none,
          ),
        ),
        items: const [
          DropdownMenuItem(
            value: 'ADMIN',
            child: Text('Admin'),
          ),
          DropdownMenuItem(
            value: 'ASSET_MANAGER',
            child:
                Text('Asset Manager'),
          ),
          DropdownMenuItem(
            value: 'DEPARTMENT_HEAD',
            child:
                Text('Department Head'),
          ),
        ],
        onChanged: _isLoading
            ? null
            : (value) {
                setState(() {
                  _selectedManagementRole =
                      value;
                });
              },
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
          child:
              SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),

                  // ------------------------------------------------
                  // LOGO
                  // ------------------------------------------------

                  Container(
                    width: 78,
                    height: 78,
                    decoration:
                        BoxDecoration(
                      color: primaryColor,
                      borderRadius:
                          BorderRadius.circular(
                        22,
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .business_center_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // ------------------------------------------------
                  // TITLE
                  // ------------------------------------------------

                  const Text(
                    'Welcome to Orgaflow',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight:
                          FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  const Text(
                    'Manage your organization with ease',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryText,
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ------------------------------------------------
                  // PORTAL
                  // ------------------------------------------------

                  _buildPortalToggle(),

                  const SizedBox(
                    height: 20,
                  ),

                  // ------------------------------------------------
                  // EMAIL
                  // ------------------------------------------------

                  _buildTextField(
                    controller:
                        _emailController,
                    hint: 'Email',
                    icon:
                        Icons.email_outlined,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // ------------------------------------------------
                  // PASSWORD
                  // ------------------------------------------------

                  _buildTextField(
                    controller:
                        _passwordController,
                    hint: 'Password',
                    icon:
                        Icons.lock_outline,
                    obscureText:
                        _obscurePassword,
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
                                .visibility_off_outlined
                            : Icons
                                .visibility_outlined,
                        color:
                            secondaryText,
                      ),
                    ),
                  ),

                  // ------------------------------------------------
                  // MANAGEMENT ROLE
                  // ------------------------------------------------

                  _buildManagementRoleDropdown(),

                  const SizedBox(
                    height: 20,
                  ),

                  // ------------------------------------------------
                  // LOGIN
                  // ------------------------------------------------

                  SizedBox(
                    width:
                        double.infinity,
                    height: 52,
                    child:
                        ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _login,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            primaryColor,
                        foregroundColor:
                            Colors.white,
                        disabledBackgroundColor:
                            primaryColor
                                .withValues(
                          alpha: 0.5,
                        ),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2.5,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              'Login',
                              style:
                                  TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ------------------------------------------------
                  // OR
                  // ------------------------------------------------

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors
                              .grey
                              .shade300,
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets
                                .symmetric(
                          horizontal: 12,
                        ),
                        child: Text(
                          'OR',
                          style:
                              TextStyle(
                            fontSize: 12,
                            color:
                                secondaryText,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors
                              .grey
                              .shade300,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ------------------------------------------------
                  // GOOGLE
                  // ------------------------------------------------

                  SizedBox(
                    width:
                        double.infinity,
                    height: 52,
                    child:
                        OutlinedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : _googleLogin,
                      icon: const Icon(
                        Icons
                            .g_mobiledata_rounded,
                        size: 30,
                      ),
                      label: const Text(
                        'Continue with Google',
                        style:
                            TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                      style:
                          OutlinedButton
                              .styleFrom(
                        foregroundColor:
                            Colors.black87,
                        backgroundColor:
                            Colors.white,
                        side: BorderSide(
                          color: Colors
                              .grey
                              .shade300,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // ------------------------------------------------
                  // SIGN UP
                  // ------------------------------------------------

                  Center(
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style:
                              TextStyle(
                            fontSize: 13.5,
                            color:
                                secondaryText,
                          ),
                        ),
                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : _openSignup,
                          child:
                              const Text(
                            'Sign Up',
                            style:
                                TextStyle(
                              fontSize: 13.5,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color:
                                  primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ------------------------------------------------
                  // PRIVACY + TERMS
                  // ------------------------------------------------

                  Wrap(
                    alignment:
                        WrapAlignment
                            .center,
                    children: [
                      GestureDetector(
                        onTap:
                            _openPrivacyPolicy,
                        child:
                            const Text(
                          'Privacy Policy',
                          style:
                              TextStyle(
                            fontSize: 12.5,
                            fontWeight:
                                FontWeight
                                    .w600,
                            color:
                                primaryColor,
                          ),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets
                                .symmetric(
                          horizontal: 8,
                        ),
                        child: Text(
                          '•',
                          style:
                              TextStyle(
                            color:
                                secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            _openTermsConditions,
                        child:
                            const Text(
                          'Terms & Conditions',
                          style:
                              TextStyle(
                            fontSize: 12.5,
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
                    height: 12,
                  ),

                  const Text(
                    '© 2026 Orgaflow',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: secondaryText,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
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