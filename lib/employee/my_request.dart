import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================
/// API CONFIG
/// ============================================================
///
/// IMPORTANT:
/// If you are using a REAL Android phone connected through USB:
///
///     adb reverse tcp:8000 tcp:8000
///
/// Then 127.0.0.1 will point to your laptop's FastAPI server.
///
/// If you use Android Emulator instead, use:
///     http://10.0.2.2:8000
///
class ApiConfig {
  static const String baseUrl = 'https://orgaflow-app.onrender.com';

  static const Duration requestTimeout = Duration(seconds: 30);
}

/// ============================================================
/// AUTH STORAGE
/// ============================================================

class AuthStorage {
  static const String _primaryKey = 'access_token';

  static const List<String> _legacyKeys = [
    'token',
    'accessToken',
    'jwt',
  ];

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_primaryKey, token);

    // Keep legacy keys synchronized in case old screens use them.
    await prefs.setString('token', token);
    await prefs.setString('accessToken', token);
    await prefs.setString('jwt', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    // First check the new key.
    final primaryToken = prefs.getString(_primaryKey);

    if (primaryToken != null && primaryToken.trim().isNotEmpty) {
      return primaryToken.trim();
    }

    // Check old keys.
    for (final key in _legacyKeys) {
      final token = prefs.getString(key);

      if (token != null && token.trim().isNotEmpty) {
        // Save it to the new key too.
        await prefs.setString(_primaryKey, token.trim());
        return token.trim();
      }
    }

    return null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_primaryKey);

    for (final key in _legacyKeys) {
      await prefs.remove(key);
    }
  }
}

/// ============================================================
/// MY REQUEST PAGE
/// ============================================================

class MyRequest extends StatefulWidget {
  final Map<String, dynamic>? userData;

  /// Asset selected from EmployeeAssetsPage.
  final Map<String, dynamic> asset;

  const MyRequest({
    super.key,
    this.userData,
    required this.asset,
  });

  @override
  State<MyRequest> createState() => _MyRequestState();
}

class _MyRequestState extends State<MyRequest> {
  final TextEditingController departmentController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  String selectedPriority = 'Normal';

  bool isSubmitting = false;

  // ------------------------------------------------------------
  // SAFE VALUE HELPERS
  // ------------------------------------------------------------

  String _stringValue(dynamic value) {
    if (value == null) return '';

    return value.toString().trim();
  }

  String get employeeName {
    return _stringValue(
      widget.userData?['name'],
    ).isNotEmpty
        ? _stringValue(widget.userData?['name'])
        : 'Employee';
  }

  String get employeeEmail {
    return _stringValue(
      widget.userData?['email'],
    );
  }

  String get userDepartment {
    return _stringValue(
      widget.userData?['department'],
    );
  }

  String get assetName {
    return _stringValue(
      widget.asset['name'],
    );
  }

  String get assetId {
    return _stringValue(
      widget.asset['assetId'] ??
          widget.asset['asset_id'] ??
          widget.asset['id'],
    );
  }

  String get assetCategory {
    return _stringValue(
      widget.asset['category'] ??
          widget.asset['assetCategory'] ??
          widget.asset['asset_category'],
    );
  }

  String get assetBrand {
    return _stringValue(
      widget.asset['brand'] ??
          widget.asset['assetBrand'] ??
          widget.asset['asset_brand'],
    );
  }

  String get assetModel {
    return _stringValue(
      widget.asset['model'] ??
          widget.asset['assetModel'] ??
          widget.asset['asset_model'],
    );
  }

  String get assetImage {
    return _stringValue(
      widget.asset['image'],
    );
  }

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Automatically fill department if available.
    departmentController.text = userDepartment;
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    departmentController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void _showMessage(
    String message, {
    bool success = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success ? Colors.green.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ------------------------------------------------------------
  // ERROR PARSER
  // ------------------------------------------------------------

  String _getErrorMessage(http.Response response) {
    try {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];

        if (detail is String && detail.trim().isNotEmpty) {
          return detail.trim();
        }

        if (detail is List && detail.isNotEmpty) {
          final messages = detail.map((item) {
            if (item is Map<String, dynamic>) {
              return _stringValue(
                item['msg'],
              );
            }

            return item.toString();
          }).where((msg) => msg.trim().isNotEmpty).join(', ');

          if (messages.isNotEmpty) {
            return messages;
          }
        }

        final message = decoded['message'];

        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {
      // Response was not valid JSON.
    }

    if (response.body.trim().isNotEmpty) {
      return response.body.trim();
    }

    return 'Request failed with status ${response.statusCode}.';
  }

  // ------------------------------------------------------------
  // SUBMIT REQUEST
  // ------------------------------------------------------------

  Future<void> _submitRequest() async {
    if (isSubmitting) return;

    final department = departmentController.text.trim();
    final description = descriptionController.text.trim();

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (department.isEmpty) {
      _showMessage('Please enter your department.');
      return;
    }

    if (assetName.isEmpty) {
      _showMessage('Asset name is missing.');
      return;
    }

    if (assetId.isEmpty) {
      _showMessage('Asset ID is missing.');
      return;
    }

    if (description.isEmpty) {
      _showMessage('Please enter the reason for your request.');
      return;
    }

    if (description.length < 3) {
      _showMessage('Please enter a valid request description.');
      return;
    }

    // ----------------------------------------------------------
    // GET JWT TOKEN
    // ----------------------------------------------------------

    final token = await AuthStorage.getToken();

    if (token == null || token.trim().isEmpty) {
      _showMessage(
        'Your login session has expired. Please login again.',
      );
      return;
    }

    // ----------------------------------------------------------
    // DEBUG
    // ----------------------------------------------------------

    debugPrint('============================================');
    debugPrint('ORGAFLOW CREATE REQUEST');
    debugPrint('URL: ${ApiConfig.baseUrl}/api/requests');
    debugPrint('Employee: $employeeName');
    debugPrint('Email: $employeeEmail');
    debugPrint('Department: $department');
    debugPrint('Asset ID: $assetId');
    debugPrint('Asset Name: $assetName');
    debugPrint('Priority: $selectedPriority');
    debugPrint('Token available: ${token.isNotEmpty}');
    debugPrint('============================================');

    if (mounted) {
      setState(() {
        isSubmitting = true;
      });
    }

    try {
      // --------------------------------------------------------
      // REQUEST BODY
      // --------------------------------------------------------

      final requestBody = {
        'asset_id': assetId,
        'asset_name': assetName,
        'asset_category': assetCategory,
        'asset_brand': assetBrand,
        'asset_model': assetModel,
        'department': department,
        'priority': selectedPriority,
        'description': description,
      };

      debugPrint(
        'REQUEST JSON: ${jsonEncode(requestBody)}',
      );

      // --------------------------------------------------------
      // API CALL
      // --------------------------------------------------------

      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}/api/requests',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer ${token.trim()}',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            ApiConfig.requestTimeout,
          );

      // --------------------------------------------------------
      // RESPONSE DEBUG
      // --------------------------------------------------------

      debugPrint('--------------------------------------------');
      debugPrint(
        'REQUEST STATUS: ${response.statusCode}',
      );
      debugPrint(
        'REQUEST BODY: ${response.body}',
      );
      debugPrint('--------------------------------------------');

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        String requestCode = 'Pending';

        try {
          final decoded = jsonDecode(response.body);

          if (decoded is Map<String, dynamic>) {
            final requestData = decoded['request'];

            if (requestData is Map<String, dynamic>) {
              final code = requestData['request_code'];

              if (code != null &&
                  code.toString().trim().isNotEmpty) {
                requestCode = code.toString().trim();
              }
            }
          }
        } catch (_) {
          // Keep default value.
        }

        if (!mounted) return;

        await _showSuccessDialog(
          requestCode,
        );

        return;
      }

      // --------------------------------------------------------
      // UNAUTHORIZED
      // --------------------------------------------------------

      if (response.statusCode == 401) {
        await AuthStorage.clear();

        _showMessage(
          'Login session expired. Please login again.',
        );

        return;
      }

      // --------------------------------------------------------
      // FORBIDDEN
      // --------------------------------------------------------

      if (response.statusCode == 403) {
        final message = _getErrorMessage(response);

        _showMessage(
          message.isNotEmpty
              ? message
              : 'You are not allowed to submit this request.',
        );

        return;
      }

      // --------------------------------------------------------
      // VALIDATION ERROR
      // --------------------------------------------------------

      if (response.statusCode == 422) {
        _showMessage(
          _getErrorMessage(response),
        );

        return;
      }

      // --------------------------------------------------------
      // SERVER ERROR
      // --------------------------------------------------------

      if (response.statusCode >= 500) {
        _showMessage(
          'Server error. Please check the FastAPI terminal.',
        );

        return;
      }

      // --------------------------------------------------------
      // OTHER ERROR
      // --------------------------------------------------------

      _showMessage(
        _getErrorMessage(response),
      );
    } on TimeoutException {
      debugPrint(
        'REQUEST ERROR: Connection timed out.',
      );

      _showMessage(
        'Server connection timed out. '
        'Make sure FastAPI is running and adb reverse is enabled.',
      );
    } on http.ClientException catch (e) {
      debugPrint(
        'HTTP CLIENT ERROR: $e',
      );

      _showMessage(
        'Unable to connect to Orgaflow server.',
      );
    } on FormatException catch (e) {
      debugPrint(
        'JSON FORMAT ERROR: $e',
      );

      _showMessage(
        'Invalid response received from server.',
      );
    } catch (e) {
      debugPrint(
        'REQUEST API ERROR: $e',
      );

      _showMessage(
        'Unable to connect to Orgaflow server. '
        'Please make sure the backend is running.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // SUCCESS DIALOG
  // ------------------------------------------------------------

  Future<void> _showSuccessDialog(
    String requestCode,
  ) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Request Submitted',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your asset request has been submitted successfully.',
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request ID',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      requestCode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Pending',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Return to previous page after successful submission.
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // ASSET IMAGE
  // ------------------------------------------------------------

  Widget _buildAssetImage() {
    if (assetImage.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.inventory_2_outlined,
          size: 70,
          color: Colors.grey,
        ),
      );
    }

    // Network image.
    if (assetImage.startsWith('http://') ||
        assetImage.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          assetImage,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.broken_image_outlined,
                size: 60,
                color: Colors.grey,
              ),
            );
          },
        ),
      );
    }

    // Local asset image.
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        assetImage,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // INFO ROW
  // ------------------------------------------------------------

  Widget _infoRow(
    String title,
    String value,
  ) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TEXT FIELD
  // ------------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF3B5BDB),
            width: 2,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEFF5),
      appBar: AppBar(
        title: const Text(
          'New Asset Request',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF3B5BDB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // EMPLOYEE
              // ------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Employee Information',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _infoRow(
                      'Name',
                      employeeName,
                    ),
                    _infoRow(
                      'Email',
                      employeeEmail,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // SELECTED ASSET
              // ------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Asset',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildAssetImage(),

                    const SizedBox(height: 16),

                    Text(
                      assetName.isEmpty
                          ? 'Unknown Asset'
                          : assetName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _infoRow(
                      'Asset ID',
                      assetId,
                    ),

                    _infoRow(
                      'Category',
                      assetCategory,
                    ),

                    _infoRow(
                      'Brand',
                      assetBrand,
                    ),

                    _infoRow(
                      'Model',
                      assetModel,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // REQUEST DETAILS
              // ------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request Details',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: departmentController,
                      label: 'Department',
                      hint: 'Enter your department',
                      icon: Icons.business_outlined,
                    ),

                    const SizedBox(height: 16),

                    // Priority
                    DropdownButtonFormField<String>(
                      initialValue: selectedPriority,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        prefixIcon:
                            const Icon(Icons.flag_outlined),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF3B5BDB),
                            width: 2,
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Normal',
                          child: Text('Normal'),
                        ),
                        DropdownMenuItem(
                          value: 'Urgent',
                          child: Text('Urgent'),
                        ),
                      ],
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              if (value == null) return;

                              setState(() {
                                selectedPriority = value;
                              });
                            },
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: descriptionController,
                      label: 'Reason / Description',
                      hint:
                          'Why do you need this asset?',
                      icon: Icons.description_outlined,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // SUBMIT BUTTON
              // ------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF3B5BDB),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send_rounded,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Submit Request',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  'Your request will be sent to the asset management team.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}