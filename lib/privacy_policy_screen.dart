import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color primaryColor = Color(0xFF3B5BDB);
  static const Color backgroundColor = Color(0xFFEDEFF5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
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
                'Privacy Policy',
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

              _SectionTitle('1. Information We Collect'),
              _SectionText(
                'Orgaflow may collect information such as your name, '
                'email address, phone number, employee details, department '
                'information, and asset-related information required to '
                'provide the services of the application.',
              ),

              _SectionTitle('2. How We Use Your Information'),
              _SectionText(
                'The information collected through Orgaflow is used to '
                'authenticate users, manage employee accounts, assign and '
                'track organizational assets, handle maintenance requests, '
                'send notifications, and provide other application features, '
              ),

              _SectionTitle('3. Account Information'),
              _SectionText(
                'Users are responsible for providing accurate information '
                'during account creation and for keeping their account '
                'credentials secure.',
              ),

              _SectionTitle('4. Google Sign-In'),
              _SectionText(
                'If you choose to sign in using Google, Orgaflow may receive '
                'basic account information provided by Google, such as your '
                'name, email address, and Google account identifier. This '
                'information is used for authentication and account linking,' 
              ),

              _SectionTitle('5. Asset Information'),
              _SectionText(
                'Asset identifiers, assignment information, maintenance '
                'requests, and related records may be stored in the Orgaflow '
                'backend to support organizational asset management.',
              ),

              _SectionTitle('6. Data Security'),
              _SectionText(
                'Orgaflow is designed to protect user and organizational '
                'information using authentication, access control, password '
                'hashing, and secure communication practices where applicable.',
              ),

              _SectionTitle('7. Third-Party Services'),
              _SectionText(
                'Orgaflow may use third-party services such as Google '
                'authentication and cloud or hosting services required for '
                'application functionality.',
              ),

              _SectionTitle('8. Data Retention'),
              _SectionText(
                'Account and organizational data may be retained for as long '
                'as required to provide the application services or according '
                'to the organization’s data-retention requirements.',
              ),

              _SectionTitle('9. Changes to This Policy'),
              _SectionText(
                'This Privacy Policy may be updated when application '
                'features, security practices, or applicable requirements '
                'change. Users should review this page periodically.',
              ),

              _SectionTitle('10. Contact'),
              _SectionText(
                'For questions regarding privacy or the use of personal '
                'information within Orgaflow, please contact the appropriate '
                'organization or application administrator.',
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
          color: PrivacyPolicyScreen.primaryColor,
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