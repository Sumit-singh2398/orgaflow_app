
import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const Color primaryColor = Color(0xFF3B5BDB);
  static const Color backgroundColor = Color(0xFFF5F7FC);
  static const Color textColor = Color(0xFF202944);
  static const Color secondaryTextColor = Color(0xFF737D94);

  static const List<_TermsSection> sections = [
    _TermsSection(
      title: 'Acceptance of Terms',
      icon: Icons.verified_user_outlined,
      content:
          'By accessing or using Orgaflow, you agree to follow these '
          'Terms & Conditions. If you do not agree with these terms, '
          'you should not use the application.',
    ),
    _TermsSection(
      title: 'Account Registration',
      icon: Icons.person_outline_rounded,
      content:
          'Users must provide accurate information while creating an '
          'account. Users are responsible for maintaining the security '
          'of their login credentials and account. Any suspected '
          'unauthorized access should be reported to the administrator.',
    ),
    _TermsSection(
      title: 'Authorized Use',
      icon: Icons.security_outlined,
      content:
          'Orgaflow is intended for authorized organizational use. '
          'Users should only access information, assets, requests, '
          'and features that they are permitted to access.',
    ),
    _TermsSection(
      title: 'User Roles & Permissions',
      icon: Icons.admin_panel_settings_outlined,
      content:
          'Access to management features is controlled by the '
          'organization and application backend. Selecting a management '
          'portal does not itself grant administrative or management '
          'permissions.',
    ),
    _TermsSection(
      title: 'Asset Management',
      icon: Icons.inventory_2_outlined,
      content:
          'Asset information, assignments, transfers, maintenance '
          'records, and related activities should be entered accurately '
          'and only by authorized users.',
    ),
    _TermsSection(
      title: 'Prohibited Activities',
      icon: Icons.gpp_bad_outlined,
      content:
          'Users must not attempt to access another user’s account, '
          'bypass authorization controls, manipulate organizational '
          'records without permission, or use Orgaflow for unlawful '
          'or unauthorized activities.',
    ),
    _TermsSection(
      title: 'Service Availability',
      icon: Icons.cloud_outlined,
      content:
          'The availability of Orgaflow may depend on application '
          'servers, databases, internet connectivity, authentication '
          'providers, and other technical services. Temporary '
          'interruptions may occur.',
    ),
    _TermsSection(
      title: 'Account Suspension',
      icon: Icons.no_accounts_outlined,
      content:
          'An organization administrator may suspend or deactivate '
          'an account when required for security, organizational policy, '
          'or other legitimate administrative reasons.',
    ),
    _TermsSection(
      title: 'Changes to Terms',
      icon: Icons.update_rounded,
      content:
          'These Terms & Conditions may be updated when application '
          'features, policies, or requirements change. The updated '
          'version should be reviewed before continuing to use Orgaflow.',
    ),
    _TermsSection(
      title: 'Contact & Support',
      icon: Icons.support_agent_rounded,
      content:
          'For questions about these Terms & Conditions, please contact '
          'your organization or the Orgaflow administrator.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  const SizedBox(height: 22),
                  _buildInformationCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'TERMS OF SERVICE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...sections.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SectionCard(
                        number: entry.key + 1,
                        section: entry.value,
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  _buildFooter(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B5BDB),
            Color(0xFF5877EE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Terms & Conditions',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.7,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Please read these terms carefully before using Orgaflow.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                  size: 15,
                ),
                SizedBox(width: 7),
                Text(
                  'Last updated: August 2026',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAF3)),
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
                  'Your use of Orgaflow',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'These terms explain your responsibilities, '
                  'account permissions, and acceptable use of the app.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEDFA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: primaryColor,
            size: 28,
          ),
          SizedBox(height: 10),
          Text(
            'Thank you for using Orgaflow',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Use the platform responsibly and help keep '
            'organizational information secure.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.6,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsSection {
  final String title;
  final IconData icon;
  final String content;

  const _TermsSection({
    required this.title,
    required this.icon,
    required this.content,
  });
}

class _SectionCard extends StatelessWidget {
  final int number;
  final _TermsSection section;

  const _SectionCard({
    required this.number,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8EBF3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25345C).withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF1FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  section.icon,
                  color: TermsConditionsScreen.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: TermsConditionsScreen.textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  number.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: TermsConditionsScreen.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF0F1F6),
          ),
          const SizedBox(height: 12),
          Text(
            section.content,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.75,
              color: TermsConditionsScreen.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}