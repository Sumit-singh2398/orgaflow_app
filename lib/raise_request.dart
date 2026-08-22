import 'package:flutter/material.dart';

class RaiseRequestScreen extends StatelessWidget {
  const RaiseRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP HEADER: Back Button & Title
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A), size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Raise Request',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SELECT ASSET FIELD
              const Text(
                'Select Asset',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Laptop AF-0012',
                      style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Color(0xFF888888)),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ISSUE DESCRIPTION FIELD
              const Text(
                'Issue Description',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 6),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Describe the issue...',
                  hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEFEF))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEFEF))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B5BDB))),
                ),
              ),
              const SizedBox(height: 18),

              // PRIORITY SELECTION
              const Text(
                'Priority',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildPriorityChip('Low', false),
                  const SizedBox(width: 10),
                  _buildPriorityChip('Medium', true), // Selected by default as per image
                  const SizedBox(width: 10),
                  _buildPriorityChip('High', false),
                ],
              ),
              const SizedBox(height: 18),

              // UPLOAD PHOTO BUTTON
              const Text(
                'Upload Photo',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.upload_outlined, color: Color(0xFF3B5BDB), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Add issue photo',
                      style: TextStyle(color: Color(0xFF3B5BDB), fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ADDITIONAL NOTES FIELD
              const Text(
                'Additional Notes',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 6),
              TextField(
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Optional notes',
                  hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEFEF))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEFEF))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B5BDB))),
                ),
              ),
              const SizedBox(height: 20),

              // REQUEST WORKFLOW STEPS
              const Text(
                'REQUEST WORKFLOW',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF777777), letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Text('Pending', style: TextStyle(color: Color(0xFF3B5BDB), fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(' > ', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                  Text('Approved', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                  Text(' > ', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                  Text('Assigned', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                  Text(' > ', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                  Text('Resolved', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                ],
              ),
              const SizedBox(height: 30),

              // SUBMIT REQUEST BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Submit Request',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for Priority Chips
  static Widget _buildPriorityChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.amber.withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.amber : const Color(0xFFEFEFEF),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.amber.shade800 : const Color(0xFF666666),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}