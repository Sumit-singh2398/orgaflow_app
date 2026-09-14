import 'package:flutter/material.dart';

import 'employee_my_assets_page.dart';
import 'employee_assets_page.dart';
import 'employee_requests_page.dart';
import 'employee_profile_page.dart';
import 'my_request.dart';

class ExistingEmployeeHome extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ExistingEmployeeHome({
    super.key,
    this.userData,
  });

  @override
  State<ExistingEmployeeHome> createState() =>
      _ExistingEmployeeHomeState();
}

class _ExistingEmployeeHomeState extends State<ExistingEmployeeHome> {
  int _currentIndex = 0;

  static const Color primaryColor = Color(0xFF3157D5);
  static const Color darkColor = Color(0xFF172033);
  static const Color greyColor = Color(0xFF6B7280);
  static const Color backgroundColor = Color(0xFFF6F8FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _currentIndex == 0
          ? _buildHomePage()
          : _buildSelectedPage(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ============================================================
  // SELECTED PAGE
  // ============================================================

  Widget _buildSelectedPage() {
    switch (_currentIndex) {
      case 1:
        return EmployeeAssetsPage(
          userData: widget.userData,
        );

      case 2:
        return EmployeeRequestsPage(
          userData: widget.userData,
        );

      case 3:
        return EmployeeProfilePage(
          userData: widget.userData,
        );

      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // HOME PAGE
  // ============================================================

  Widget _buildHomePage() {
    final String name =
        widget.userData?['name']?.toString() ?? 'Employee';

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(name),

            const SizedBox(height: 28),

            _buildWelcomeSection(name),

            const SizedBox(height: 24),

            _buildMyAssetsCard(),

            const SizedBox(height: 18),

            _buildRequestsCard(),

            const SizedBox(height: 28),

            _buildSectionHeader(
              'Quick Access',
              'Access your frequently used options',
            ),

            const SizedBox(height: 14),

            _buildQuickAccessGrid(),

            const SizedBox(height: 28),

            _buildSectionHeader(
              'Recent Activity',
              'Your latest activity will appear here',
            ),

            const SizedBox(height: 14),

            _buildActivityCard(),

            const SizedBox(height: 28),

            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(String name) {
    final String firstLetter =
        name.isNotEmpty ? name[0].toUpperCase() : 'E';

    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              firstLetter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Orgaflow',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Employee Portal',
                style: TextStyle(
                  fontSize: 12,
                  color: greyColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        _buildNotificationButton(),
      ],
    );
  }

  // ============================================================
  // NOTIFICATION BUTTON
  // ============================================================

  Widget _buildNotificationButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE5E8EF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              _showNotifications(context);
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: darkColor,
              size: 24,
            ),
          ),
        ),

        Positioned(
          right: 10,
          top: 8,
          child: Container(
            height: 7,
            width: 7,
            decoration: const BoxDecoration(
              color: Color(0xFFE5484D),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _buildWelcomeSection(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(
            fontSize: 14,
            color: greyColor,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          '$name 👋',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: darkColor,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Here is an overview of your organization assets.',
          style: TextStyle(
            fontSize: 13,
            color: greyColor,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MY ASSETS CARD
  // ============================================================

  Widget _buildMyAssetsCard() {
    return _buildDashboardCard(
      icon: Icons.inventory_2_outlined,
      title: 'My Assets',
      subtitle: 'View assets currently assigned to you',
      buttonText: 'View My Assets',
      onTap: _openMyAssets,
    );
  }

  // ============================================================
  // REQUEST CARD
  // ============================================================

  Widget _buildRequestsCard() {
    return _buildDashboardCard(
      icon: Icons.assignment_outlined,
      title: 'My Requests',
      subtitle: 'Track your submitted asset requests',
      buttonText: 'Track Requests',
      onTap: _openMyRequest,
    );
  }

  // ============================================================
  // DASHBOARD CARD
  // ============================================================

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E8EF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 27,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: darkColor,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: greyColor,
                  ),
                ),

                const SizedBox(height: 11),

                GestureDetector(
                  onTap: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: primaryColor,
                      ),
                    ],
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
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: darkColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: greyColor,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK ACCESS GRID
  // ============================================================

  Widget _buildQuickAccessGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickCard(
            icon: Icons.devices_outlined,
            title: 'Available Assets',
            subtitle: 'Browse assets',
            onTap: () {
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: _buildQuickCard(
            icon: Icons.assignment_outlined,
            title: 'Requests',
            subtitle: 'Manage requests',
            onTap: () {
              setState(() {
                _currentIndex = 2;
              });
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK CARD
  // ============================================================

  Widget _buildQuickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 132,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE5E8EF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 43,
                width: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 23,
                ),
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: darkColor,
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: greyColor,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: Color(0xFF9AA0AC),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RECENT ACTIVITY
  // ============================================================

  Widget _buildActivityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E8EF),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F8),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Color(0xFF687080),
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No recent activity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your latest asset and request activities will appear here.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: greyColor,
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
  // INFORMATION CARD
  // ============================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.security_outlined,
              color: primaryColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee Access',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: darkColor,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'You can view your assigned assets, browse available assets, submit requests and track your requests.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.45,
                    color: Color(0xFF5E6675),
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
  // OPEN MY ASSETS
  // ============================================================

  void _openMyAssets() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeMyAssetsPage(
          userData: widget.userData,
        ),
      ),
    );
  }

  // ============================================================
  // OPEN MY REQUEST
  // ============================================================

  void _openMyRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyRequest(
          userData: widget.userData,
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: Color(0xFFE6E9EF),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,

        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xFF9298A5),

        selectedFontSize: 11,
        unselectedFontSize: 11,

        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: 23,
            ),
            activeIcon: Icon(
              Icons.home_rounded,
              size: 23,
            ),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.devices_outlined,
              size: 23,
            ),
            activeIcon: Icon(
              Icons.devices_rounded,
              size: 23,
            ),
            label: 'Assets',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.assignment_outlined,
              size: 23,
            ),
            activeIcon: Icon(
              Icons.assignment_rounded,
              size: 23,
            ),
            label: 'Requests',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline_rounded,
              size: 23,
            ),
            activeIcon: Icon(
              Icons.person_rounded,
              size: 23,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7DAE1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: darkColor,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 43,
                        width: 43,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 13),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No new notifications',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: darkColor,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              'Updates about your assets and requests will appear here.',
                              style: TextStyle(
                                fontSize: 11.5,
                                height: 1.4,
                                color: greyColor,
                              ),
                            ),
                          ],
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
}