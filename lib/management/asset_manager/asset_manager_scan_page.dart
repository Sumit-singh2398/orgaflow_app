import 'package:flutter/material.dart';

class AssetManagerScanPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerScanPage({
    super.key,
    this.userData,
  });

  @override
  State<AssetManagerScanPage> createState() =>
      _AssetManagerScanPageState();
}

class _AssetManagerScanPageState
    extends State<AssetManagerScanPage> {
  final TextEditingController codeController =
      TextEditingController();

  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 30),

          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE1E5EC),
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: Color(0xFF3157D5),
                ),
                SizedBox(height: 15),
                Text(
                  'Scan QR / Barcode',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Scan an asset code to view details.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          TextField(
            controller: codeController,
            decoration: InputDecoration(
              labelText: 'Asset Code',
              hintText: 'Example: AST-000102',
              prefixIcon: const Icon(Icons.qr_code),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (codeController.text.trim().isEmpty) {
                  return;
                }

                setState(() {
                  scanned = true;
                });
              },
              child: const Text('Find Asset'),
            ),
          ),

          if (scanned) ...[
            const SizedBox(height: 25),
            _assetResult(),
          ],
        ],
      ),
    );
  }

  Widget _assetResult() {
    return Card(
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8EDFF),
          child: Icon(
            Icons.devices_other,
            color: Color(0xFF3157D5),
          ),
        ),
        title: const Text(
          'Asset Found',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Asset ID: ${codeController.text.trim()}\nStatus: Assigned',
        ),
      ),
    );
  }
}