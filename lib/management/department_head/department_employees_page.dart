
import 'package:flutter/material.dart';

class DepartmentEmployeesPage extends StatelessWidget {
  const DepartmentEmployeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final employees = [
      ['Rahul Sharma', 'Developer'],
      ['Priya Singh', 'Designer'],
      ['Aman Kumar', 'Backend Developer'],
      ['Neha Verma', 'HR Executive'],
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Department Employees',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text('Employees in your department'),
        const SizedBox(height: 18),

        ...employees.map(
          (e) => Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8EDFF),
                child: Icon(
                  Icons.person,
                  color: Color(0xFF3B5BDB),
                ),
              ),
              title: Text(
                e[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(e[1]),
              trailing: const Icon(
                Icons.chevron_right,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

