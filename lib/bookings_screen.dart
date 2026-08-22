import 'package:flutter/material.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

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
          
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Resource Booking',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month_outlined, color: Color(0xFF1A1A1A), size: 24),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

            
              Row(
                children: [
                  _buildTabButton('Today', true),
                  const SizedBox(width: 8),
                  _buildTabButton('Week', false),
                  const SizedBox(width: 8),
                  _buildTabButton('Month', false),
                ],
              ),
              const SizedBox(height: 16),

              
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
                      'Conference Room A',
                      style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Color(0xFF888888)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

        
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    _DateCard(day: 'Mo', date: '18', isSelected: false),
                    SizedBox(width: 8),
                    _DateCard(day: 'Tu', date: '19', isSelected: false),
                    SizedBox(width: 8),
                    _DateCard(day: 'We', date: '20', isSelected: false),
                    SizedBox(width: 8),
                    _DateCard(day: 'Th', date: '21', isSelected: false),
                    SizedBox(width: 8),
                    _DateCard(day: 'Fr', date: '22', isSelected: true), 
                    SizedBox(width: 8),
                    _DateCard(day: 'Sa', date: '23', isSelected: false),
                    SizedBox(width: 8),
                    _DateCard(day: 'Su', date: '24', isSelected: false),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              
              const Text(
                'Friday, 22 August',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),

              
              _buildTimeSlotRow('09:00', 'Booked', Colors.red.shade700, Colors.red.withOpacity(0.08)),
              const SizedBox(height: 10),
              _buildTimeSlotRow('10:00', 'Available', Colors.green.shade700, Colors.green.withOpacity(0.12)),
              const SizedBox(height: 10),
              _buildTimeSlotRow('11:00', 'Booked', Colors.red.shade700, Colors.red.withOpacity(0.08)),
              const SizedBox(height: 10),
              _buildTimeSlotRow('12:00', 'Available', Colors.green.shade700, Colors.green.withOpacity(0.12)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF3B5BDB),
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  
  static Widget _buildTabButton(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF3B5BDB).withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF3B5BDB) : const Color(0xFFEFEFEF),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF3B5BDB) : const Color(0xFF666666),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }


  static Widget _buildTimeSlotRow(String time, String status, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final String day;
  final String date;
  final bool isSelected;

  const _DateCard({
    required this.day,
    required this.date,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF3B5BDB) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF3B5BDB) : const Color(0xFFEFEFEF),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white70 : const Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}