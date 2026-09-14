import 'package:flutter/material.dart';

class EmployeeRequestsPage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const EmployeeRequestsPage({
    super.key,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Requests',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}