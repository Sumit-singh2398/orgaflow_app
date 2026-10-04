
import 'package:flutter/material.dart';

class AssetManagerRequestsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerRequestsPage({
    super.key,
    this.userData,
  });

  @override
  State<AssetManagerRequestsPage> createState() =>
      _AssetManagerRequestsPageState();
}

class _AssetManagerRequestsPageState
    extends State<AssetManagerRequestsPage> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> requests = [
    {
      'id': 'REQ-1001',
      'employee': 'Rahul Sharma',
      'department': 'IT',
      'asset': 'Dell Latitude 5420',
      'category': 'Laptop',
      'date': '04 Oct 2026',
      'status': 'Pending',
      'priority': 'High',
      'reason': 'Required for software development work.',
    },
    {
      'id': 'REQ-1002',
      'employee': 'Priya Verma',
      'department': 'HR',
      'asset': 'Samsung Galaxy A55',
      'category': 'Mobile',
      'date': '03 Oct 2026',
      'status': 'Pending',
      'priority': 'Medium',
      'reason': 'Required for official communication.',
    },
    {
      'id': 'REQ-1003',
      'employee': 'Aman Gupta',
      'department': 'Marketing',
      'asset': 'DSLR Camera',
      'category': 'Camera',
      'date': '03 Oct 2026',
      'status': 'Approved',
      'priority': 'Medium',
      'reason': 'Required for marketing content creation.',
    },
    {
      'id': 'REQ-1004',
      'employee': 'Neha Singh',
      'department': 'Finance',
      'asset': 'Dell Latitude 5420',
      'category': 'Laptop',
      'date': '02 Oct 2026',
      'status': 'Rejected',
      'priority': 'Low',
      'reason': 'No available laptop currently.',
    },
    {
      'id': 'REQ-1005',
      'employee': 'Arjun Mehta',
      'department': 'IT',
      'asset': 'Wi-Fi Router',
      'category': 'Network',
      'date': '01 Oct 2026',
      'status': 'Pending',
      'priority': 'High',
      'reason': 'Required for a new office setup.',
    },
  ];

  List<Map<String, dynamic>> get filteredRequests {
    if (selectedFilter == 'All') {
      return requests;
    }

    return requests
        .where(
          (request) =>
              request['status'] == selectedFilter,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSummary(),
            _buildFilters(),
            Expanded(
              child: _buildRequestList(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        16,
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.pending_actions_outlined,
              color: Color(0xFF3157D5),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Asset Requests',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Review and manage employee requests',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _refreshRequests,
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFF3157D5),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    final pending = requests
        .where(
          (request) =>
              request['status'] == 'Pending',
        )
        .length;

    final approved = requests
        .where(
          (request) =>
              request['status'] == 'Approved',
        )
        .length;

    final rejected = requests
        .where(
          (request) =>
              request['status'] == 'Rejected',
        )
        .length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        18,
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              title: 'Pending',
              value: pending.toString(),
              icon: Icons.hourglass_empty,
              iconColor: Colors.orange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryCard(
              title: 'Approved',
              value: approved.toString(),
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryCard(
              title: 'Rejected',
              value: rejected.toString(),
              icon: Icons.cancel_outlined,
              iconColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE7EAF2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 23,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        15,
        18,
        12,
      ),
      color: const Color(0xFFF6F8FC),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterButton('All'),
            _filterButton('Pending'),
            _filterButton('Approved'),
            _filterButton('Rejected'),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String filter) {
    final bool selected =
        selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(filter),
        selected: selected,
        onSelected: (_) {
          setState(() {
            selectedFilter = filter;
          });
        },
        selectedColor:
            const Color(0xFF3157D5),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : const Color(0xFF4B5563),
          fontWeight: selected
              ? FontWeight.bold
              : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected
              ? const Color(0xFF3157D5)
              : const Color(0xFFE1E5EE),
        ),
      ),
    );
  }

  // ============================================================
  // REQUEST LIST
  // ============================================================

  Widget _buildRequestList() {
    final data = filteredRequests;

    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        18,
        4,
        18,
        25,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _requestCard(data[index]);
      },
    );
  }

  // ============================================================
  // REQUEST CARD
  // ============================================================

  Widget _requestCard(
    Map<String, dynamic> request,
  ) {
    final status =
        request['status']?.toString() ?? 'Pending';

    final priority =
        request['priority']?.toString() ?? 'Low';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE8EAF0),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showRequestDetails(request);
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _employeeAvatar(
                    request['employee']
                        ?.toString() ??
                        'Employee',
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          request['employee']
                                  ?.toString() ??
                              'Employee',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Color(0xFF172033),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${request['department']} • ${request['id']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color:
                                Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _statusBadge(status),
                ],
              ),

              const SizedBox(height: 15),

              Container(
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFF8F9FD),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.devices_other_outlined,
                      size: 21,
                      color:
                          Color(0xFF3157D5),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            request['asset']
                                    ?.toString() ??
                                'Asset',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                              color:
                                  Color(0xFF172033),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            request['category']
                                    ?.toString() ??
                                'Category',
                            style:
                                const TextStyle(
                              fontSize: 12,
                              color:
                                  Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _priorityBadge(priority),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color:
                        Color(0xFF6B7280),
                  ),

                  const SizedBox(width: 5),

                  Text(
                    request['date']
                            ?.toString() ??
                        '',
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          Color(0xFF6B7280),
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(0xFF3157D5),
                    ),
                  ),

                  const SizedBox(width: 3),

                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color:
                        Color(0xFF3157D5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPLOYEE AVATAR
  // ============================================================

  Widget _employeeAvatar(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+'));

    String initials = 'E';

    if (parts.length >= 2) {
      initials =
          '${parts.first[0]}${parts.last[0]}'
              .toUpperCase();
    } else if (parts.isNotEmpty &&
        parts.first.isNotEmpty) {
      initials =
          parts.first[0].toUpperCase();
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor:
          const Color(0xFFE8EDFF),
      child: Text(
        initials,
        style: const TextStyle(
          color: Color(0xFF3157D5),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(String status) {
    Color background;
    Color textColor;

    switch (status) {
      case 'Approved':
        background =
            const Color(0xFFE8F7EE);
        textColor =
            const Color(0xFF16834A);
        break;

      case 'Rejected':
        background =
            const Color(0xFFFFEAEA);
        textColor =
            const Color(0xFFD92D20);
        break;

      default:
        background =
            const Color(0xFFFFF4E5);
        textColor =
            const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // PRIORITY BADGE
  // ============================================================

  Widget _priorityBadge(String priority) {
    Color color;

    switch (priority) {
      case 'High':
        color = Colors.red;
        break;

      case 'Medium':
        color = Colors.orange;
        break;

      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFE8EDFF),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 40,
                color:
                    Color(0xFF3157D5),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No Requests Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF172033),
              ),
            ),

            const SizedBox(height: 7),

            Text(
              selectedFilter == 'All'
                  ? 'There are no asset requests.'
                  : 'There are no $selectedFilter requests.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color:
                    Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REQUEST DETAILS
  // ============================================================

  void _showRequestDetails(
    Map<String, dynamic> request,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              25,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Request Details',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Color(0xFF172033),
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  _detailRow(
                    'Request ID',
                    request['id'],
                  ),

                  _detailRow(
                    'Employee',
                    request['employee'],
                  ),

                  _detailRow(
                    'Department',
                    request['department'],
                  ),

                  _detailRow(
                    'Requested Asset',
                    request['asset'],
                  ),

                  _detailRow(
                    'Category',
                    request['category'],
                  ),

                  _detailRow(
                    'Request Date',
                    request['date'],
                  ),

                  _detailRow(
                    'Priority',
                    request['priority'],
                  ),

                  _detailRow(
                    'Status',
                    request['status'],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Reason',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(13),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xFFF6F8FC),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Text(
                      request['reason']
                              ?.toString() ??
                          'No reason provided.',
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF4B5563),
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  if (request['status'] ==
                      'Pending')
                    Row(
                      children: [
                        Expanded(
                          child:
                              _decisionButton(
                            label: 'Reject',
                            icon:
                                Icons.close,
                            color:
                                Colors.red,
                            onTap: () {
                              Navigator.pop(
                                context,
                              );
                              _updateStatus(
                                request,
                                'Rejected',
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child:
                              _decisionButton(
                            label: 'Approve',
                            icon:
                                Icons.check,
                            color:
                                Colors.green,
                            onTap: () {
                              Navigator.pop(
                                context,
                              );
                              _updateStatus(
                                request,
                                'Approved',
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        child: const Text(
                          'Close',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    String title,
    dynamic value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color:
                    Color(0xFF6B7280),
              ),
            ),
          ),

          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
                color:
                    Color(0xFF172033),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DECISION BUTTON
  // ============================================================

  Widget _decisionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 18,
      ),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(
          vertical: 13,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  void _updateStatus(
    Map<String, dynamic> request,
    String newStatus,
  ) {
    setState(() {
      request['status'] = newStatus;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          newStatus == 'Approved'
              ? 'Request approved successfully.'
              : 'Request rejected successfully.',
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // REFRESH
  // ============================================================

  void _refreshRequests() {
    setState(() {});

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Requests refreshed.',
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
}
