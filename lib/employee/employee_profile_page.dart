import 'package:flutter/material.dart';

class EmployeeProfilePage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const EmployeeProfilePage({
    super.key,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}