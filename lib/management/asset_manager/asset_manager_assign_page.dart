import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssetManagerAssignPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerAssignPage({super.key, this.userData});

  @override
  State<AssetManagerAssignPage> createState() =>
      _AssetManagerAssignPageState();
}

class _AssetManagerAssignPageState extends State<AssetManagerAssignPage> {
  // Android emulator. For a physical phone, use your computer's LAN IP.
  static const String baseUrl = 'https://orgaflow-app.onrender.com';

  static const Color primary = Color(0xFF3B5BDB);
  static const Color background = Color(0xFFF4F6FB);
  static const Color textDark = Color(0xFF182230);
  static const Color textMuted = Color(0xFF737D90);
  static const Color success = Color(0xFF0F9D80);
  static const Color danger = Color(0xFFB42318);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? selectedAssetCode;
  bool isAssigning = false;
  Map<String, dynamic>? lastAssignment;

  // Demo assets. Connect these to your real asset API for production.
  final List<Map<String, dynamic>> assets = [
    {
      'id': 'AST-001',
      'name': 'Dell Latitude 5420',
      'category': 'Laptop',
      'brand': 'Dell',
      'specification': 'Intel Core i5, 16 GB RAM, 512 GB SSD',
      'location': 'Noida Office',
      'status': 'Available',
    },
    {
      'id': 'AST-002',
      'name': 'Samsung Galaxy A55',
      'category': 'Smartphone',
      'brand': 'Samsung',
      'specification': '8 GB RAM, 128 GB Storage',
      'location': 'Noida Office',
      'status': 'Available',
    },
    {
      'id': 'AST-003',
      'name': 'Canon DSLR',
      'category': 'Camera',
      'brand': 'Canon',
      'specification': 'Professional DSLR Camera',
      'location': 'Noida Office',
      'status': 'Available',
    },
    {
      'id': 'AST-004',
      'name': 'Epson Projector',
      'category': 'Projector',
      'brand': 'Epson',
      'specification': 'Office Presentation Projector',
      'location': 'Conference Room',
      'status': 'Available',
    },
    {
      'id': 'AST-005',
      'name': 'Dell Monitor',
      'category': 'Monitor',
      'brand': 'Dell',
      'specification': '24-inch Full HD Monitor',
      'location': 'Noida Office',
      'status': 'Available',
    },
  ];

  Map<String, dynamic>? get selectedAsset {
    for (final asset in assets) {
      if (asset['id'] == selectedAssetCode) return asset;
    }
    return null;
  }

  List<Map<String, dynamic>> get availableAssets =>
      assets.where((a) => a['status'] == 'Available').toList();

  @override
  void initState() {
    super.initState();

    final user = widget.userData ?? {};

    _nameController.text =
        (user['name'] ?? user['full_name'] ?? '').toString();
    _emailController.text = (user['email'] ?? '').toString();
    _departmentController.text = (user['department'] ?? '').toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = selectedAsset;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Assign Asset',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        foregroundColor: Colors.white,
        backgroundColor: primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'Available',
                    '${availableAssets.length}',
                    Icons.inventory_2_outlined,
                    primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    'Workflow',
                    'Email alert',
                    Icons.mark_email_read_outlined,
                    success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle(
              'Select Asset',
              'Choose an asset that is currently available.',
              Icons.devices_other_outlined,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: availableAssets.any(
                (a) => a['id'] == selectedAssetCode,
              )
                  ? selectedAssetCode
                  : null,
              isExpanded: true,
              decoration: _decoration(
                'Available Asset',
                Icons.inventory_2_outlined,
              ),
              hint: const Text('Choose an asset'),
              items: availableAssets.map((a) {
                return DropdownMenuItem<String>(
                  value: a['id'] as String,
                  child: Text(
                    '${a['id']} - ${a['name']}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: isAssigning
                  ? null
                  : (value) {
                      setState(() {
                        selectedAssetCode = value;
                        lastAssignment = null;
                      });
                    },
            ),
            if (asset != null) ...[
              const SizedBox(height: 12),
              _assetCard(asset),
            ],
            const SizedBox(height: 24),
            _sectionTitle(
              'Employee Information',
              'The assignment notification will be sent to this email.',
              Icons.person_outline,
            ),
            const SizedBox(height: 14),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _field(
                    _nameController,
                    'Employee Full Name',
                    'Enter employee name',
                    Icons.badge_outlined,
                    validator: (value) {
                      if (value == null || value.trim().length < 2) {
                        return 'Enter a valid employee name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 13),
                  _field(
                    _emailController,
                    'Employee Email Address',
                    'employee@company.com',
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = (value ?? '').trim();
                      final valid = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(email);

                      return valid ? null : 'Enter a valid email address';
                    },
                  ),
                  const SizedBox(height: 13),
                  _field(
                    _departmentController,
                    'Department',
                    'IT, HR, Finance...',
                    Icons.apartment_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter department';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 13),
                  _field(
                    _descriptionController,
                    'Assignment Description',
                    'Purpose, condition or usage instructions',
                    Icons.notes_outlined,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().length < 5) {
                        return 'Enter at least 5 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _infoBanner(),
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isAssigning ? null : _assignAsset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      primary.withValues(alpha: 0.55),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: isAssigning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.assignment_turned_in_outlined,
                      ),
                label: Text(
                  isAssigning
                      ? 'Saving and Sending Email...'
                      : 'Confirm Assignment',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (isAssigning)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Center(
                  child: Text(
                    'Please wait for the server response.',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            if (lastAssignment != null) ...[
              const SizedBox(height: 22),
              _confirmation(lastAssignment!),
            ],
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B5BDB),
            Color(0xFF657CF0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.assignment_ind_outlined,
            color: Colors.white,
            size: 42,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assign Asset',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Allocate an asset and notify the employee by email',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE8ECF4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _assetCard(Map<String, dynamic> asset) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFDCE4FF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.devices_outlined,
                  color: primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${asset['name']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${asset['id']} • ${asset['category']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle,
                color: success,
              ),
            ],
          ),
          const Divider(height: 25),
          _detail('Brand', '${asset['brand']}'),
          _detail('Specifications', '${asset['specification']}'),
          _detail('Location', '${asset['location']}'),
          _detail('Status', '${asset['status']}'),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: !isAssigning,
      textCapitalization: keyboardType == TextInputType.emailAddress
          ? TextCapitalization.none
          : TextCapitalization.words,
      decoration: _decoration(label, icon).copyWith(
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
      ),
      validator: validator,
      onChanged: (_) {
        if (lastAssignment != null) {
          setState(() => lastAssignment = null);
        }
      },
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 21),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE1E6EF),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE1E6EF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD9E4FF),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            color: primary,
            size: 21,
          ),
          SizedBox(width: 10),
         Expanded(child: Text(
         'After confirming the assignment, an email notification will be sent to the employee with the asset details and instructions.',),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _assignAsset() async {
    if (isAssigning) return;

    FocusScope.of(context).unfocus();

    final asset = selectedAsset;

    if (asset == null) {
      _message('Please select an available asset.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final token =
        widget.userData?['access_token'] ?? widget.userData?['token'];

    if (token == null || token.toString().trim().isEmpty) {
      _message('Login session token missing. Please log in again.');
      return;
    }

    final payload = <String, dynamic>{
      'asset_code': asset['id'],
      'asset_name': asset['name'],
      'employee_name': _nameController.text.trim(),
      'employee_email': _emailController.text.trim().toLowerCase(),
      'department': _departmentController.text.trim(),
      'description': _descriptionController.text.trim(),
    };

    setState(() {
      isAssigning = true;
      lastAssignment = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/assets/assign'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${token.toString().trim()}',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 25));

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      final data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final emailSent = data['email_sent'] == true;

        setState(() {
          asset['status'] = 'Assigned';
          selectedAssetCode = null;

          lastAssignment = {
            ...payload,
            'assignment_id': data['assignment_id'] ?? 'Created',
            'status': data['status'] ?? 'Assigned',
            'assigned_at': data['assigned_at'] ??
                DateTime.now().toUtc().toIso8601String(),
            'email_sent': emailSent,
            'message': data['message'] ?? 'Assignment saved.',
          };
        });

        _message(
          emailSent
              ? 'Assignment saved. Email sent to ${payload['employee_email']}.'
              : 'Assignment saved, but email was not sent. Check SMTP settings.',
          isError: !emailSent,
        );
      } else {
        final detail =
            data['detail'] ?? data['message'] ?? response.body;

        _message(
          'Assignment failed (${response.statusCode}): $detail',
        );
      }
    } on TimeoutException {
      if (mounted) {
        _message(
          'Request timed out. Check backend and SMTP connection.',
        );
      }
    } on http.ClientException catch (error) {
      debugPrint('Asset assignment connection error: $error');

      if (mounted) {
        _message(
          'Cannot reach backend. Check baseUrl and server status.',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Asset assignment error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        _message('Unexpected error: $error');
      }
    } finally {
      if (mounted) {
        setState(() => isAssigning = false);
      }
    }
  }

  Widget _confirmation(Map<String, dynamic> data) {
    final emailSent = data['email_sent'] == true;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: emailSent
              ? const Color(0xFFBCE7D8)
              : const Color(0xFFFFD6A5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                emailSent
                    ? Icons.check_circle
                    : Icons.warning_amber_rounded,
                color: emailSent
                    ? success
                    : const Color(0xFFB54708),
                size: 25,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  emailSent
                      ? 'Assignment Confirmed'
                      : 'Assignment Saved — Email Pending',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${data['message']}',
            style: const TextStyle(
              fontSize: 12,
              color: textMuted,
              height: 1.4,
            ),
          ),
          const Divider(height: 25),
          _detail('Assignment ID', '${data['assignment_id']}'),
          _detail('Asset ID', '${data['asset_code']}'),
          _detail('Asset Name', '${data['asset_name']}'),
          _detail('Employee', '${data['employee_name']}'),
          _detail('Email', '${data['employee_email']}'),
          _detail('Department', '${data['department']}'),
          _detail('Description', '${data['description']}'),
          _detail('Status', '${data['status']}'),
          _detail('Assigned At', '${data['assigned_at']}'),
          _detail('Email Sent', emailSent ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  void _message(String message, {bool isError = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? danger : success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
  }
}