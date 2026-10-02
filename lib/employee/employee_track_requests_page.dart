import 'package:flutter/material.dart';

class EmployeeTrackRequestsPage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const EmployeeTrackRequestsPage({
    super.key,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Requests'),
      ),
      body: const Center(
        child: Text('Your requests will appear here.'),
      ),
    );
  }
}