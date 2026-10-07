import 'package:flutter/material.dart';

class DepartmentHeadProfilePage extends StatelessWidget {
  const DepartmentHeadProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 15),

          const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFF3B5BDB),
            child: Text(
              'DH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 15),

          const Center(
            child: Text(
              'Department Head',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 25),

          _info('Email', 'department.head@example.com'),
          _info('Department', 'Department Name'),
          _info('Role', 'Department Head'),
          _info('Status', 'Active'),
        ],
      ),
    );
  }

  Widget _info(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}