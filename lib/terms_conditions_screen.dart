import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const Color primaryColor = Color(0xFF3B5BDB);
  static const Color backgroundColor = Color(0xFFEDEFF5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Terms & Conditions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Last updated: August 2026',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 24),

              _SectionTitle('1. Acceptance of Terms'),
              _SectionText(
                'By accessing or using Orgaflow, you agree to follow these '
                'Terms & Conditions. If you do not agree with these terms, '
                'you should not use the application.',
              ),

              _SectionTitle('2. Account Registration'),
              _SectionText(
                'Users must provide accurate information while creating an '
                'account. Users are responsible for maintaining the security '
                'of their login credentials and account.',
              ),

              _SectionTitle('3. Authorized Use'),
              _SectionText(
                'Orgaflow is intended for authorized organizational use. '
                'Users should only access information, assets, requests, '
                'and features that they are permitted to access.',
              ),

              _SectionTitle('4. User Roles'),
              _SectionText(
                'Access to management features is controlled by the '
                'organization and the application backend. Selecting a '
                'management portal does not itself grant administrative or '
                'management permissions.',
              ),

              _SectionTitle('5. Asset Management'),
              _SectionText(
                'Asset information, assignments, transfers, maintenance '
                'records, and related activities should be entered accurately '
                'and only by authorized users.',
              ),

              _SectionTitle('6. Prohibited Activities'),
              _SectionText(
                'Users must not attempt to access another user’s account, '
                'bypass authorization controls, manipulate organizational '
                'records without permission, or use Orgaflow for unlawful or '
                'unauthorized activities.',
              ),

              _SectionTitle('7. Availability'),
              _SectionText(
                'The availability of Orgaflow may depend on application '
                'servers, databases, internet connectivity, authentication '
                'providers, and other technical services.',
              ),

              _SectionTitle('8. Account Suspension'),
              _SectionText(
                'An organization administrator may suspend or deactivate an '
                'account when required for security, organizational policy, '
                'or other legitimate administrative reasons.',
              ),

              _SectionTitle('9. Changes to Terms'),
              _SectionText(
                'These Terms & Conditions may be updated when application '
                'features, policies, or requirements change. Continued use '
                'of Orgaflow after an update may constitute acceptance of '
                'the revised terms.',
              ),

              _SectionTitle('10. Contact'),
              _SectionText(
                'For questions about these Terms & Conditions, please contact '
                'the appropriate organization or Orgaflow administrator.',
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: TermsConditionsScreen.primaryColor,
        ),
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;

  const _SectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14.5,
        height: 1.6,
        color: Colors.black87,
      ),
    );
  }
}