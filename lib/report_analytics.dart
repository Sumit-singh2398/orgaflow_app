import 'package:flutter/material.dart';

class ReportAnalyticsScreen extends StatelessWidget {
  const ReportAnalyticsScreen({super.key});

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
              // TOP HEADER: Back Button, Title & Share Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        'Reports & Analytics',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Color(0xFF1A1A1A), size: 22),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ASSET UTILIZATION CHART CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Asset Utilization',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                        ),
                        Text(
                          '+8.4%',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Custom Bar Chart Simulation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar(40),
                        _buildBar(65),
                        _buildBar(90),
                        _buildBar(55),
                        _buildBar(95),
                        _buildBar(75),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ROW: Assets by Department & Maintenance Frequency
              Row(
                children: [
                  // Assets by Department Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEFEFEF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Assets by Department',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: 0.72,
                              backgroundColor: const Color(0xFFEFEFEF),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B5BDB)),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'IT · 72%',
                            style: TextStyle(fontSize: 12, color: Color(0xFF777777), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Maintenance Frequency Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEFEFEF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Maintenance Frequency',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: 0.4,
                              backgroundColor: const Color(0xFFEFEFEF),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '12 this month',
                            style: TextStyle(fontSize: 12, color: Color(0xFF777777), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // BOOKING USAGE CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Booking Usage',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF777777)),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '86%',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Conference rooms · August',
                      style: TextStyle(fontSize: 13, color: Color(0xFF777777)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // EXPORT REPORT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                  label: const Text(
                    'Export Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  // Helper widget to build vertical bar chart lines
  static Widget _buildBar(double height) {
    return Container(
      width: 26,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF3B5BDB),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}