import 'package:flutter/material.dart';

class MyRequest extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const MyRequest({
    super.key,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF222222),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'My Request',
          style: TextStyle(
            color: Color(0xFF202020),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: const Center(
        child: Text(
          'Track Request',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF202020),
          ),
        ),
      ),
    );
  }
}