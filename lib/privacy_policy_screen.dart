
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color primaryColor = Color(0xFF3B5BDB);
  static const Color backgroundColor = Color(0xFFEDEFF5);
  static const Color textColor = Color(0xFF202945);
  static const Color secondaryTextColor = Color(0xFF737B91);
  static const Color cardColor = Colors.white;

  static const List<_PolicySection> sections = [
    _PolicySection(
      title: 'Information We Collect',
      icon: Icons.folder_shared_outlined,
      content:
          'Orgaflow may collect your name, email address, phone number, '
          'employee details, department information, and asset-related '
          'information needed to provide application services.',
    ),
    _PolicySection(
      title: 'How We Use Your Information',
      icon: Icons.track_changes_rounded,
      content:
          'Your information helps us authenticate users, manage employee '
          'accounts, assign and track organizational assets, handle '
          'maintenance requests, send notifications, and provide application '
          'features.',
    ),
    _PolicySection(
      title: 'Account Information',
      icon: Icons.manage_accounts_outlined,
      content:
          'Please provide accurate information when creating your account. '
          'You are responsible for keeping your login credentials secure '
          'and preventing unauthorized access to your account.',
    ),
    _PolicySection(
      title: 'Google Sign-In',
      icon: Icons.g_mobiledata_rounded,
      content:
          'When you sign in with Google, Orgaflow may receive basic account '
          'information such as your name, email address, and Google account '
          'identifier. This information is used for authentication and '
          'account linking.',
    ),
    _PolicySection(
      title: 'Asset Information',
      icon: Icons.devices_other_rounded,
      content:
          'Asset identifiers, assignment details, maintenance requests, '
          'and related records may be stored in the Orgaflow backend to '
          'support organizational asset management.',
    ),
    _PolicySection(
      title: 'Data Security',
      icon: Icons.shield_outlined,
      content:
          'Orgaflow is designed to protect user and organizational '
          'information through authentication, access controls, password '
          'hashing, and secure communication practices where applicable.',
    ),
    _PolicySection(
      title: 'Third-Party Services',
      icon: Icons.hub_outlined,
      content:
          'Orgaflow may use third-party services, including Google '
          'authentication and hosting services, to support application '
          'functionality.',
    ),
    _PolicySection(
      title: 'Data Retention',
      icon: Icons.storage_outlined,
      content:
          'Account and organizational data may be retained for as long '
          'as necessary to provide application services or to meet the '
          'organization’s applicable data-retention requirements.',
    ),
    _PolicySection(
      title: 'Policy Updates',
      icon: Icons.update_rounded,
      content:
          'This Privacy Policy may change as application features, '
          'security practices, or applicable requirements evolve. '
          'Please review this page periodically for updates.',
    ),
    _PolicySection(
      title: 'Contact & Support',
      icon: Icons.support_agent_rounded,
      content:
          'For questions about privacy or the use of personal information '
          'within Orgaflow, please contact your organization or application '
          'administrator.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeroCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'YOUR PRIVACY MATTERS',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 11,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Understand how your data is handled.',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 21,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Here is a breakdown of the information '
                    'Orgaflow uses and why it matters.',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...sections.asMap().entries.map((entry) {
                    final index = entry.key;
                    final section = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PolicyCard(
                        number: index + 1,
                        section: section,
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  _buildFooterCard(),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'ORGAFLOW  •  PRIVACY & TRUST',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
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
          colors: [
            Color(0xFF3B5BDB),
            Color(0xFF647CF0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your data.\nYour trust.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1.18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Learn how Orgaflow handles your information '
            'while helping your organization manage assets.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 14,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'Last updated: October 2026',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EAFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.10),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: primaryColor,
            size: 23,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Questions about your privacy?',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Contact your organization or Orgaflow '
                  'administrator for clarification about data '
                  'handling and account information.',
                  style: TextStyle(
                    color: Color(0xFF626D8A),
                    fontSize: 13,
                    height: 1.6,
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

class _PolicySection {
  final String title;
  final IconData icon;
  final String content;

  const _PolicySection({
    required this.title,
    required this.icon,
    required this.content,
  });
}

class _PolicyCard extends StatelessWidget {
  final int number;
  final _PolicySection section;

  const _PolicyCard({
    required this.number,
    required this.section,
  });

  static const Color primaryColor = PrivacyPolicyScreen.primaryColor;
  static const Color textColor = PrivacyPolicyScreen.textColor;
  static const Color secondaryTextColor =
      PrivacyPolicyScreen.secondaryTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8EAF1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172554).withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF1FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              section.icon,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${number.toString().padLeft(2, '0')}  /  10',
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  section.title,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  section.content,
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13,
                    height: 1.7,
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