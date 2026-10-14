import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

class AssetManagerScanPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerScanPage({
    super.key,
    this.userData,
  });

  @override
  State<AssetManagerScanPage> createState() =>
      _AssetManagerScanPageState();
}

class _AssetManagerScanPageState extends State<AssetManagerScanPage> {
  static const Color primary = Color(0xFF3B5BDB);
  static const Color background = Color(0xFFF4F6FB);
  static const Color dark = Color(0xFF17233C);
  static const Color muted = Color(0xFF7B879B);
  static const Color border = Color(0xFFE7EBF3);

  // Android emulator URL.
  // Real phone par laptop ka LAN IP ya deployed backend URL use karein.
  static const String baseUrl = 'http://10.0.2.2:8000';

  final TextEditingController codeController = TextEditingController();

  Map<String, dynamic>? selectedAsset;
  bool searched = false;
  bool isLoading = false;
  bool isAssigning = false;

  // Demo records. Real assets backend se fetch hone chahiye.
  final List<Map<String, dynamic>> assets = [
    {
      'code': 'AST-001',
      'barcode': 'ORG-AST-001',
      'name': 'Dell Latitude 5420',
      'category': 'Laptop',
      'brand': 'Dell',
      'model': 'Latitude 5420',
      'serial': 'DLL-5420-001',
      'location': 'Noida Office',
      'department': 'Engineering',
      'assignedTo': 'Rahul Sharma',
      'employeeEmail': 'rahul@example.com',
      'status': 'Assigned',
      'condition': 'Good',
      'icon': Icons.laptop_mac_rounded,
    },
    {
      'code': 'AST-002',
      'barcode': 'ORG-AST-002',
      'name': 'Samsung Galaxy A55',
      'category': 'Smartphone',
      'brand': 'Samsung',
      'model': 'Galaxy A55',
      'serial': 'SAM-A55-002',
      'location': 'Noida Office',
      'department': 'Marketing',
      'assignedTo': 'Unassigned',
      'employeeEmail': '',
      'status': 'Available',
      'condition': 'Excellent',
      'icon': Icons.smartphone_rounded,
    },
    {
      'code': 'AST-003',
      'barcode': 'ORG-AST-003',
      'name': 'Epson Projector',
      'category': 'Projector',
      'brand': 'Epson',
      'model': 'EB Series',
      'serial': 'EPS-003',
      'location': 'Conference Room',
      'department': 'Administration',
      'assignedTo': 'Unassigned',
      'employeeEmail': '',
      'status': 'Maintenance',
      'condition': 'Under repair',
      'icon': Icons.videocam_rounded,
    },
    {
      'code': 'AST-004',
      'barcode': 'ORG-AST-004',
      'name': 'Canon DSLR Camera',
      'category': 'Camera',
      'brand': 'Canon',
      'model': 'EOS Series',
      'serial': 'CAN-004',
      'location': 'Media Room',
      'department': 'Marketing',
      'assignedTo': 'Unassigned',
      'employeeEmail': '',
      'status': 'Available',
      'condition': 'Good',
      'icon': Icons.camera_alt_rounded,
    },
    {
      'code': 'AST-005',
      'barcode': 'ORG-AST-005',
      'name': 'Dell 24-inch Monitor',
      'category': 'Monitor',
      'brand': 'Dell',
      'model': 'P2422H',
      'serial': 'DEL-MON-005',
      'location': 'Noida Office',
      'department': 'Engineering',
      'assignedTo': 'Unassigned',
      'employeeEmail': '',
      'status': 'Available',
      'condition': 'Good',
      'icon': Icons.desktop_windows_rounded,
    },
  ];

  String? get token {
    final value = widget.userData?['access_token'] ??
        widget.userData?['token'];
    if (value == null || value.toString().isEmpty) return null;
    return value.toString();
  }

  Map<String, String> get requestHeaders => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _findLocalAsset(String value) {
    final query = value.trim().toLowerCase();

    for (final asset in assets) {
      final candidates = [
        asset['code'],
        asset['barcode'],
        asset['serial'],
      ];

      if (candidates.any(
        (candidate) => candidate.toString().trim().toLowerCase() == query,
      )) {
        return asset;
      }
    }

    return null;
  }

  Future<void> _lookupAsset(String value) async {
    final query = value.trim();

    if (query.isEmpty) {
      _message('Enter or scan a barcode first.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      searched = true;
      selectedAsset = null;
    });

    // First check the demo records.
    final localAsset = _findLocalAsset(query);

    if (localAsset != null) {
      if (!mounted) return;
      setState(() {
        selectedAsset = localAsset;
        isLoading = false;
      });
      return;
    }

    // Production lookup: this endpoint must be implemented in FastAPI.
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/api/assets/barcode/${Uri.encodeComponent(query)}',
            ),
            headers: requestHeaders,
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final data = decoded is Map<String, dynamic> &&
                decoded['asset'] is Map<String, dynamic>
            ? decoded['asset'] as Map<String, dynamic>
            : decoded;

        if (data is Map<String, dynamic>) {
          setState(() {
            selectedAsset = _normalizeAsset(data, query);
          });
        } else {
          _message('Unexpected asset data returned by the server.');
        }
      } else if (response.statusCode == 404) {
        _message(
          'Barcode not registered. Add this product to Orgaflow first.',
        );
      } else {
        _message(
          'Asset lookup failed (${response.statusCode}). '
          'Check the backend endpoint.',
        );
      }
    } on TimeoutException {
      if (mounted) {
        _message('Server timeout. Please try again.');
      }
    } catch (_) {
      if (mounted) {
        _message(
          'Could not connect to the asset API. '
          'Check your server URL and connection.',
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Map<String, dynamic> _normalizeAsset(
    Map<String, dynamic> data,
    String barcode,
  ) {
    final result = Map<String, dynamic>.from(data);

    // Supports common backend field names.
    result['code'] ??= result['asset_code'] ?? result['asset_tag'] ?? barcode;
    result['barcode'] ??= barcode;
    result['name'] ??= result['asset_name'] ?? 'Registered Asset';
    result['category'] ??= result['asset_category'] ?? 'General';
    result['brand'] ??= 'Not provided';
    result['model'] ??= 'Not provided';
    result['serial'] ??= result['serial_number'] ?? barcode;
    result['location'] ??= 'Not provided';
    result['department'] ??= 'Not assigned';
    result['assignedTo'] ??= result['employee_name'] ?? 'Unassigned';
    result['employeeEmail'] ??= result['employee_email'] ?? '';
    result['status'] ??= 'Available';
    result['condition'] ??= 'Not inspected';
    result['icon'] = _iconForCategory(result['category'].toString());

    return result;
  }

  Future<void> _openCameraScanner() async {
    var handled = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: MediaQuery.of(dialogContext).size.height * 0.70,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  color: dark,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Scan Asset Barcode',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        onDetect: (capture) {
                          if (handled || capture.barcodes.isEmpty) return;

                          final value = capture.barcodes.first.rawValue;
                          if (value == null || value.trim().isEmpty) return;

                          handled = true;
                          Navigator.pop(dialogContext);
                          codeController.text = value.trim();
                          _lookupAsset(value.trim());
                        },
                      ),
                      IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 260,
                            height: 160,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF8DABFF),
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 20,
                        right: 20,
                        bottom: 24,
                        child: Text(
                          'Align the barcode or QR code inside the frame',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _clearSearch() {
    setState(() {
      codeController.clear();
      selectedAsset = null;
      searched = false;
    });
  }

  Future<void> _assignAsset() async {
    final asset = selectedAsset;
    if (asset == null) return;

    if (asset['status'].toString().toLowerCase() != 'available') {
      _message('Only available assets can be assigned.');
      return;
    }

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _EmployeeAssignmentDialog(),
    );

    if (result == null || !mounted) return;

    setState(() => isAssigning = true);

    final payload = {
      'asset_code': asset['code'],
      'asset_name': asset['name'],
      'barcode': asset['barcode'],
      'employee_name': result['name'],
      'employee_email': result['email']!.trim().toLowerCase(),
      'department': result['department'],
      'description': result['description'],
    };

    try {
      // This endpoint must verify the registered employee by email,
      // save the assignment in PostgreSQL and update the asset status.
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/assets/assign'),
            headers: requestHeaders,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;

      Map<String, dynamic> responseData = {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (_) {}

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          asset['status'] = 'Assigned';
          asset['assignedTo'] = result['name'];
          asset['employeeEmail'] = result['email']!.trim().toLowerCase();
          asset['department'] = result['department'];
        });

        _showAssignmentSuccess(asset, result, responseData);
      } else {
        final detail = responseData['detail'] ??
            responseData['message'] ??
            'The server could not save this assignment.';

        _message('Assignment failed: $detail');
      }
    } on TimeoutException {
      if (mounted) _message('Assignment request timed out. Try again.');
    } catch (_) {
      if (mounted) {
        _message(
          'Could not connect to the assignment API. '
          'The asset was not confirmed as assigned.',
        );
      }
    } finally {
      if (mounted) setState(() => isAssigning = false);
    }
  }

  void _showAssignmentSuccess(
    Map<String, dynamic> asset,
    Map<String, String> employee,
    Map<String, dynamic> response,
  ) {
    final assignmentId = response['assignment_id'] ??
        response['id'] ??
        'Saved by server';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF16845B),
          size: 48,
        ),
        title: const Text(
          'Asset Assigned',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The server accepted the assignment.',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 16),
            _successRow('Assignment ID', '$assignmentId'),
            _successRow('Asset', '${asset['name']}'),
            _successRow('Asset ID', '${asset['code']}'),
            _successRow('Employee', '${employee['name']}'),
            _successRow('Email', '${employee['email']}'),
            _successRow('Department', '${employee['department']}'),
            _successRow('Description', '${employee['description']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _successRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: dark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullDetails(Map<String, dynamic> asset) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    asset['icon'] as IconData,
                    color: primary,
                    size: 34,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      asset['name'].toString(),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: dark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...[
                ['Asset ID', asset['code']],
                ['Barcode', asset['barcode']],
                ['Category', asset['category']],
                ['Brand', asset['brand']],
                ['Model', asset['model']],
                ['Serial number', asset['serial']],
                ['Location', asset['location']],
                ['Department', asset['department']],
                ['Assigned employee', asset['assignedTo']],
                ['Employee email', asset['employeeEmail']],
                ['Status', asset['status']],
                ['Condition', asset['condition']],
              ].map(
                (row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 125,
                        child: Text(
                          row[0].toString(),
                          style: const TextStyle(
                            color: muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          row[1]?.toString() ?? 'Not available',
                          style: const TextStyle(
                            color: dark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (asset['status'].toString().toLowerCase() == 'available') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _assignAsset();
                    },
                    icon: const Icon(Icons.assignment_ind_outlined),
                    label: const Text('Assign to Employee'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'laptop':
        return Icons.laptop_mac_rounded;
      case 'smartphone':
      case 'mobile':
        return Icons.smartphone_rounded;
      case 'projector':
        return Icons.videocam_rounded;
      case 'camera':
        return Icons.camera_alt_rounded;
      case 'monitor':
        return Icons.desktop_windows_rounded;
      default:
        return Icons.devices_other_rounded;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF16845B);
      case 'assigned':
        return primary;
      case 'maintenance':
        return const Color(0xFFCC7A12);
      default:
        return muted;
    }
  }

  Color _statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFFE5F7EF);
      case 'assigned':
        return const Color(0xFFEBEFFF);
      case 'maintenance':
        return const Color(0xFFFFF2DF);
      default:
        return const Color(0xFFF0F2F6);
    }
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: _statusBackground(status),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: muted, fontSize: 11),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: dark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF304DC8), Color(0xFF5475F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(height: 16),
          const Text(
            'Smart Asset Scanner',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan a registered asset tag to inspect its details '
            'and assign it to an employee.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _openCameraScanner,
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text(
                'Scan Barcode / QR Code',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: codeController,
      textCapitalization: TextCapitalization.characters,
      onSubmitted: _lookupAsset,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Asset ID, serial number or barcode',
        prefixIcon: const Icon(Icons.search_rounded, color: primary),
        suffixIcon: codeController.text.isEmpty
            ? null
            : IconButton(
                onPressed: _clearSearch,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  asset['icon'] as IconData,
                  color: primary,
                  size: 27,
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
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${asset['code']} • ${asset['category']}',
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              _statusBadge(asset['status'].toString()),
            ],
          ),
          const Divider(height: 28, color: border),
          _detailItem(
            Icons.qr_code_rounded,
            'Barcode / serial',
            '${asset['barcode']} / ${asset['serial']}',
          ),
          const SizedBox(height: 17),
          _detailItem(
            Icons.person_outline_rounded,
            'Assigned to',
            '${asset['assignedTo']}',
          ),
          const SizedBox(height: 17),
          _detailItem(
            Icons.location_on_outlined,
            'Location',
            '${asset['location']}',
          ),
          const SizedBox(height: 17),
          _detailItem(
            Icons.business_outlined,
            'Department',
            '${asset['department']}',
          ),
          const SizedBox(height: 17),
          _detailItem(
            Icons.verified_outlined,
            'Condition',
            '${asset['condition']}',
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => _showFullDetails(asset),
              child: const Text('View Full Details'),
            ),
          ),
          if (asset['status'].toString().toLowerCase() == 'available') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isAssigning ? null : _assignAsset,
                icon: const Icon(Icons.assignment_ind_outlined),
                label: Text(
                  isAssigning ? 'Assigning...' : 'Assign to Employee',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAsset(Map<String, dynamic> asset) {
    return InkWell(
      onTap: () {
        setState(() {
          codeController.text = asset['code'].toString();
          selectedAsset = asset;
          searched = true;
        });
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(asset['icon'] as IconData, color: primary, size: 25),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset['name'].toString(),
                    style: const TextStyle(
                      color: dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${asset['code']} • ${asset['location']}',
                    style: const TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            _statusBadge(asset['status'].toString()),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right_rounded, color: muted),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: const Column(
        children: [
          Icon(Icons.qr_code_2_rounded, size: 43, color: muted),
          SizedBox(height: 12),
          Text(
            'Asset not found',
            style: TextStyle(
              color: dark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'This code is not in the demo records. For real lookup, '
            'register the barcode in the Orgaflow backend first.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Scanner',
              style: TextStyle(
                color: dark,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Scan, inspect and assign assets',
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          children: [
            _buildHeroCard(),
            const SizedBox(height: 25),
            const Text(
              'Find an asset',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: dark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Search by Orgaflow asset ID, serial number or registered barcode.',
              style: TextStyle(color: muted, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 13),
            _buildSearchField(),
            const SizedBox(height: 11),
            SizedBox(
              height: 49,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => _lookupAsset(codeController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Search Asset',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 25),
            if (searched) ...[
              const Text(
                'Search result',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: dark,
                ),
              ),
              const SizedBox(height: 13),
              if (selectedAsset != null)
                _buildAssetCard(selectedAsset!)
              else if (!isLoading)
                _buildEmptyResult(),
            ] else ...[
              const Text(
                'Quick access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: dark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap a demo asset to inspect its record.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 13),
              ...assets.take(3).map(_buildQuickAsset),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF1FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Demo assets are sample records. Real asset lookup and '
                      'employee assignment require matching FastAPI endpoints '
                      'and PostgreSQL records.',
                      style: TextStyle(
                        color: Color(0xFF596782),
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeAssignmentDialog extends StatefulWidget {
  const _EmployeeAssignmentDialog();

  @override
  State<_EmployeeAssignmentDialog> createState() =>
      _EmployeeAssignmentDialogState();
}

class _EmployeeAssignmentDialogState
    extends State<_EmployeeAssignmentDialog> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final departmentController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    departmentController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      title: const Text(
        'Assign to Employee',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(
                nameController,
                'Employee full name',
                Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _field(
                emailController,
                'Registered employee email',
                Icons.email_outlined,
                email: true,
              ),
              const SizedBox(height: 12),
              _field(
                departmentController,
                'Department',
                Icons.business_outlined,
              ),
              const SizedBox(height: 12),
              _field(
                descriptionController,
                'Assignment description',
                Icons.notes_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              const Text(
                'Use the email associated with the employee account. '
                'The backend must verify that account before assigning.',
                style: TextStyle(
                  color: Color(0xFF7B879B),
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;

            final email = emailController.text.trim();
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                .hasMatch(email)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter a valid email address.')),
              );
              return;
            }

            Navigator.pop(context, {
              'name': nameController.text.trim(),
              'email': email,
              'department': departmentController.text.trim(),
              'description': descriptionController.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B5BDB),
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool email = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType:
          email ? TextInputType.emailAddress : TextInputType.text,
      textCapitalization:
          email ? TextCapitalization.none : TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}
