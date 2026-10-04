import 'package:flutter/material.dart';

class AssetManagerTransferPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerTransferPage({
    super.key,
    this.userData,
  });

  @override
  State<AssetManagerTransferPage> createState() =>
      _AssetManagerTransferPageState();
}

class _AssetManagerTransferPageState
    extends State<AssetManagerTransferPage> {
  String? asset;
  String? fromEmployee;
  String? toEmployee;

  final assets = [
    'AST-001 - Dell Latitude 5420',
    'AST-002 - Samsung Galaxy A55',
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
          'Transfer Asset',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Transfer an assigned asset to another employee.',
          style: TextStyle(
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 25),

        _dropdown(
          'Asset',
          asset,
          assets,
          (value) => setState(() => asset = value),
        ),

        const SizedBox(height: 18),

        _dropdown(
          'Current Employee',
          fromEmployee,
          employees,
          (value) => setState(() => fromEmployee = value),
        ),

        const SizedBox(height: 18),

        _dropdown(
          'Transfer To',
          toEmployee,
          employees,
          (value) => setState(() => toEmployee = value),
        ),

        const SizedBox(height: 25),

        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: asset == null ||
                    fromEmployee == null ||
                    toEmployee == null ||
                    fromEmployee == toEmployee
                ? null
                : _transfer,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Transfer Asset'),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
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

  void _transfer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Asset transferred successfully.'),
      ),
    );
  }
}