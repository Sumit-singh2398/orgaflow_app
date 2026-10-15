import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssetManagerAssignPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerAssignPage({
    super.key,
    this.userData,
  });

  @override
  State<AssetManagerAssignPage> createState() =>
      _AssetManagerAssignPageState();
}

class _AssetManagerAssignPageState
    extends State<AssetManagerAssignPage> {
  // Android emulator:
  static const String baseUrl = 'http://10.0.2.2:8000';

  // Real phone par laptop ka Wi-Fi IP use karein, e.g.:
  // static const String baseUrl = 'http://192.168.1.5:8000';
  //
  // 127.0.0.1 phone ke andar phone ko hi refer karta hai.
  // Laptop browser mein 127.0.0.1 kaam karta hai, lekin
  // physical phone se laptop access karne ke liye nahi.

  static const Color primary = Color(0xFF3B5BDB);
  static const Color background = Color(0xFFF4F6FB);
  static const Color textDark = Color(0xFF182230);
  static const Color textMuted = Color(0xFF737D90);
  static const Color success = Color(0xFF0F9D80);

  final _formKey = GlobalKey<FormState>();

  final _employeeNameController = TextEditingController();
  final _employeeEmailController = TextEditingController();
  final _departmentController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? selectedAsset;
  bool isAssigning = false;
  Map<String, dynamic>? lastAssignment;

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

  Map<String, dynamic>? get selectedAssetData {
    for (final asset in assets) {
      if (asset['id'] == selectedAsset) return asset;
    }
    return null;
  }

  List<Map<String, dynamic>> get availableAssets {
    return assets
        .where((asset) => asset['status'] == 'Available')
        .toList();
  }

  @override
  void initState() {
    super.initState();

    final user = widget.userData ?? {};

    _employeeNameController.text =
        (user['name'] ?? user['full_name'] ?? '').toString();

    _employeeEmailController.text =
        (user['email'] ?? '').toString();

    _departmentController.text =
        (user['department'] ?? '').toString();
  }

  @override
  void dispose() {
    _employeeNameController.dispose();
    _employeeEmailController.dispose();
    _departmentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSummary(),
            const SizedBox(height: 24),
            _buildSectionTitle(
              'Select Asset',
              'Choose an asset that is currently available.',
              Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 12),
            _buildAssetDropdown(),
            if (selectedAssetData != null) ...[
              const SizedBox(height: 12),
              _buildSelectedAsset(selectedAssetData!),
            ],
            const SizedBox(height: 24),
            _buildSectionTitle(
              'Employee Information',
              'Confirm the employee details before assigning.',
              Icons.person_outline,
            ),
            const SizedBox(height: 14),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildField(
                    controller: _employeeNameController,
                    label: 'Employee Full Name',
                    hint: 'Enter employee name',
                    icon: Icons.badge_outlined,
                    validator: (value) {
                      if (value == null || value.trim().length < 2) {
                        return 'Enter a valid employee name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _employeeEmailController,
                    label: 'Employee Email Address',
                    hint: 'employee@company.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(email)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _departmentController,
                    label: 'Department',
                    hint: 'IT, HR, Finance...',
                    icon: Icons.apartment_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter the department';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _descriptionController,
                    label: 'Assignment Description',
                    hint: 'Purpose, condition or usage instructions',
                    icon: Icons.notes_outlined,
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
            _buildInfoBanner(),
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isAssigning ? null : _assignAsset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primary.withValues(alpha: 0.55),
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
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.assignment_turned_in_outlined),
                label: Text(
                  isAssigning ? 'Saving Assignment...' : 'Confirm Assignment',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (isAssigning) ...[
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Contacting server. Please wait...',
                  style: TextStyle(fontSize: 12, color: textMuted),
                ),
              ),
            ],
            if (lastAssignment != null) ...[
              const SizedBox(height: 22),
              _buildConfirmation(lastAssignment!),
            ],
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B5BDB), Color(0xFF657CF0)],
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
                  'Allocate company assets to employees',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            'Available Assets',
            '${availableAssets.length}',
            Icons.inventory_2_outlined,
            primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            'Assignment',
            'Manual',
            Icons.person_search_outlined,
            success,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
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
        border: Border.all(color: const Color(0xFFE8ECF4)),
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
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
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

  Widget _buildAssetDropdown() {
    final items = availableAssets;

    // Agar selected asset available nahi raha, dropdown ko safe rakhein.
    final validValue = items.any((a) => a['id'] == selectedAsset)
        ? selectedAsset
        : null;

    return DropdownButtonFormField<String>(
      value: validValue,
      isExpanded: true,
      decoration: _inputDecoration(
        'Available Asset',
        Icons.devices_other_outlined,
      ),
      hint: const Text('Select an asset'),
      items: items.map((asset) {
        return DropdownMenuItem<String>(
          value: asset['id'] as String,
          child: Text(
            '${asset['id']} - ${asset['name']}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: isAssigning
          ? null
          : (value) {
              setState(() {
                selectedAsset = value;
                lastAssignment = null;
              });
            },
      validator: (value) {
        if (value == null) return 'Please select an available asset';
        return null;
      },
    );
  }

  Widget _buildSelectedAsset(Map<String, dynamic> asset) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFDCE4FF)),
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
                child: const Icon(Icons.devices_outlined, color: primary),
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
              const Icon(Icons.check_circle, color: success),
            ],
          ),
          const Divider(height: 25),
          _detailRow('Brand', '${asset['brand']}'),
          _detailRow('Specifications', '${asset['specification']}'),
          _detailRow('Location', '${asset['location']}'),
          _detailRow('Status', '${asset['status']}'),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: keyboardType == TextInputType.emailAddress
          ? TextCapitalization.none
          : TextCapitalization.words,
      enabled: !isAssigning,
      decoration: _inputDecoration(label, icon).copyWith(
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

  InputDecoration _inputDecoration(String label, IconData icon) {
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
        borderSide: const BorderSide(color: Color(0xFFE1E6EF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE1E6EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9E4FF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: primary, size: 21),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'The server must verify the employee account and asset '
              'availability before saving the assignment.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF34456D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: textMuted),
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

    if (selectedAsset == null) {
      _showMessage('Please select an available asset.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final asset = selectedAssetData;
    if (asset == null || asset['status'] != 'Available') {
      _showMessage('This asset is not available. Refresh and try again.');
      return;
    }

    final name = _employeeNameController.text.trim();
    final email = _employeeEmailController.text.trim().toLowerCase();
    final department = _departmentController.text.trim();
    final description = _descriptionController.text.trim();

    final token = widget.userData?['access_token'] ??
        widget.userData?['token'];

    final payload = <String, dynamic>{
      'asset_code': asset['id'],
      'asset_name': asset['name'],
      'employee_name': name,
      'employee_email': email,
      'department': department,
      'description': description,
    };

    setState(() {
      isAssigning = true;
      lastAssignment = null;
    });

    try {
      final uri = Uri.parse('$baseUrl/api/assets/assign');

      debugPrint('ORGAFLOW ASSIGN: POST $uri');
      debugPrint('ORGAFLOW ASSIGN: payload = ${jsonEncode(payload)}');

      final response = await http
          .post(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              if (token != null && token.toString().trim().isNotEmpty)
                'Authorization': 'Bearer ${token.toString().trim()}',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 12));

      debugPrint('ORGAFLOW ASSIGN: status = ${response.statusCode}');
      debugPrint('ORGAFLOW ASSIGN: response = ${response.body}');

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      final Map<String, dynamic> responseData =
          decoded is Map<String, dynamic> ? decoded : {};

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Sirf server success par local UI status update hota hai.
        setState(() {
          asset['status'] = 'Assigned';
          selectedAsset = null;

          lastAssignment = {
            ...payload,
            'assignment_id': responseData['assignment_id'] ??
                responseData['id'] ??
                responseData['assignment_code'] ??
                'Created',
            'status': responseData['status'] ?? 'Assigned',
            'assignment_date': responseData['assigned_at'] ??
                responseData['created_at'] ??
                DateTime.now().toLocal().toString().split('.').first,
          };
        });

        _showMessage(
          'Asset assignment saved successfully.',
          isError: false,
        );
      } else {
        final detail = responseData['detail'] ??
            responseData['message'] ??
            response.body;

        _showMessage(
          'Assignment failed (${response.statusCode}): '
          '${detail.toString().length > 220 ? detail.toString().substring(0, 220) : detail}',
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      _showMessage(
        'Server response timed out. Check main.py, database and API logs.',
      );
    } on http.ClientException catch (error) {
      if (!mounted) return;
      debugPrint('ORGAFLOW ASSIGN connection error: $error');
      _showMessage(
        'Cannot reach backend. Check Base URL, Wi-Fi and server status.',
      );
    } catch (error, stackTrace) {
      debugPrint('ORGAFLOW ASSIGN error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      _showMessage('Unexpected error: $error');
    } finally {
      if (mounted) {
        setState(() => isAssigning = false);
      }
    }
  }

  Widget _buildConfirmation(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBCE7D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: success, size: 25),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Assignment Confirmation',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'The server accepted the request. Saved details:',
            style: TextStyle(fontSize: 12, color: textMuted),
          ),
          const Divider(height: 25),
          _detailRow('Assignment ID', '${data['assignment_id']}'),
          _detailRow('Asset ID', '${data['asset_code']}'),
          _detailRow('Asset Name', '${data['asset_name']}'),
          _detailRow('Employee', '${data['employee_name']}'),
          _detailRow('Email', '${data['employee_email']}'),
          _detailRow('Department', '${data['department']}'),
          _detailRow('Description', '${data['description']}'),
          _detailRow('Status', '${data['status']}'),
          _detailRow('Assigned At', '${data['assignment_date']}'),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              final details = data.entries
                  .map((entry) => '${entry.key}: ${entry.value}')
                  .join('\n');
              debugPrint('ORGAFLOW ASSIGNMENT DETAILS\n$details');
              _showMessage('Assignment details printed in Debug Console.',
                  isError: false);
            },
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('View Details in Debug Log'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? const Color(0xFFB42318) : success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
  }
}