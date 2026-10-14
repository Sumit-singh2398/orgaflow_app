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
  // Android emulator ke liye.
  // Real phone par laptop ka local IP address use karein.
  // Deployed backend ho to yahan Render URL daalein.
  static const String baseUrl = 'http://10.0.2.2:8000';

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _employeeNameController =
      TextEditingController();

  final TextEditingController _employeeEmailController =
      TextEditingController();

  final TextEditingController _departmentController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  String? selectedAsset;
  bool isAssigning = false;

  Map<String, dynamic>? lastAssignment;

  // Demo assets. Production mein available assets
  // FastAPI backend se load karne chahiye.
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
    final availableAssets = assets
        .where((asset) => asset['status'] == 'Available')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildHeader(),
            const SizedBox(height: 22),

            _buildSummaryCards(availableAssets.length),
            const SizedBox(height: 22),

            _buildSectionTitle(
              'Select Asset',
              'Choose the available asset you want to assign.',
              Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 12),

            _buildAssetDropdown(availableAssets),

            if (selectedAssetData != null) ...[
              const SizedBox(height: 14),
              _buildSelectedAssetCard(selectedAssetData!),
            ],

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Employee Information',
              'Enter the exact email of the employee receiving this asset.',
              Icons.person_outline,
            ),
            const SizedBox(height: 14),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _employeeNameController,
                    label: 'Employee Full Name',
                    hint: 'e.g. Sumit Singh',
                    icon: Icons.badge_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter employee name';
                      }
                      if (value.trim().length < 2) {
                        return 'Enter a valid employee name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  _buildTextField(
                    controller: _employeeEmailController,
                    label: 'Employee Email Address',
                    hint: 'employee@company.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      final emailRegex =
                          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                      if (email.isEmpty) {
                        return 'Please enter employee email';
                      }
                      if (!emailRegex.hasMatch(email)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  _buildTextField(
                    controller: _departmentController,
                    label: 'Department',
                    hint: 'e.g. IT, HR, Finance',
                    icon: Icons.apartment_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter department';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Assignment Description',
                    hint:
                        'Reason, purpose, condition or usage instructions...',
                    icon: Icons.notes_outlined,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter assignment description';
                      }
                      if (value.trim().length < 5) {
                        return 'Please enter at least 5 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            _buildInfoBanner(),

            const SizedBox(height: 22),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isAssigning ? null : _assignAsset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5BDB),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.blueGrey.shade200,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: isAssigning
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.assignment_turned_in_outlined),
                label: Text(
                  isAssigning ? 'Assigning Asset...' : 'Confirm Assignment',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            if (lastAssignment != null) ...[
              const SizedBox(height: 24),
              _buildAssignmentConfirmation(lastAssignment!),
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
            color: const Color(0xFF3B5BDB).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.assignment_ind_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
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

  Widget _buildSummaryCards(int availableCount) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: 'Available Assets',
            value: '$availableCount',
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF3B5BDB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            title: 'Assignment',
            value: 'Manual',
            icon: Icons.person_search_outlined,
            color: const Color(0xFF0F9D80),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF182230),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF737D90),
            ),
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
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF3B5BDB).withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF3B5BDB)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF182230),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF737D90),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssetDropdown(List<Map<String, dynamic>> availableAssets) {
    return DropdownButtonFormField<String>(
      value: selectedAsset,
      isExpanded: true,
      decoration: _inputDecoration(
        label: 'Available Asset',
        icon: Icons.devices_other_outlined,
      ),
      hint: const Text('Select an asset'),
      items: availableAssets.map((asset) {
        return DropdownMenuItem<String>(
          value: asset['id'] as String,
          child: Text(
            '${asset['id']} - ${asset['name']}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedAsset = value;
          lastAssignment = null;
        });
      },
      validator: (value) {
        if (value == null) return 'Please select an asset';
        return null;
      },
    );
  }

  Widget _buildSelectedAssetCard(Map<String, dynamic> asset) {
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
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B5BDB).withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.devices_outlined,
                  color: Color(0xFF3B5BDB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset['name'].toString(),
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
                        color: Color(0xFF737D90),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle,
                color: Color(0xFF0F9D80),
              ),
            ],
          ),
          const Divider(height: 25),
          _detailRow('Brand', asset['brand'].toString()),
          _detailRow('Specifications', asset['specification'].toString()),
          _detailRow('Location', asset['location'].toString()),
          _detailRow('Status', asset['status'].toString()),
        ],
      ),
    );
  }

  Widget _buildTextField({
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
      decoration: _inputDecoration(
        label: label,
        icon: icon,
      ).copyWith(
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

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
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
        borderSide: const BorderSide(
          color: Color(0xFF3B5BDB),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
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
          Icon(
            Icons.info_outline,
            color: Color(0xFF3B5BDB),
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Check the employee email carefully. The backend must verify '
              'the email against the registered employee account before '
              'saving the assignment.',
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
              style: const TextStyle(
                color: Color(0xFF737D90),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF182230),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _assignAsset() async {
    FocusScope.of(context).unfocus();

    if (selectedAsset == null) {
      _showMessage('Please select an available asset.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final asset = selectedAssetData;
    if (asset == null) {
      _showMessage('Selected asset was not found.');
      return;
    }

    if (asset['status'] != 'Available') {
      _showMessage('This asset is no longer available.');
      return;
    }

    final token = widget.userData?['access_token'] ??
        widget.userData?['token'];

    final payload = <String, dynamic>{
      'asset_code': asset['id'],
      'asset_name': asset['name'],
      'employee_name': _employeeNameController.text.trim(),
      'employee_email': _employeeEmailController.text.trim().toLowerCase(),
      'department': _departmentController.text.trim(),
      'description': _descriptionController.text.trim(),
    };

    setState(() {
      isAssigning = true;
      lastAssignment = null;
    });

    try {
      // This endpoint must exist in your FastAPI main.py.
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/assets/assign'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.toString().isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      Map<String, dynamic> responseData = {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (_) {
        // The server may return a non-JSON error response.
      }

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          lastAssignment = {
            ...payload,
            'assignment_date': DateTime.now().toLocal().toString().split('.').first,
            'assignment_id': responseData['assignment_id'] ??
                responseData['id'] ??
                responseData['assignment_code'] ??
                'Saved by server',
            'status': responseData['status'] ?? 'Assigned',
          };

          // Update local demo status to prevent selecting it again
          // during this screen session. The database remains authoritative.
          asset['status'] = 'Assigned';
          selectedAsset = null;
        });

        _showMessage(
          'Assignment saved successfully.',
          isError: false,
        );
      } else {
        final detail = responseData['detail'] ??
            responseData['message'] ??
            'Server rejected the assignment.';

        _showMessage(
          'Assignment failed (${response.statusCode}): $detail',
        );
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Could not connect to the backend. Check the server URL and '
        'ensure the assignment API is running.',
      );
    } finally {
      if (mounted) {
        setState(() => isAssigning = false);
      }
    }
  }

  Widget _buildAssignmentConfirmation(Map<String, dynamic> data) {
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
              Icon(
                Icons.check_circle,
                color: Color(0xFF0F9D80),
                size: 25,
              ),
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
            'The server accepted this assignment. Review the saved details below.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF737D90),
            ),
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
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final details = data.entries
                    .map((entry) => '${entry.key}: ${entry.value}')
                    .join('\n');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Assignment details ready to copy.'),
                  ),
                );
                // Copy/share integration can be added if required.
                debugPrint(details);
              },
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('View Details in Debug Log'),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB42318)
            : const Color(0xFF0F9D80),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
