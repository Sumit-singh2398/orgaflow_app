import 'package:flutter/material.dart';

class ExistingEmployeeHome extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ExistingEmployeeHome({
    super.key,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final String name =
        userData?['name']?.toString() ?? 'Employee';

    final String email =
        userData?['email']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Orgaflow',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // GREETING
            Text(
              'Welcome back, $name 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              email.isEmpty
                  ? 'Manage your assigned resources'
                  : email,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF777777),
              ),
            ),

            const SizedBox(height: 25),

            // MY ASSETS
            _buildSectionTitle('My Assets'),

            const SizedBox(height: 12),

            _buildMainCard(
              icon: Icons.devices_outlined,
              title: 'My Assigned Assets',
              subtitle: 'View assets assigned to you',
              onTap: () {},
            ),

            const SizedBox(height: 12),

            // REQUESTS
            _buildSectionTitle('Requests'),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildSmallCard(
                    icon: Icons.build_outlined,
                    title: 'Maintenance',
                    subtitle: 'Request service',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSmallCard(
                    icon: Icons.report_problem_outlined,
                    title: 'Report Issue',
                    subtitle: 'Report an asset issue',
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            _buildSectionTitle('Activity'),

            const SizedBox(height: 12),

            _buildMainCard(
              icon: Icons.history,
              title: 'Request Status',
              subtitle: 'Track your maintenance requests',
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _buildMainCard(
              icon: Icons.person_outline,
              title: 'My Profile',
              subtitle: 'View and update your profile',
              onTap: () {},
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3B5BDB),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices_outlined),
            label: 'Assets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF222222),
      ),
    );
  }

  Widget _buildMainCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE6E8EF),
          ),
        ),
        child: Row(
          children: [

            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF3B5BDB),
                size: 25,
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 145,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE6E8EF),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Icon(
              icon,
              color: const Color(0xFF3B5BDB),
              size: 28,
            ),

            const Spacer(),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}