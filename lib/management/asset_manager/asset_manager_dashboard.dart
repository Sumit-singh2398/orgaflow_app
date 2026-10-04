
import 'package:flutter/material.dart';

import 'asset_manager_assets_page.dart' as assets;
import 'asset_manager_requests_page.dart' as requests;
import 'asset_manager_assign_page.dart' as assign;
import 'asset_manager_transfer_page.dart' as transfer;
import 'asset_manager_maintenance_page.dart' as maintenance;
import 'asset_manager_history_page.dart' as history;
import 'asset_manager_reports_page.dart' as reports;
import 'asset_manager_scan_page.dart' as scan;
import 'asset_manager_profile_page.dart' as profile;

class AssetManagerDashboard extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerDashboard({
    super.key,
    this.userData,
  });

  @override
  State<AssetManagerDashboard> createState() =>
      _AssetManagerDashboardState();
}

class _AssetManagerDashboardState
    extends State<AssetManagerDashboard> {
  int selectedIndex = 0;

  final List<String> titles = [
    'Dashboard',
    'Assets',
    'Requests',
    'Assign Asset',
    'Transfer Asset',
    'Maintenance',
    'Asset History',
    'Reports',
    'Scan Asset',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF172033),

        title: Text(
          titles[selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _showNotifications,
            icon: const Icon(
              Icons.notifications_none,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF3157D5),
              child: Text(
                _getInitials(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),

      drawer: _buildDrawer(),

      body: _buildPage(),
    );
  }

  // ============================================================
  // PAGE ROUTER
  // ============================================================

  Widget _buildPage() {
    switch (selectedIndex) {
      case 1:
        return assets.AssetManagerAssetsPage(
          userData: widget.userData,
        );

      case 2:
        return requests.AssetManagerRequestsPage(
          userData: widget.userData,
        );

      case 3:
        return assign.AssetManagerAssignPage(
          userData: widget.userData,
        );

      case 4:
        return transfer.AssetManagerTransferPage(
          userData: widget.userData,
        );

      case 5:
        return maintenance.AssetManagerMaintenancePage(
          userData: widget.userData,
        );

      case 6:
        return history.AssetManagerHistoryPage(
          userData: widget.userData,
        );

      case 7:
        return reports.AssetManagerReportsPage(
          userData: widget.userData,
        );

      case 8:
        return scan.AssetManagerScanPage(
          userData: widget.userData,
        );

      case 9:
        return profile.AssetManagerProfilePage(
          userData: widget.userData,
        );

      case 0:
      default:
        return _buildDashboard();
    }
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  Widget _buildDashboard() {
    final name =
        widget.userData?['name']?.toString() ??
        'Asset Manager';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            'Welcome, $name 👋',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Manage and track organization assets.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 22),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,

            children: [
              _statCard(
                title: 'Total Assets',
                value: '356',
                icon: Icons.devices_other_outlined,
              ),

              _statCard(
                title: 'Assigned',
                value: '291',
                icon:
                    Icons.assignment_turned_in_outlined,
              ),

              _statCard(
                title: 'Available',
                value: '65',
                icon:
                    Icons.inventory_2_outlined,
              ),

              _statCard(
                title: 'Maintenance',
                value: '18',
                icon: Icons.build_outlined,
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 12),

          _actionCard(
            icon: Icons.devices_other_outlined,
            title: 'All Assets',
            subtitle:
                'View and manage organization assets',
            onTap: () => _changePage(1),
          ),

          _actionCard(
            icon:
                Icons.pending_actions_outlined,
            title: 'Employee Requests',
            subtitle:
                'Review pending asset requests',
            onTap: () => _changePage(2),
          ),

          _actionCard(
            icon:
                Icons.assignment_ind_outlined,
            title: 'Assign Asset',
            subtitle:
                'Assign an available asset',
            onTap: () => _changePage(3),
          ),

          _actionCard(
            icon: Icons.swap_horiz_outlined,
            title: 'Transfer Asset',
            subtitle:
                'Transfer asset between employees',
            onTap: () => _changePage(4),
          ),

          _actionCard(
            icon: Icons.build_outlined,
            title: 'Maintenance',
            subtitle:
                'Manage asset maintenance',
            onTap: () => _changePage(5),
          ),

          _actionCard(
            icon: Icons.history_outlined,
            title: 'Asset History',
            subtitle:
                'View asset assignment history',
            onTap: () => _changePage(6),
          ),

          _actionCard(
            icon: Icons.bar_chart_outlined,
            title: 'Reports',
            subtitle:
                'View asset reports and analytics',
            onTap: () => _changePage(7),
          ),

          _actionCard(
            icon: Icons.qr_code_scanner,
            title: 'Scan Asset',
            subtitle:
                'Scan QR code or barcode',
            onTap: () => _changePage(8),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color:
                const Color(0xFF3157D5),
            size: 28,
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xFF172033),
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              color:
                  Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,

      margin:
          const EdgeInsets.only(bottom: 10),

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),

      child: ListTile(
        onTap: onTap,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),

        leading: CircleAvatar(
          backgroundColor:
              const Color(0xFFE8EDFF),

          child: Icon(
            icon,
            color:
                const Color(0xFF3157D5),
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
            color:
                Color(0xFF172033),
          ),
        ),

        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color:
                Color(0xFF6B7280),
          ),
        ),

        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }

  // ============================================================
  // DRAWER
  // ============================================================

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,

          children: [
            Container(
              height: 190,

              padding:
                  const EdgeInsets.fromLTRB(
                20,
                25,
                20,
                20,
              ),

              color:
                  const Color(0xFF3157D5),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        Colors.white,

                    child: Text(
                      _getInitials(),
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF3157D5),
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Asset Manager',
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 2),

                  const Text(
                    'Asset & Resource Management',
                    style:
                        TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            _drawerItem(
              Icons.dashboard_outlined,
              'Dashboard',
              0,
            ),

            _drawerItem(
              Icons.devices_other_outlined,
              'Assets',
              1,
            ),

            _drawerItem(
              Icons.pending_actions_outlined,
              'Requests',
              2,
            ),

            _drawerItem(
              Icons.assignment_ind_outlined,
              'Assign Asset',
              3,
            ),

            _drawerItem(
              Icons.swap_horiz_outlined,
              'Transfer Asset',
              4,
            ),

            _drawerItem(
              Icons.build_outlined,
              'Maintenance',
              5,
            ),

            _drawerItem(
              Icons.history_outlined,
              'Asset History',
              6,
            ),

            _drawerItem(
              Icons.bar_chart_outlined,
              'Reports',
              7,
            ),

            _drawerItem(
              Icons.qr_code_scanner,
              'Scan Asset',
              8,
            ),

            _drawerItem(
              Icons.person_outline,
              'Profile',
              9,
            ),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),

              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DRAWER ITEM
  // ============================================================

  Widget _drawerItem(
    IconData icon,
    String title,
    int index,
  ) {
    final selected =
        selectedIndex == index;

    return ListTile(
      selected: selected,

      selectedTileColor:
          const Color(0xFFE8EDFF),

      leading: Icon(
        icon,

        color: selected
            ? const Color(0xFF3157D5)
            : Colors.grey.shade700,
      ),

      title: Text(
        title,

        style: TextStyle(
          fontWeight: selected
              ? FontWeight.bold
              : FontWeight.normal,

          color: selected
              ? const Color(0xFF3157D5)
              : Colors.black87,
        ),
      ),

      onTap: () {
        setState(() {
          selectedIndex = index;
        });

        Navigator.pop(context);
      },
    );
  }

  // ============================================================
  // INITIALS
  // ============================================================

  String _getInitials() {
    final name =
        widget.userData?['name']
            ?.toString();

    if (name == null ||
        name.trim().isEmpty) {
      return 'AM';
    }

    final parts =
        name.trim().split(
          RegExp(r'\s+'),
        );

    if (parts.length == 1) {
      return parts[0]
          .substring(0, 1)
          .toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  // ============================================================
  // PAGE CHANGE
  // ============================================================

  void _changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  void _showNotifications() {
    showModalBottomSheet(
      context: context,

      backgroundColor:
          Colors.white,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(20),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Notifications',
                  style:
                      TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                ListTile(
                  leading:
                      const CircleAvatar(
                    backgroundColor:
                        Color(0xFFE8EDFF),
                    child: Icon(
                      Icons
                          .pending_actions,
                      color:
                          Color(0xFF3157D5),
                    ),
                  ),

                  title: const Text(
                    'New asset request',
                  ),

                  subtitle:
                      const Text(
                    'An employee has requested an asset.',
                  ),
                ),

                ListTile(
                  leading:
                      const CircleAvatar(
                    backgroundColor:
                        Color(0xFFFFF4E5),
                    child: Icon(
                      Icons.build_outlined,
                      color:
                          Colors.orange,
                    ),
                  ),

                  title: const Text(
                    'Maintenance required',
                  ),

                  subtitle:
                      const Text(
                    'Some assets require maintenance.',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }
}
