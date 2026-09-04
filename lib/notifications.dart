import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B5BDB),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _NotificationCard(
                title: 'Asset Assigned',
                message: 'Laptop AF-0012 has been assigned to you.',
                time: '10 minutes ago',
                isUnread: true,
              ),
              const SizedBox(height: 14),

              const _NotificationCard(
                title: 'Maintenance Approved',
                message: 'Maintenance request MR-001 has been approved.',
                time: '2 hours ago',
                isUnread: false,
              ),
              const SizedBox(height: 14),

              const _NotificationCard(
                title: 'Booking Reminder',
                message: 'Conference Room A booking starts in 30 minutes.',
                time: 'Today',
                isUnread: false,
              ),
              const SizedBox(height: 14),

              const _NotificationCard(
                title: 'Overdue Return',
                message: 'Asset AF-0096 is overdue.',
                time: 'Yesterday',
                isUnread: false,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final bool isUnread;

  const _NotificationCard({
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B5BDB),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}