import 'package:flutter/material.dart';

class AssetManagerAssignPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerAssignPage({
    super.key,
    this.userData,
  });

  @override
  State<AssetManagerAssignPage> createState() =>
      _AssetManagerAssignPageState();
}

class _AssetManagerAssignPageState
    extends State<AssetManagerAssignPage> {
  String? selectedAsset;
  String? selectedEmployee;

  final assets = [
    'AST-003 - Canon DSLR',
    'AST-005 - Dell Monitor',
    'AST-006 - Keyboard',
  ];

  final employees = [
    'Amit Kumar',
    'Neha Singh',
    'Rahul Sharma',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Assign Asset',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Assign an available asset to an employee.',
          style: TextStyle(
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 25),

        _dropdown(
          label: 'Select Asset',
          value: selectedAsset,
          items: assets,
          onChanged: (value) {
            setState(() {
              selectedAsset = value;
            });
          },
        ),

        const SizedBox(height: 18),

        _dropdown(
          label: 'Select Employee',
          value: selectedEmployee,
          items: employees,
          onChanged: (value) {
            setState(() {
              selectedEmployee = value;
            });
          },
        ),

        const SizedBox(height: 25),

        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: selectedAsset == null ||
                    selectedEmployee == null
                ? null
                : _assignAsset,
            icon: const Icon(Icons.assignment_turned_in),
            label: const Text('Assign Asset'),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  void _assignAsset() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Asset assigned successfully.'),
      ),
    );
  }
}