
import 'package:flutter/material.dart';

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

  final TextEditingController codeController = TextEditingController();

  Map<String, dynamic>? selectedAsset;
  bool searched = false;

  // Demo data: Replace with your FastAPI asset API later.
  final List<Map<String, dynamic>> assets = [
    {
      'code': 'AST-001',
      'name': 'Dell Latitude 5420',
      'category': 'Laptop',
      'brand': 'Dell',
      'model': 'Latitude 5420',
      'serial': 'DLL-5420-001',
      'location': 'Noida Office',
      'department': 'Engineering',
      'assignedTo': 'Rahul Sharma',
      'status': 'Assigned',
      'condition': 'Good',
      'icon': Icons.laptop_mac_rounded,
    },
    {
      'code': 'AST-002',
      'name': 'Samsung Galaxy A55',
      'category': 'Smartphone',
      'brand': 'Samsung',
      'model': 'Galaxy A55',
      'serial': 'SAM-A55-002',
      'location': 'Noida Office',
      'department': 'Marketing',
      'assignedTo': 'Priya Singh',
      'status': 'Available',
      'condition': 'Excellent',
      'icon': Icons.smartphone_rounded,
    },
    {
      'code': 'AST-003',
      'name': 'Epson Projector',
      'category': 'Projector',
      'brand': 'Epson',
      'model': 'EB Series',
      'serial': 'EPS-003',
      'location': 'Conference Room',
      'department': 'Administration',
      'assignedTo': 'Unassigned',
      'status': 'Maintenance',
      'condition': 'Under repair',
      'icon': Icons.videocam_rounded,
    },
    {
      'code': 'AST-004',
      'name': 'Office DSLR Camera',
      'category': 'Camera',
      'brand': 'Canon',
      'model': 'EOS Series',
      'serial': 'CAN-004',
      'location': 'Media Room',
      'department': 'Marketing',
      'assignedTo': 'Unassigned',
      'status': 'Available',
      'condition': 'Good',
      'icon': Icons.camera_alt_rounded,
    },
  ];

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void _searchAsset() {
    final query = codeController.text.trim().toLowerCase();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an asset code first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      searched = true;
      selectedAsset = assets.cast<Map<String, dynamic>?>().firstWhere(
        (asset) =>
            asset!['code'].toString().toLowerCase() == query ||
            asset['serial'].toString().toLowerCase() == query,
        orElse: () => null,
      );
    });
  }

  void _clearSearch() {
    setState(() {
      codeController.clear();
      selectedAsset = null;
      searched = false;
    });
  }

  void _showScannerInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 42,
                  color: primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'QR Scanner',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: dark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Camera scanning is not connected yet. '
                'You can search for an asset using its code below.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: muted,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Enter Code Manually',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 22,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Scanner',
              style: TextStyle(
                color: dark,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Identify and inspect your assets',
              style: TextStyle(
                color: muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                color: primary,
                size: 23,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(),
              const SizedBox(height: 26),
              _sectionHeading('Find an asset', 'Search by asset ID'),
              const SizedBox(height: 14),
              _buildSearchField(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _searchAsset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_rounded, size: 21),
                      SizedBox(width: 9),
                      Text(
                        'Search Asset',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 27),
              if (searched) ...[
                _sectionHeading(
                  'Search results',
                  selectedAsset == null ? 'No match found' : '1 asset found',
                ),
                const SizedBox(height: 14),
                if (selectedAsset != null)
                  _buildAssetCard(selectedAsset!)
                else
                  _buildEmptyResult(),
              ] else ...[
                _sectionHeading('Quick access', 'Demo assets'),
                const SizedBox(height: 5),
                const Text(
                  'Select a sample asset to view its information.',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
                const SizedBox(height: 14),
                ...assets.take(3).map(
                  (asset) => _buildQuickAsset(asset),
                ),
              ],
              const SizedBox(height: 12),
              _buildHelpCard(),
            ],
          ),
        ),
      ),
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
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.19),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        color: Colors.white, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'ORGAFLOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Smart Asset\nIdentification',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Quickly access asset records, ownership, '
            'location and current status.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 21),
          SizedBox(
            width: double.infinity,
            height: 49,
            child: ElevatedButton.icon(
              onPressed: _showScannerInfo,
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
              label: const Text(
                'Open QR Scanner',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                elevation: 0,
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

  Widget _sectionHeading(String title, String subtitle) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: dark,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: codeController,
      textCapitalization: TextCapitalization.characters,
      onSubmitted: (_) => _searchAsset(),
      decoration: InputDecoration(
        hintText: 'Enter asset code (e.g. AST-001)',
        hintStyle: const TextStyle(color: muted, fontSize: 13),
        prefixIcon: const Icon(
          Icons.qr_code_2_rounded,
          color: primary,
          size: 23,
        ),
        suffixIcon: codeController.text.isNotEmpty
            ? IconButton(
                onPressed: _clearSearch,
                icon: const Icon(Icons.close_rounded, color: muted),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    final status = asset['status'].toString();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: dark.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1FF),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  asset['icon'] as IconData,
                  size: 29,
                  color: primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset['name'].toString(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${asset['category']} • ${asset['code']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(status),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: border, height: 1),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _detailItem(
                  Icons.person_outline_rounded,
                  'Assigned to',
                  asset['assignedTo'].toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _detailItem(
                  Icons.location_on_outlined,
                  'Location',
                  asset['location'].toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Row(
            children: [
              Expanded(
                child: _detailItem(
                  Icons.business_outlined,
                  'Department',
                  asset['department'].toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _detailItem(
                  Icons.verified_outlined,
                  'Condition',
                  asset['condition'].toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  color: muted,
                  size: 19,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Serial number',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    asset['serial'].toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: dark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showFullDetails(asset),
              icon: const Icon(Icons.open_in_new_rounded, size: 17),
              label: const Text(
                'View Full Details',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: const BorderSide(color: Color(0xFFD7DFFF)),
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

  Widget _buildQuickAsset(Map<String, dynamic> asset) {
    return InkWell(
      onTap: () {
        setState(() {
          codeController.text = asset['code'].toString();
          selectedAsset = asset;
          searched = true;
        });
      },
      borderRadius: BorderRadius.circular(17),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF1FF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                asset['icon'] as IconData,
                color: primary,
                size: 23,
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
                      color: dark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${asset['code']} • ${asset['location']}',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            _statusBadge(asset['status'].toString()),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: muted,
              size: 20,
            ),
          ],
        ),
      ),
    );
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
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
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

  Widget _buildEmptyResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEEEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 32,
              color: Color(0xFFD94848),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Asset not found',
            style: TextStyle(
              color: dark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Check the asset code and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _clearSearch,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Search again'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF1FF),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: primary, size: 22),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick tip',
                  style: TextStyle(
                    color: dark,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Use the unique asset ID printed on the asset tag '
                  'to locate the correct record.',
                  style: TextStyle(
                    color: Color(0xFF596782),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullDetails(Map<String, dynamic> asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF1FF),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(
                      asset['icon'] as IconData,
                      color: primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset['name'].toString(),
                          style: const TextStyle(
                            color: dark,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          asset['code'].toString(),
                          style: const TextStyle(
                            color: muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(asset['status'].toString()),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Asset information',
                style: TextStyle(
                  color: dark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              ...[
                ['Category', asset['category']],
                ['Brand', asset['brand']],
                ['Model', asset['model']],
                ['Serial number', asset['serial']],
                ['Location', asset['location']],
                ['Department', asset['department']],
                ['Assigned to', asset['assignedTo']],
                ['Condition', asset['condition']],
              ].map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item[0].toString(),
                          style: const TextStyle(
                            color: muted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          item[1].toString(),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: dark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Close Details',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
