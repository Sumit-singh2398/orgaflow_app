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
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFF3157D5);
  static const Color darkColor = Color(0xFF172033);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color lightBlue = Color(0xFFEAF0FF);
  static const Color borderColor = Color(0xFFE8EBF2);

  int selectedIndex = 0;

  // ============================================================
  // PAGE TITLES
  // ============================================================

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: darkColor,
        elevation: 0,
        surfaceTintColor: Colors.white,

        leading: Builder(
          builder: (context) {
            return IconButton(
              tooltip: 'Menu',
              icon: const Icon(
                Icons.menu_rounded,
                size: 25,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),

        titleSpacing: 0,

        title: Text(
          titles[selectedIndex],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: darkColor,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: _showNotifications,
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 25,
            ),
          ),

          const SizedBox(width: 3),

          Padding(
            padding: const EdgeInsets.only(
              right: 14,
            ),
            child: CircleAvatar(
              radius: 19,
              backgroundColor: primaryColor,
              child: Text(
                _getInitials(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      drawer: _buildDrawer(),

      body: SafeArea(
        child: _buildPage(),
      ),
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
    final String name =
        widget.userData?['name']?.toString().trim().isNotEmpty == true
            ? widget.userData!['name'].toString()
            : 'Asset Manager';

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        final double horizontalPadding =
            width >= 1100 ? 32 : 18;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            20,
            horizontalPadding,
            35,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1250,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // WELCOME
                  // ==================================================

                  _buildWelcomeSection(name),

                  const SizedBox(height: 24),

                  // ==================================================
                  // STATISTICS
                  // ==================================================

                  _buildStatsSection(width),

                  const SizedBox(height: 30),

                  // ==================================================
                  // QUICK ACTIONS HEADER
                  // ==================================================

                  _sectionHeader(
                    title: 'Quick Actions',
                    subtitle:
                        'Frequently used asset management tools',
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // QUICK ACTIONS
                  // ==================================================

                  _buildQuickActions(width),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // STATISTICS SECTION
  // ============================================================

  Widget _buildStatsSection(double width) {
    final List<Map<String, dynamic>> cards = [
      {
        'title': 'Total Assets',
        'value': '356',
        'icon': Icons.devices_other_rounded,
      },
      {
        'title': 'Assigned',
        'value': '291',
        'icon': Icons.assignment_turned_in_rounded,
      },
      {
        'title': 'Available',
        'value': '65',
        'icon': Icons.inventory_2_rounded,
      },
      {
        'title': 'Maintenance',
        'value': '18',
        'icon': Icons.build_rounded,
      },
    ];

    // ------------------------------------------------------------
    // MOBILE
    // ------------------------------------------------------------

    if (width < 600) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _statCard(
                  title: cards[0]['title'] as String,
                  value: cards[0]['value'] as String,
                  icon: cards[0]['icon'] as IconData,
                ),
                const SizedBox(height: 12),
                _statCard(
                  title: cards[2]['title'] as String,
                  value: cards[2]['value'] as String,
                  icon: cards[2]['icon'] as IconData,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              children: [
                _statCard(
                  title: cards[1]['title'] as String,
                  value: cards[1]['value'] as String,
                  icon: cards[1]['icon'] as IconData,
                ),
                const SizedBox(height: 12),
                _statCard(
                  title: cards[3]['title'] as String,
                  value: cards[3]['value'] as String,
                  icon: cards[3]['icon'] as IconData,
                ),
              ],
            ),
          ),
        ],
      );
    }

    // ------------------------------------------------------------
    // TABLET / DESKTOP
    // ------------------------------------------------------------

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        cards.length,
        (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == cards.length - 1
                    ? 0
                    : 12,
              ),
              child: _statCard(
                title: cards[index]['title'] as String,
                value: cards[index]['value'] as String,
                icon: cards[index]['icon'] as IconData,
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // WELCOME SECTION
  // ============================================================

  Widget _buildWelcomeSection(String name) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3157D5),
            Color(0xFF4770E8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisSize:
                  MainAxisSize.min,

              children: [
                const Text(
                  'Welcome back 👋',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Manage and track your organization assets easily.',
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          // ======================================================
          // LOGO
          // ======================================================

          Container(
            height: 72,
            width: 72,

            padding: const EdgeInsets.all(7),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(17),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: 0.10),
                  blurRadius: 10,
                  offset:
                      const Offset(0, 4),
                ),
              ],
            ),

            child: Image.asset(
              'assets/images/orgaflow_logo.png',
              fit: BoxFit.contain,

              errorBuilder:
                  (context, error, stackTrace) {
                return const Icon(
                  Icons.business_rounded,
                  color: primaryColor,
                  size: 40,
                );
              },
            ),
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
    // IMPORTANT:
    // Fixed height prevents Grid/Column RenderFlex overflow.
    return Container(
      width: double.infinity,
      height: 128,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: borderColor,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisAlignment:
            MainAxisAlignment.start,

        children: [
          // ======================================================
          // ICON
          // ======================================================

          Container(
            height: 40,
            width: 40,

            decoration: BoxDecoration(
              color: lightBlue,

              borderRadius:
                  BorderRadius.circular(11),
            ),

            child: Icon(
              icon,
              color: primaryColor,
              size: 21,
            ),
          ),

          const SizedBox(height: 9),

          // ======================================================
          // VALUE
          // ======================================================

          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,

            style: const TextStyle(
              fontSize: 23,
              height: 1.0,
              fontWeight: FontWeight.w800,
              color: darkColor,
            ),
          ),

          const SizedBox(height: 5),

          // ======================================================
          // TITLE
          // ======================================================

          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,

              style: const TextStyle(
                color: textGrey,
                fontSize: 12,
                height: 1.1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      mainAxisSize:
          MainAxisSize.min,

      children: [
        Text(
          title,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,

          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: darkColor,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,

          style: const TextStyle(
            color: textGrey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions(double width) {
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.devices_other_rounded,
        'title': 'All Assets',
        'subtitle': 'View and manage assets',
        'index': 1,
      },
      {
        'icon': Icons.pending_actions_rounded,
        'title': 'Requests',
        'subtitle': 'Review asset requests',
        'index': 2,
      },
      {
        'icon': Icons.assignment_ind_rounded,
        'title': 'Assign Asset',
        'subtitle': 'Assign available assets',
        'index': 3,
      },
      {
        'icon': Icons.swap_horiz_rounded,
        'title': 'Transfer Asset',
        'subtitle': 'Transfer between employees',
        'index': 4,
      },
      {
        'icon': Icons.build_rounded,
        'title': 'Maintenance',
        'subtitle': 'Manage asset maintenance',
        'index': 5,
      },
      {
        'icon': Icons.history_rounded,
        'title': 'Asset History',
        'subtitle': 'View assignment history',
        'index': 6,
      },
      {
        'icon': Icons.bar_chart_rounded,
        'title': 'Reports',
        'subtitle': 'View reports and analytics',
        'index': 7,
      },
      {
        'icon': Icons.qr_code_scanner_rounded,
        'title': 'Scan Asset',
        'subtitle': 'Scan QR or barcode',
        'index': 8,
      },
    ];

    // ============================================================
    // MOBILE
    // ============================================================

    if (width < 700) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: actions.map(
          (action) {
            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 10,
              ),

              child: _actionCard(
                icon:
                    action['icon']
                        as IconData,

                title:
                    action['title']
                        as String,

                subtitle:
                    action['subtitle']
                        as String,

                onTap: () {
                  _changePage(
                    action['index']
                        as int,
                  );
                },
              ),
            );
          },
        ).toList(),
      );
    }

    // ============================================================
    // TABLET / DESKTOP
    // ============================================================

    return GridView.builder(
      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      itemCount: actions.length,

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,

        // Larger height than before.
        childAspectRatio: 3.4,
      ),

      itemBuilder: (context, index) {
        final action =
            actions[index];

        return _actionCard(
          icon:
              action['icon']
                  as IconData,

          title:
              action['title']
                  as String,

          subtitle:
              action['subtitle']
                  as String,

          onTap: () {
            _changePage(
              action['index']
                  as int,
            );
          },
        );
      },
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
    return Material(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(16),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),

        onTap: onTap,

        child: Container(
          constraints:
              const BoxConstraints(
            minHeight: 72,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),

          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(16),

            border: Border.all(
              color: borderColor,
            ),
          ),

          child: Row(
            children: [
              // ==================================================
              // ICON
              // ==================================================

              Container(
                height: 44,
                width: 44,

                decoration:
                    BoxDecoration(
                  color: lightBlue,

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // ==================================================
              // TEXT
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w700,
                        color:
                            darkColor,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        color:
                            textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 7),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color:
                    Color(0xFF9AA1B1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DRAWER
  // ============================================================

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,

      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(),

            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),

                children: [
                  _drawerItem(
                    Icons.dashboard_rounded,
                    'Dashboard',
                    0,
                  ),

                  _drawerItem(
                    Icons.devices_other_rounded,
                    'Assets',
                    1,
                  ),

                  _drawerItem(
                    Icons.pending_actions_rounded,
                    'Requests',
                    2,
                  ),

                  _drawerItem(
                    Icons.assignment_ind_rounded,
                    'Assign Asset',
                    3,
                  ),

                  _drawerItem(
                    Icons.swap_horiz_rounded,
                    'Transfer Asset',
                    4,
                  ),

                  _drawerItem(
                    Icons.build_rounded,
                    'Maintenance',
                    5,
                  ),

                  _drawerItem(
                    Icons.history_rounded,
                    'Asset History',
                    6,
                  ),

                  _drawerItem(
                    Icons.bar_chart_rounded,
                    'Reports',
                    7,
                  ),

                  _drawerItem(
                    Icons.qr_code_scanner_rounded,
                    'Scan Asset',
                    8,
                  ),

                  _drawerItem(
                    Icons.person_outline_rounded,
                    'Profile',
                    9,
                  ),
                ],
              ),
            ),

            const Divider(
              height: 1,
              indent: 15,
              endIndent: 15,
            ),

            Padding(
              padding:
                  const EdgeInsets.all(10),

              child: ListTile(
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                leading:
                    const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                ),

                title:
                    const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                onTap: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DRAWER HEADER
  // ============================================================

  Widget _buildDrawerHeader() {
    final String name =
        widget.userData?['name']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true
            ? widget.userData!['name']
                .toString()
            : 'Asset Manager';

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        22,
      ),

      decoration:
          const BoxDecoration(
        color: primaryColor,

        borderRadius:
            BorderRadius.only(
          bottomLeft:
              Radius.circular(24),
          bottomRight:
              Radius.circular(24),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ==================================================
          // BIG LOGO
          // ==================================================

          Container(
            height: 86,
            width: 86,

            padding:
                const EdgeInsets.all(8),

            decoration:
                BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(
                18,
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset:
                      const Offset(0, 5),
                ),
              ],
            ),

            child: Image.asset(
              'assets/images/orgaflow_logo.png',

              fit: BoxFit.contain,

              errorBuilder:
                  (context, error, stackTrace) {
                return const Icon(
                  Icons.business_rounded,
                  color: primaryColor,
                  size: 50,
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ==================================================
          // USER NAME
          // ==================================================

          Text(
            name,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Asset Manager',
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,

            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 2),

          const Text(
            'OrgaFlow Asset Management',
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,

            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
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
    final bool selected =
        selectedIndex == index;

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 3,
      ),

      child: ListTile(
        dense: true,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),

        selected: selected,

        selectedTileColor:
            lightBlue,

        leading: Icon(
          icon,
          size: 21,

          color: selected
              ? primaryColor
              : Colors.grey.shade700,
        ),

        title: Text(
          title,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,

          style: TextStyle(
            fontSize: 14,

            fontWeight: selected
                ? FontWeight.w700
                : FontWeight.w500,

            color: selected
                ? primaryColor
                : darkColor,
          ),
        ),

        trailing: selected
            ? const Icon(
                Icons.chevron_right_rounded,
                color: primaryColor,
                size: 20,
              )
            : null,

        onTap: () {
          setState(() {
            selectedIndex = index;
          });

          Navigator.pop(context);
        },
      ),
    );
  }

  // ============================================================
  // INITIALS
  // ============================================================

  String _getInitials() {
    final String? name =
        widget.userData?['name']
            ?.toString();

    if (name == null ||
        name.trim().isEmpty) {
      return 'AM';
    }

    final List<String> parts =
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

      backgroundColor: Colors.white,

      isScrollControlled: true,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              24,
            ),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Notifications',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            TextStyle(
                          fontSize: 21,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              darkColor,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
                      },

                      icon:
                          const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ==================================================
                // NOTIFICATION 1
                // ==================================================

                _notificationItem(
                  icon:
                      Icons.pending_actions_rounded,
                  iconColor:
                      primaryColor,
                  iconBackground:
                      lightBlue,
                  title:
                      'New asset request',
                  subtitle:
                      'An employee has requested an asset.',
                ),

                // ==================================================
                // NOTIFICATION 2
                // ==================================================

                _notificationItem(
                  icon:
                      Icons.build_rounded,
                  iconColor:
                      Colors.orange,
                  iconBackground:
                      const Color(0xFFFFF4E5),
                  title:
                      'Maintenance required',
                  subtitle:
                      'Some assets require maintenance.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // NOTIFICATION ITEM
  // ============================================================

  Widget _notificationItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
          const EdgeInsets.all(12),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFFF8F9FC),

        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,

            decoration:
                BoxDecoration(
              color:
                  iconBackground,

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisSize:
                  MainAxisSize.min,

              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                    color:
                        darkColor,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    color:
                        textGrey,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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