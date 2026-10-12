import 'package:flutter/material.dart';

class AssetManagerReportsPage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerReportsPage({
    super.key,
    this.userData,
  });

  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _pageBackground = Color(0xFFF7F8FC);

  @override
  Widget build(BuildContext context) {
    final reports = <_ReportItem>[
      const _ReportItem(
        icon: Icons.inventory_2_outlined,
        title: 'Asset Inventory',
        subtitle: 'Overview of all organization assets',
      ),
      const _ReportItem(
        icon: Icons.assignment_turned_in_outlined,
        title: 'Assignment Report',
        subtitle: 'Assets currently assigned to employees',
      ),
      const _ReportItem(
        icon: Icons.build_outlined,
        title: 'Maintenance Report',
        subtitle: 'Maintenance activity and pending work',
      ),
      const _ReportItem(
        icon: Icons.swap_horiz_rounded,
        title: 'Transfer Report',
        subtitle: 'Asset transfer history across the organization',
      ),
    ];

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          children: [
            const Text(
              'Reports',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'View and download reports about your organization’s assets.',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'AVAILABLE REPORTS',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            ...reports.map(
              (report) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReportCard(
                  report: report,
                  onTap: () => _showReportMessage(context, report.title),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportMessage(BuildContext context, String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$title will be generated.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}

class _ReportCard extends StatelessWidget {
  final _ReportItem report;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.onTap,
  });

  static const Color _primary = Color(0xFF3157D5);
  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE9ECF3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  report.icon,
                  color: _primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      report.subtitle,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.download_outlined,
                color: _primary,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ReportItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}