import 'package:flutter/material.dart';
import 'assets_screen.dart';
import 'bookings_screen.dart';
import 'maintenance_screen.dart';
import 'more_screen.dart';
import 'raise_request.dart';
import 'assest_audit.dart';
import 'verify_assest.dart';
import 'report_analytics.dart';
import 'notifications.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // List of screens for the Bottom Navigation
  final List<Widget> _screens = [
    const DashboardHomeContent(), // Home Content (Dashboard ka main UI)
    const AssetsScreen(),
    const BookingsScreen(),
    const MaintenanceScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3B5BDB),
        unselectedItemColor: const Color(0xFF888888),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.devices_outlined), label: 'Assets'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.build_outlined), label: 'Maintenance'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

// Dashboard ka Home content jo top par dikhega
class DashboardHomeContent extends StatelessWidget {
  const DashboardHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting & Notification Icon with Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Good Morning, Sumit 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Here\'s what\'s happening today.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Metrics: Available, Allocated, Maintenance
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric('Available', '248'),
                  _buildMetric('Allocated', '156'),
                  _buildMetric('Maintenance', '1'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions with Navigation to respective screens
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RaiseRequestScreen())),
                  child: const _QuickAction(icon: Icons.add_circle_outline, label: 'Register'),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AssetAuditScreen())),
                  child: const _QuickAction(icon: Icons.fact_check_outlined, label: 'Audit'),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifyAssetScreen())),
                  child: const _QuickAction(icon: Icons.verified_outlined, label: 'Verify'),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportAnalyticsScreen())),
                  child: const _QuickAction(icon: Icons.bar_chart_rounded, label: 'Reports'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Asset Overview Chart Area
            const Text('Asset Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text("Chart Placeholder (Asset Distribution)", style: TextStyle(color: Colors.grey))),
            ),
            const SizedBox(height: 24),

            // Recent Activity
            const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildActivityItem('AF-0001 allocated to Rahul', 'Done', Colors.green),
            _buildActivityItem('Conference Room A booked', 'Pending', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String title, String value) {
    return Column(children: [
      Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildActivityItem(String text, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Expanded(child: Text(text)),
        Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: const Color(0xFF3B5BDB), size: 30),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }
}