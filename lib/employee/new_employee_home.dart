import 'package:flutter/material.dart';

class NewEmployeeHome extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const NewEmployeeHome({
    super.key,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final String name =
        userData?['name']?.toString() ?? 'Employee';

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
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            Text(
              'Welcome, $name 👋',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your employee account has been created successfully.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF777777),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 25),

            // PROFILE SETUP
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3B5BDB),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Icon(
                    Icons.person_add_alt_1,
                    color: Colors.white,
                    size: 32,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Complete your profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Add your employee information to get started with Orgaflow.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF3B5BDB),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Complete Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Getting Started',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            _buildGettingStartedCard(
              icon: Icons.person_outline,
              title: 'Set Up Profile',
              subtitle: 'Add your employee information',
            ),

            const SizedBox(height: 12),

            _buildGettingStartedCard(
              icon: Icons.devices_outlined,
              title: 'Assigned Assets',
              subtitle: 'Your assets will appear here once assigned',
            ),

            const SizedBox(height: 12),

            _buildGettingStartedCard(
              icon: Icons.notifications_none,
              title: 'Notifications',
              subtitle: 'Important updates will appear here',
            ),

            const SizedBox(height: 25),

            // INFORMATION
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE6E8EF),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF3B5BDB),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Your account is currently an Employee account. '
                      'Assets and organization resources will become '
                      'available according to your assignment.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
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
            icon: Icon(Icons.notifications_none),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildGettingStartedCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
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
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3B5BDB),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }
}