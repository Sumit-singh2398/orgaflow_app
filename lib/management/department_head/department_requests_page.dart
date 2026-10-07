import 'package:flutter/material.dart';

class DepartmentRequestsPage extends StatelessWidget {
  const DepartmentRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = [
      ['Rahul Sharma', 'Dell Laptop', 'Pending'],
      ['Priya Singh', 'Samsung Mobile', 'Approved'],
      ['Aman Kumar', 'Canon DSLR', 'Pending'],
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Requests',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text('Employee asset requests'),
        const SizedBox(height: 18),

        ...requests.map(
          (r) => Card(
            child: ListTile(
              leading: const Icon(
                Icons.assignment_outlined,
                color: Color(0xFF3B5BDB),
              ),
              title: Text(
                r[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(r[1]),
              trailing: Text(
                r[2],
                style: TextStyle(
                  color: r[2] == 'Approved'
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}