import 'package:flutter/material.dart';

// =====================================================================
// 1. ASSETS MAIN SCREEN - Search, Filter aur Assets ki List dikhane ke liye
// =====================================================================
class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER SECTION: Title aur Tune Icon
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Assets',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune_outlined, color: Color(0xFF1A1A1A)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // SEARCH BAR SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search assets...',
                  hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF888888)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEFEFEF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEFEFEF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3B5BDB)),
                  ),
                ),
              ),
            ),

            // FILTER DROPDOWNS SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EEFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Text('All Categories', style: TextStyle(color: Color(0xFF3B5BDB), fontSize: 13, fontWeight: FontWeight.w500)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF3B5BDB)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEFEFEF)),
                    ),
                    child: Row(
                      children: const [
                        Text('Status', style: TextStyle(color: Color(0xFF444444), fontSize: 13, fontWeight: FontWeight.w500)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF444444)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ASSETS LIST CARDS SECTION
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildAssetCard(
                    title: 'MacBook Pro 14"',
                    subtitle: 'AF-0001 · Electronics\nAssigned to Rahul Sharma · IT Department',
                    status: 'Allocated',
                    statusColor: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildAssetCard(
                    title: 'Dell Latitude 7440',
                    subtitle: 'AF-0002 · Electronics\nIT Department · Delhi HQ',
                    status: 'Available',
                    statusColor: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildAssetCard(
                    title: 'Ergonomic Chair',
                    subtitle: 'AF-0049 · Furniture\nAssigned to Priya Mehta',
                    status: 'Maintenance',
                    statusColor: Colors.orange,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF3B5BDB),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildAssetCard({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF888888)),
        ],
      ),
    );
  }
}


// =====================================================================
// 2. ASSET DETAIL SCREEN - Asset ki poori detail dikhane ke liye
// =====================================================================
class AssetDetailScreen extends StatelessWidget {
  const AssetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP APP BAR
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Asset Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A1A)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ASSET IMAGE CONTAINER
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEFEFEF)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.laptop_mac_outlined,
                          size: 64,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // TITLE & STATUS BADGE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'MacBook Pro 14"',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'AF-0001',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Allocated',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // DETAILS GRID SECTION
                    Row(
                      children: [
                        Expanded(child: _buildDetailCard('Category', 'Electronics')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDetailCard('Serial Number', 'C02ZK91D')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildDetailCard('Department', 'IT')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDetailCard('Condition', 'Excellent')),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ACTION BUTTONS (Transfer, Return, Maintenance)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFF3B5BDB)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Transfer', style: TextStyle(color: Color(0xFF3B5BDB), fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFF3B5BDB)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Return', style: TextStyle(color: Color(0xFF3B5BDB), fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B5BDB),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Maintenance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // TABS SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Overview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3B5BDB))),
                        Text('Allocation', style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
                        Text('Maintenance', style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
                        Text('Activity', style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
                      ],
                    ),
                    const Divider(height: 16, color: Color(0xFFE0E0E0)),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEFEFEF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Acquired 15 Jan 2025 · ₹1,79,900', style: TextStyle(fontSize: 14, color: Color(0xFF444444))),
                          SizedBox(height: 8),
                          Text('Location: Delhi HQ · Floor 6', style: TextStyle(fontSize: 14, color: Color(0xFF444444))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        ],
      ),
    );
  }
}


// =====================================================================
// 3. REGISTER ASSET SCREEN - Naya asset register karne ka form
// =====================================================================
class RegisterAssetScreen extends StatefulWidget {
  const RegisterAssetScreen({super.key});

  @override
  State<RegisterAssetScreen> createState() => _RegisterAssetScreenState();
}

class _RegisterAssetScreenState extends State<RegisterAssetScreen> {
  final TextEditingController _assetNameController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _assetNameController.dispose();
    _serialNumberController.dispose();
    _dateController.dispose();
    _costController.dispose();
    _conditionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Register Asset',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'BASIC INFORMATION',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF777777), letterSpacing: 1.0),
              ),
              const SizedBox(height: 12),

              const Text('Asset Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
              const SizedBox(height: 6),
              TextField(controller: _assetNameController, decoration: _buildInputDecoration('e.g. MacBook Pro 14"')),
              const SizedBox(height: 16),

              const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Select category', style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
                    Icon(Icons.keyboard_arrow_down, color: Color(0xFF888888)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Serial Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
              const SizedBox(height: 6),
              TextField(controller: _serialNumberController, decoration: _buildInputDecoration('Enter serial number')),
              const SizedBox(height: 24),

              const Text(
                'ACQUISITION',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF777777), letterSpacing: 1.0),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
                        const SizedBox(height: 6),
                        TextField(controller: _dateController, decoration: _buildInputDecoration('DD/MM/YYYY')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cost', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
                        const SizedBox(height: 6),
                        TextField(controller: _costController, decoration: _buildInputDecoration('₹ 0.00')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'DETAILS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF777777), letterSpacing: 1.0),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: TextField(controller: _conditionController, decoration: _buildInputDecoration('Condition'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _locationController, decoration: _buildInputDecoration('Location'))),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Generated Asset Tag', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                  Text('AF-0001', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3B5BDB))),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Register Asset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEFEF))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEFEF))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B5BDB))),
    );
  }
}


// =====================================================================
// 4. ALLOCATE ASSET SCREEN - Asset allocate karne ka form
// =====================================================================
class AllocateAssetScreen extends StatefulWidget {
  const AllocateAssetScreen({super.key});

  @override
  State<AllocateAssetScreen> createState() => _AllocateAssetScreenState();
}

class _AllocateAssetScreenState extends State<AllocateAssetScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Allocate Asset',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('SELECTED ASSET', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3B5BDB), letterSpacing: 0.8)),
                    SizedBox(height: 6),
                    Text('Dell Latitude 7440', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                    SizedBox(height: 4),
                    Text('AF-0002 · Available · Electronics', style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'ASSIGN TO',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF777777), letterSpacing: 1.0),
              ),
              const SizedBox(height: 12),

              const Text('Employee', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Select employee', style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
                    Icon(Icons.keyboard_arrow_down, color: Color(0xFF888888)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Department', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('IT Department', style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 14)),
                    Icon(Icons.keyboard_arrow_down, color: Color(0xFF888888)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Expected Return Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
              const SizedBox(height: 6),
              TextField(controller: _dateController, decoration: _buildInputDecoration('DD/MM/YYYY')),
              const SizedBox(height: 16),

              const Text('Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
              const SizedBox(height: 6),
              TextField(controller: _notesController, decoration: _buildInputDecoration('Optional notes')),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Already allocated?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange)),
                    SizedBox(height: 4),
                    Text(
                      'This asset is already allocated. Create a transfer request instead.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEFEF))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEFEF))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B5BDB))),
    );
  }
}


// =====================================================================
// 5. TRANSFER REQUESTS SCREEN - Pending, Approved, Rejected requests list
// =====================================================================
class TransferRequestsScreen extends StatelessWidget {
  const TransferRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP HEADER: Transfer Requests Title aur Filter Icon
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transfer Requests',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list_outlined, color: Color(0xFF1A1A1A)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // TABS SECTION: Pending, Approved, Rejected, Completed
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Pending', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3B5BDB))),
                      Text('Approved', style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
                      Text('Rejected', style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
                      Text('Completed', style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B5BDB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // REQUESTS LIST CONTAINER SECTION
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Pending Request Card with Approve and Reject Buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFEFEF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'MacBook Pro 14"',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Pending', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'AF-0001 · Rahul Sharma → Priya Mehta\nRequested by Sumit · 21 Aug 2026',
                          style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B5BDB),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: Colors.redAccent),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Reject', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Approved Request Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFEFEF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ergonomic Chair',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Approved', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'AF-0049 · IT → Finance\nRequested by Aditi · 20 Aug 2026',
                          style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}