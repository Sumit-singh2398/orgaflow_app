
import 'dart:async';

import 'package:flutter/material.dart';

import 'employee_my_assets_page.dart';
import 'employee_assets_page.dart';
import 'employee_profile_page.dart';
import 'employee_track_requests_page.dart';
import 'services/employee_notification_service.dart';

const Color employeePrimaryColor = Color(0xFF3157D5);
const Color employeeDarkColor = Color(0xFF172033);
const Color employeeGreyColor = Color(0xFF6B7280);
const Color employeeBackgroundColor = Color(0xFFF6F8FC);

const String employeeLogoAsset = 'assets/images/orgaflow_logo.png';
const double employeeLogoSize = 64;

class EmployeeDashboard extends StatefulWidget {
  final bool isNewUser;
  final Map<String, dynamic>? userData;

  const EmployeeDashboard({
    super.key,
    required this.isNewUser,
    this.userData,
  });

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int _selectedIndex = 0;
  int _unreadCount = 0;
  bool _loadingNotifications = false;
  String? _notificationError;

  List<Map<String, dynamic>> _notifications = [];
  Timer? _notificationTimer;

  late final EmployeeNotificationService _notificationService;

  @override
  void initState() {
    super.initState();

    final data = widget.userData ?? {};

    // Login response mein token/access_token hona chahiye.
    final token = data['access_token'] ??
        data['accessToken'] ??
        data['token'];

    _notificationService = EmployeeNotificationService(
      token: token?.toString(),
    );

    _refreshUnreadCount();

    // Jab dashboard active ho, unread count automatically refresh hoga.
    _notificationTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshUnreadCount(),
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  String get _employeeName {
    final data = widget.userData ?? {};

    final name = data['name'] ??
        data['employee_name'] ??
        data['full_name'] ??
        data['username'];

    if (name == null || name.toString().trim().isEmpty) {
      return 'Employee';
    }

    return name.toString().trim();
  }

  Future<void> _refreshUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();

      if (!mounted) return;

      setState(() {
        _unreadCount = count;
      });
    } catch (_) {
      // Network/server error par dashboard crash nahi hoga.
      // Notification sheet kholne par detailed error dikhega.
    }
  }

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 1:
        return EmployeeAssetsPage(userData: widget.userData);
      case 2:
        return EmployeeProfilePage(userData: widget.userData);
      default:
        return _buildHomePage();
    }
  }

  Future<void> _openNotifications() async {
    if (_loadingNotifications) return;

    setState(() {
      _loadingNotifications = true;
      _notificationError = null;
    });

    try {
      final items = await _notificationService.getNotifications();

      if (!mounted) return;

      setState(() {
        _notifications = items;
        _notificationError = null;
        _loadingNotifications = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _notificationError = e.toString();
        _loadingNotifications = false;
      });
    }

    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _buildNotificationSheet(
              context,
              setSheetState,
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationSheet(
    BuildContext sheetContext,
    StateSetter setSheetState,
  ) {
    return Container(
      height: MediaQuery.of(sheetContext).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD9DEE8),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 14),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: employeePrimaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: employeePrimaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          color: employeeDarkColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _unreadCount == 0
                            ? 'You are all caught up'
                            : '$_unreadCount unread notification(s)',
                        style: const TextStyle(
                          color: employeeGreyColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loadingNotifications
                ? const Center(
                    child: CircularProgressIndicator(
                      color: employeePrimaryColor,
                    ),
                  )
                : _notificationError != null
                    ? _buildNotificationError()
                    : _notifications.isEmpty
                        ? _buildEmptyNotifications()
                        : RefreshIndicator(
                            color: employeePrimaryColor,
                            onRefresh: () async {
                              await _reloadNotifications(
                                setSheetState,
                              );
                            },
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _notifications.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final notification =
                                    _notifications[index];

                                return _buildNotificationTile(
                                  notification,
                                  setSheetState,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F3FA),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 42,
                color: employeeGreyColor,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: employeeDarkColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'When management approves or rejects your asset request, '
              'you will see an update here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: employeeGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 46,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: employeeDarkColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _notificationError ?? 'Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: employeeGreyColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openNotifications,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: employeePrimaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    Map<String, dynamic> notification,
    StateSetter setSheetState,
  ) {
    final id = notification['id'] ??
        notification['notification_id'];

    final title = (notification['title'] ??
            notification['type'] ??
            'Orgaflow Update')
        .toString();

    final message = (notification['message'] ??
            notification['body'] ??
            notification['description'] ??
            'You have a new update.')
        .toString();

    final readValue = notification['is_read'] ??
        notification['read'] ??
        false;

    final isRead = readValue == true ||
        readValue == 1 ||
        readValue.toString().toLowerCase() == 'true';

    final createdAt = notification['created_at'] ??
        notification['createdAt'];

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        if (id != null && !isRead) {
          try {
            final success =
                await _notificationService.markAsRead(id);

            if (success) {
              setState(() {
                _unreadCount =
                    _unreadCount > 0 ? _unreadCount - 1 : 0;
              });

              setSheetState(() {
                notification['is_read'] = true;
                notification['read'] = true;
              });
            }
          } catch (_) {
            // User can still read the notification if the
            // server request fails.
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.white
              : const Color(0xFFF2F5FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead
                ? const Color(0xFFE9EDF4)
                : employeePrimaryColor.withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: _notificationIconColor(title)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                _notificationIcon(title),
                color: _notificationIconColor(title),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _friendlyTitle(title),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: employeeDarkColor,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: employeePrimaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: employeeGreyColor,
                    ),
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(createdAt.toString()),
                      style: const TextStyle(
                        fontSize: 10,
                        color: employeeGreyColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reloadNotifications(
    StateSetter setSheetState,
  ) async {
    try {
      final items =
          await _notificationService.getNotifications();
      final count = await _notificationService.getUnreadCount();

      if (!mounted) return;

      setState(() {
        _notifications = items;
        _unreadCount = count;
        _notificationError = null;
      });

      setSheetState(() {});
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _notificationError = e.toString();
      });

      setSheetState(() {});
    }
  }

  String _friendlyTitle(String title) {
    final value = title.toLowerCase();

    if (value.contains('approv')) {
      return 'Request Approved';
    }
    if (value.contains('reject')) {
      return 'Request Rejected';
    }
    if (value.contains('assign')) {
      return 'Asset Assigned';
    }
    if (value.contains('maintenance')) {
      return 'Maintenance Update';
    }

    return title;
  }

  IconData _notificationIcon(String title) {
    final value = title.toLowerCase();

    if (value.contains('approv')) {
      return Icons.check_circle_rounded;
    }
    if (value.contains('reject')) {
      return Icons.cancel_rounded;
    }
    if (value.contains('assign')) {
      return Icons.inventory_2_rounded;
    }

    return Icons.notifications_active_rounded;
  }

  Color _notificationIconColor(String title) {
    final value = title.toLowerCase();

    if (value.contains('approv')) return Colors.green;
    if (value.contains('reject')) return Colors.red;
    if (value.contains('assign')) return Colors.deepPurple;

    return employeePrimaryColor;
  }

  String _formatDate(String value) {
    try {
      final date = DateTime.parse(value).toLocal();

      String twoDigits(int number) =>
          number.toString().padLeft(2, '0');

      return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} '
          '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
    } catch (_) {
      return value;
    }
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: RefreshIndicator(
        color: employeePrimaryColor,
        onRefresh: () async {
          await _refreshUnreadCount();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            _buildWelcome(),
            const SizedBox(height: 24),
            _buildMyAssetsCard(),
            const SizedBox(height: 14),
            _buildTrackRequestsCard(),
            const SizedBox(height: 25),
            _buildSectionTitle('Quick Access'),
            const SizedBox(height: 14),
            _buildQuickAccess(),
            const SizedBox(height: 22),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          height: employeeLogoSize,
          width: employeeLogoSize,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE8ECF4),
            ),
            boxShadow: [
              BoxShadow(
                color: employeeDarkColor.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Image.asset(
            employeeLogoAsset,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Center(
                child: Icon(
                  Icons.business_rounded,
                  color: employeePrimaryColor,
                  size: 35,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Orgaflow',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: employeeDarkColor,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Employee Portal',
                style: TextStyle(
                  fontSize: 12,
                  color: employeeGreyColor,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: _openNotifications,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFE7EBF3),
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: employeeDarkColor,
                    size: 25,
                  ),
                ),
              ),
            ),
            if (_unreadCount > 0)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 19,
                    minHeight: 19,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5484D),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: employeeBackgroundColor,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _unreadCount > 99 ? '99+' : '$_unreadCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WELCOME BACK',
          style: TextStyle(
            color: employeePrimaryColor,
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hello, $_employeeName 👋',
          style: const TextStyle(
            color: employeeDarkColor,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Manage your assigned assets and track your requests.',
          style: TextStyle(
            color: employeeGreyColor,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMyAssetsCard() {
    return _actionCard(
      title: 'My Assets',
      subtitle: 'View your assigned company assets',
      icon: Icons.inventory_2_rounded,
      color: employeePrimaryColor,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmployeeMyAssetsPage(
              userData: widget.userData,
            ),
          ),
        );
      },
      label: 'VIEW ASSETS',
    );
  }

  Widget _buildTrackRequestsCard() {
    return _actionCard(
      title: 'Track Requests',
      subtitle: 'Check approval status and request updates',
      icon: Icons.receipt_long_rounded,
      color: const Color(0xFF0F9D85),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmployeeTrackRequestsPage(
              userData: widget.userData,
            ),
          ),
        );
      },
      label: 'TRACK NOW',
    );
  }

  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String label,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE9EDF5),
            ),
            boxShadow: [
              BoxShadow(
                color: employeeDarkColor.withValues(alpha: 0.025),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: employeeDarkColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.45,
                        color: employeeGreyColor,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w900,
        color: employeeDarkColor,
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Row(
      children: [
        Expanded(
          child: _quickAccessItem(
            icon: Icons.devices_rounded,
            title: 'Browse Assets',
            subtitle: 'Explore inventory',
            color: const Color(0xFF3157D5),
            onTap: () {
              setState(() => _selectedIndex = 1);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickAccessItem(
            icon: Icons.person_outline_rounded,
            title: 'My Profile',
            subtitle: 'Personal details',
            color: const Color(0xFF8B5CF6),
            onTap: () {
              setState(() => _selectedIndex = 2);
            },
          ),
        ),
      ],
    );
  }

  Widget _quickAccessItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: const Color(0xFFE9EDF5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 13),
              Text(
                title,
                style: const TextStyle(
                  color: employeeDarkColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: employeeGreyColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3157D5),
            Color(0xFF4F73E8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay up to date',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Check notifications for asset request approvals, '
                  'rejections and assignment updates.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: employeeBackgroundColor,
      body: _getCurrentPage(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE9EDF5),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: employeePrimaryColor,
            unselectedItemColor: employeeGreyColor,
            selectedFontSize: 11,
            unselectedFontSize: 10,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                label: 'Assets',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
