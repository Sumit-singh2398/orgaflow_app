import 'package:flutter/material.dart';

class EmployeeAssetsPage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const EmployeeAssetsPage({
    super.key,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Assets',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}