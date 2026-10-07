import 'package:flutter/material.dart';

class AssetManagerAssetsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AssetManagerAssetsPage({
    super.key,
    this.userData,
  });

  @override
  State<AssetManagerAssetsPage> createState() =>
      _AssetManagerAssetsPageState();
}

class _AssetManagerAssetsPageState
    extends State<AssetManagerAssetsPage> {
  final TextEditingController searchController =
      TextEditingController();

  // ============================================================
  // ASSETS
  // ============================================================

  final List<Map<String, dynamic>> assets = [
    {
      'id': 'AST-001',
      'name': 'Dell Latitude 5420',
      'category': 'Laptop',
      'employee': 'Rahul Sharma',
      'status': 'Assigned',
      'visibleToEmployees': true,
    },
    {
      'id': 'AST-002',
      'name': 'Samsung Galaxy A55',
      'category': 'Mobile',
      'employee': 'Neha Singh',
      'status': 'Assigned',
      'visibleToEmployees': true,
    },
    {
      'id': 'AST-003',
      'name': 'Canon DSLR Camera',
      'category': 'Camera',
      'employee': '',
      'status': 'Available',
      'visibleToEmployees': true,
    },
    {
      'id': 'AST-004',
      'name': 'Epson Projector',
      'category': 'Projector',
      'employee': '',
      'status': 'Maintenance',
      'visibleToEmployees': false,
    },
    {
      'id': 'AST-005',
      'name': 'HP LaserJet Printer',
      'category': 'Printer',
      'employee': '',
      'status': 'Available',
      'visibleToEmployees': true,
    },
    {
      'id': 'AST-006',
      'name': 'Logitech Wireless Keyboard',
      'category': 'Accessories',
      'employee': 'Aman Verma',
      'status': 'Assigned',
      'visibleToEmployees': true,
    },
    {
      'id': 'AST-007',
      'name': 'Logitech Wireless Mouse',
      'category': 'Accessories',
      'employee': '',
      'status': 'Available',
      'visibleToEmployees': true,
    },
    {
      'id': 'AST-008',
      'name': 'TP-Link Wi-Fi Router',
      'category': 'Networking',
      'employee': '',
      'status': 'Available',
      'visibleToEmployees': true,
    },
    {
      'id': 'AST-009',
      'name': 'UPS 1100VA',
      'category': 'Power',
      'employee': '',
      'status': 'Maintenance',
      'visibleToEmployees': false,
    },
    {
      'id': 'AST-010',
      'name': 'Conference Room Display',
      'category': 'Display',
      'employee': '',
      'status': 'Available',
      'visibleToEmployees': true,
    },
  ];

  // ============================================================
  // EMPLOYEE LIST
  // Later this will come from backend/API
  // ============================================================

  final List<String> employees = [
    'Rahul Sharma',
    'Neha Singh',
    'Aman Verma',
    'Priya Gupta',
    'Rohit Kumar',
    'Not Assigned',
  ];

  // ============================================================
  // CATEGORIES
  // ============================================================

  final List<String> categories = [
    'Laptop',
    'Mobile',
    'Camera',
    'Projector',
    'Printer',
    'Accessories',
    'Networking',
    'Power',
    'Display',
    'Other',
  ];

  // ============================================================
  // STATUS
  // ============================================================

  final List<String> statuses = [
    'Available',
    'Assigned',
    'Maintenance',
    'Retired',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --------------------------------------------------------
        // SEARCH + ADD BUTTON
        // --------------------------------------------------------

        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            10,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Search assets...',
                    prefixIcon: const Icon(
                      Icons.search,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // ADD ASSET
              SizedBox(
                height: 52,
                width: 52,
                child: ElevatedButton(
                  onPressed: _showAddAssetDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF3157D5),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ),

        // --------------------------------------------------------
        // ASSET COUNT
        // --------------------------------------------------------

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 5,
          ),
          child: Row(
            children: [
              Text(
                '${_filteredAssets.length} Assets',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              Text(
                '${assets.where((a) => a['status'] == 'Available').length} Available',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // --------------------------------------------------------
        // ASSET LIST
        // --------------------------------------------------------

        Expanded(
          child: _filteredAssets.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    20,
                  ),
                  itemCount: _filteredAssets.length,
                  itemBuilder: (context, index) {
                    final asset =
                        _filteredAssets[index];

                    return _assetCard(asset);
                  },
                ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<Map<String, dynamic>> get _filteredAssets {
    final query =
        searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return assets;
    }

    return assets.where((asset) {
      return asset['name']
              .toString()
              .toLowerCase()
              .contains(query) ||
          asset['id']
              .toString()
              .toLowerCase()
              .contains(query) ||
          asset['category']
              .toString()
              .toLowerCase()
              .contains(query) ||
          asset['employee']
              .toString()
              .toLowerCase()
              .contains(query) ||
          asset['status']
              .toString()
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  // ============================================================
  // ASSET CARD
  // ============================================================

  Widget _assetCard(
      Map<String, dynamic> asset) {
    final status =
        asset['status'].toString();

    final employee =
        asset['employee'].toString();

    final visible =
        asset['visibleToEmployees'] == true;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showDetails(asset);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // ICON
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE8EDFF),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  _getCategoryIcon(
                    asset['category']
                        .toString(),
                  ),
                  color:
                      const Color(0xFF3157D5),
                ),
              ),

              const SizedBox(width: 12),

              // DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset['name']
                          .toString(),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${asset['id']} • ${asset['category']}',
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 5),

                    if (employee.isNotEmpty)
                      Text(
                        'Assigned: $employee',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 11,
                          color:
                              Colors.black54,
                        ),
                      )
                    else
                      const Text(
                        'Not Assigned',
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              Colors.black54,
                        ),
                      ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          visible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 13,
                          color: visible
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          visible
                              ? 'Employee visible'
                              : 'Hidden from employees',
                          style: TextStyle(
                            fontSize: 10,
                            color: visible
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _statusChip(status),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _getCategoryIcon(
      String category) {
    switch (category) {
      case 'Laptop':
        return Icons.laptop_mac;

      case 'Mobile':
        return Icons.phone_android;

      case 'Camera':
        return Icons.camera_alt_outlined;

      case 'Projector':
        return Icons.videocam_outlined;

      case 'Printer':
        return Icons.print_outlined;

      case 'Accessories':
        return Icons.keyboard_outlined;

      case 'Networking':
        return Icons.wifi;

      case 'Power':
        return Icons.battery_charging_full;

      case 'Display':
        return Icons.desktop_windows_outlined;

      default:
        return Icons.devices_other_outlined;
    }
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip(String status) {
    Color color;

    switch (status) {
      case 'Available':
        color = Colors.green;
        break;

      case 'Maintenance':
        color = Colors.orange;
        break;

      case 'Retired':
        color = Colors.grey;
        break;

      default:
        color = Colors.blue;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // DETAILS
  // ============================================================

  void _showDetails(
      Map<String, dynamic> asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        final visible =
            asset['visibleToEmployees'] == true;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                asset['name'].toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              _detailRow(
                'Asset ID',
                asset['id'].toString(),
              ),

              _detailRow(
                'Category',
                asset['category'].toString(),
              ),

              _detailRow(
                'Assigned To',
                asset['employee']
                        .toString()
                        .isEmpty
                    ? 'Not Assigned'
                    : asset['employee']
                        .toString(),
              ),

              _detailRow(
                'Status',
                asset['status'].toString(),
              ),

              _detailRow(
                'Employee Visibility',
                visible
                    ? 'Visible'
                    : 'Hidden',
              ),

              const SizedBox(height: 20),

              // EDIT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditAssetDialog(asset);
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  label: const Text(
                    'Edit Asset',
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF3157D5,
                    ),
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // DELETE
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteAsset(asset);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Delete Asset',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
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
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD ASSET
  // ============================================================

  void _showAddAssetDialog() {
    final nameController =
        TextEditingController();

    String selectedCategory =
        categories.first;

    String selectedStatus =
        'Available';

    String selectedEmployee =
        'Not Assigned';

    bool visibleToEmployees = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Add New Asset',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    TextField(
                      controller:
                          nameController,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Asset Name',
                        prefixIcon:
                            const Icon(
                          Icons.devices,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    DropdownButtonFormField<
                        String>(
                      value:
                          selectedCategory,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Category',
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                      ),
                      items:
                          categories.map(
                        (category) {
                          return DropdownMenuItem(
                            value: category,
                            child:
                                Text(category),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedCategory =
                                value;
                          });
                        }
                      },
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    DropdownButtonFormField<
                        String>(
                      value:
                          selectedStatus,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Status',
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                      ),
                      items:
                          statuses.map(
                        (status) {
                          return DropdownMenuItem(
                            value: status,
                            child:
                                Text(status),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedStatus =
                                value;
                          });
                        }
                      },
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    DropdownButtonFormField<
                        String>(
                      value:
                          selectedEmployee,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Assign Employee',
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                      ),
                      items:
                          employees.map(
                        (employee) {
                          return DropdownMenuItem(
                            value: employee,
                            child:
                                Text(employee),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedEmployee =
                                value;
                          });
                        }
                      },
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    SwitchListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      title: const Text(
                        'Show on Employee Dashboard',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Employees can see this asset',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                      value:
                          visibleToEmployees,
                      activeColor:
                          const Color(
                        0xFF3157D5,
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          visibleToEmployees =
                              value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                      const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController
                        .text
                        .trim()
                        .isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter asset name',
                          ),
                        ),
                      );
                      return;
                    }

                    final newId =
                        _generateAssetId();

                    setState(() {
                      assets.add({
                        'id': newId,
                        'name':
                            nameController.text
                                .trim(),
                        'category':
                            selectedCategory,
                        'employee':
                            selectedEmployee ==
                                    'Not Assigned'
                                ? ''
                                : selectedEmployee,
                        'status':
                            selectedStatus,
                        'visibleToEmployees':
                            visibleToEmployees,
                      });
                    });

                    Navigator.pop(
                      dialogContext,
                    );

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Asset added successfully',
                        ),
                        behavior:
                            SnackBarBehavior
                                .floating,
                      ),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF3157D5,
                    ),
                    foregroundColor:
                        Colors.white,
                  ),
                  child:
                      const Text('Add Asset'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // EDIT ASSET
  // ============================================================

  void _showEditAssetDialog(
      Map<String, dynamic> asset) {
    final nameController =
        TextEditingController(
      text: asset['name'].toString(),
    );

    String selectedCategory =
        asset['category'].toString();

    String selectedStatus =
        asset['status'].toString();

    String selectedEmployee =
        asset['employee']
                .toString()
                .isEmpty
            ? 'Not Assigned'
            : asset['employee'].toString();

    bool visibleToEmployees =
        asset['visibleToEmployees'] == true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Edit Asset',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    // NAME
                    TextField(
                      controller:
                          nameController,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Asset Name',
                        prefixIcon:
                            const Icon(
                          Icons.devices,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // CATEGORY
                    DropdownButtonFormField<
                        String>(
                      value:
                          selectedCategory,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Category',
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                      ),
                      items:
                          categories.map(
                        (category) {
                          return DropdownMenuItem(
                            value: category,
                            child:
                                Text(category),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedCategory =
                                value;
                          });
                        }
                      },
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // STATUS
                    DropdownButtonFormField<
                        String>(
                      value:
                          selectedStatus,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Status',
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                      ),
                      items:
                          statuses.map(
                        (status) {
                          return DropdownMenuItem(
                            value: status,
                            child:
                                Text(status),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedStatus =
                                value;
                          });
                        }
                      },
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // EMPLOYEE
                    DropdownButtonFormField<
                        String>(
                      value:
                          employees.contains(
                        selectedEmployee,
                      )
                              ? selectedEmployee
                              : 'Not Assigned',
                      decoration:
                          InputDecoration(
                        labelText:
                            'Assigned Employee',
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                      ),
                      items:
                          employees.map(
                        (employee) {
                          return DropdownMenuItem(
                            value: employee,
                            child:
                                Text(employee),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedEmployee =
                                value;
                          });
                        }
                      },
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // EMPLOYEE VISIBILITY
                    SwitchListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      title: const Text(
                        'Show on Employee Dashboard',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Control employee visibility',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                      value:
                          visibleToEmployees,
                      activeColor:
                          const Color(
                        0xFF3157D5,
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          visibleToEmployees =
                              value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                      const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController
                        .text
                        .trim()
                        .isEmpty) {
                      return;
                    }

                    setState(() {
                      asset['name'] =
                          nameController.text
                              .trim();

                      asset['category'] =
                          selectedCategory;

                      asset['status'] =
                          selectedStatus;

                      asset['employee'] =
                          selectedEmployee ==
                                  'Not Assigned'
                              ? ''
                              : selectedEmployee;

                      asset[
                              'visibleToEmployees'] =
                          visibleToEmployees;
                    });

                    Navigator.pop(
                      dialogContext,
                    );

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Asset updated successfully',
                        ),
                        behavior:
                            SnackBarBehavior
                                .floating,
                      ),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF3157D5,
                    ),
                    foregroundColor:
                        Colors.white,
                  ),
                  child:
                      const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // DELETE ASSET
  // ============================================================

  void _deleteAsset(
      Map<String, dynamic> asset) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Delete Asset?'),
          content: Text(
            'Are you sure you want to delete "${asset['name']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  assets.remove(asset);
                });

                Navigator.pop(
                  dialogContext,
                );

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Asset deleted',
                    ),
                    behavior:
                        SnackBarBehavior
                            .floating,
                  ),
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // GENERATE ASSET ID
  // ============================================================

  String _generateAssetId() {
    int number = assets.length + 1;

    String id =
        'AST-${number.toString().padLeft(3, '0')}';

    while (assets.any(
      (asset) => asset['id'] == id,
    )) {
      number++;

      id =
          'AST-${number.toString().padLeft(3, '0')}';
    }

    return id;
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFE8EDFF),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.search_off,
              size: 35,
              color:
                  Color(0xFF3157D5),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'No assets found',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Try another search term',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}