
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../login_screen.dart';

const Color profilePrimaryColor = Color(0xFF3157D5);
const Color profileSecondaryColor = Color(0xFF5B7CFA);
const Color profileDarkColor = Color(0xFF172033);
const Color profileGreyColor = Color(0xFF6B7280);
const Color profileBackgroundColor = Color(0xFFF6F8FC);
const Color profileSuccessColor = Color(0xFF16A34A);
const Color profileWarningColor = Color(0xFFF59E0B);

class EmployeeProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  final Future<void> Function()? onLogout;

  final void Function(String name, String phone)? onProfileUpdated;

  const EmployeeProfilePage({
    super.key,
    this.userData,
    this.onLogout,
    this.onProfileUpdated,
  });

  @override
  State<EmployeeProfilePage> createState() =>
      _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;

  String? _editedName;
  String? _editedPhone;

  String _read(List<String> keys, String fallback) {
    for (final key in keys) {
      final value = widget.userData?[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  String get employeeName =>
      _editedName ?? _read(['name', 'full_name'], 'Employee');

  String get employeeEmail =>
      _read(['email'], 'No email available');

  String get employeeId =>
      _read(['employeeId', 'employee_id', 'empId'], 'Not assigned');

  String get department =>
      _read(['department', 'department_name', 'dept'], 'Not assigned');

  String get designation =>
      _read(['designation'], 'Not assigned');

  String get manager =>
      _read(['manager', 'reportingManager', 'reporting_manager'],
          'Not assigned');

  String get joiningDate =>
      _read(['joiningDate', 'joining_date', 'joinedOn'], 'Not available');

  String get workLocation =>
      _read(['location', 'workLocation', 'work_location'],
          'Not available');

  String get phone =>
      _editedPhone ?? _read(['phone', 'mobile'], 'Not added');

  bool get isProfileAssigned =>
      employeeId != 'Not assigned' &&
      department != 'Not assigned';

  String get profileStatus =>
      isProfileAssigned ? 'Active' : 'Pending Setup';

  String get initials {
    final parts = employeeName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'E';

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError ? Colors.red.shade700 : profileDarkColor,
        ),
      );
  }

  // ------------------------------------------------------------
  // PROFILE PHOTO: CAMERA + GALLERY
  // ------------------------------------------------------------

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (image == null || !mounted) return;

      setState(() {
        _profileImage = File(image.path);
      });

      _showMessage('Profile photo selected');
    } catch (_) {
      _showMessage(
        'Unable to open photo picker. Please try again.',
        isError: true,
      );
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: profileDarkColor,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _photoOption(
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _photoOption(
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                  ],
                ),
                if (_profileImage != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        setState(() {
                          _profileImage = null;
                        });
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove Photo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _photoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: profileBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: profilePrimaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: profileDarkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // EDIT NAME + PHONE
  // ------------------------------------------------------------

  void _openEditProfile() {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: employeeName == 'Employee' ? '' : employeeName,
    );

    final phoneController = TextEditingController(
      text: phone == 'Not added' ? '' : phone,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: profileDarkColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Department, designation and Employee ID '
                      'are managed by your admin.',
                      style: TextStyle(
                        color: profileGreyColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        'Full Name',
                        Icons.person_outline,
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';

                        if (name.isEmpty) {
                          return 'Please enter your name';
                        }

                        if (name.length < 2) {
                          return 'Name is too short';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(
                        'Phone Number',
                        Icons.phone_outlined,
                      ),
                      validator: (value) {
                        final valueText = value?.trim() ?? '';

                        if (valueText.isEmpty) return null;

                        if (!RegExp(r'^\+?\d{10,13}$')
                            .hasMatch(valueText)) {
                          return 'Enter a valid phone number';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          final newName =
                              nameController.text.trim();
                          final newPhone =
                              phoneController.text.trim();

                          setState(() {
                            _editedName = newName;
                            _editedPhone = newPhone.isEmpty
                                ? 'Not added'
                                : newPhone;
                          });

                          Navigator.pop(sheetContext);

                          widget.onProfileUpdated?.call(
                            newName,
                            newPhone,
                          );

                          _showMessage('Profile updated');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: profilePrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      phoneController.dispose();
    });
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: profilePrimaryColor,
      ),
      filled: true,
      fillColor: profileBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: profilePrimaryColor,
          width: 1.5,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: profilePrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;

    try {
      await widget.onLogout?.call();
    } catch (_) {
      // Continue to login even if the logout callback fails.
    }

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: profileBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: profileDarkColor,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            onPressed: _openEditProfile,
            icon: const Icon(
              Icons.edit_outlined,
              color: profileDarkColor,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              const Text(
                'EMPLOYEE DETAILS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: profileGreyColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildDetailsCard(),
              const SizedBox(height: 24),
              const Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: profileGreyColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildAction(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                subtitle: 'Update your name and phone number',
                onTap: _openEditProfile,
              ),
              const SizedBox(height: 12),
              _buildAction(
                icon: Icons.logout_rounded,
                title: 'Logout',
                subtitle: 'Sign out from your account',
                onTap: _logout,
                isLogout: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PROFILE HEADER
  // ------------------------------------------------------------

  Widget _buildProfileHeader() {
    final bool active = isProfileAssigned;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            profilePrimaryColor,
            profileSecondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: profilePrimaryColor.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _profileImage != null
                      ? Image.file(
                          _profileImage!,
                          width: 112,
                          height: 112,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: profilePrimaryColor,
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 2,
                child: Material(
                  color: profileDarkColor,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _showPhotoOptions,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 19,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            employeeName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            employeeEmail,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _headerChip(
                icon: active
                    ? Icons.check_circle_outline
                    : Icons.hourglass_top_rounded,
                label: profileStatus,
                color: active
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFFFFD166),
              ),
              _headerChip(
                icon: Icons.badge_outlined,
                label: 'ID: $employeeId',
                color: Colors.white,
              ),
            ],
          ),
          if (!active) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Your employee details are awaiting admin assignment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _headerChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPLOYEE DETAILS
  // ------------------------------------------------------------

  Widget _buildDetailsCard() {
    final details = <Map<String, dynamic>>[
      {
        'icon': Icons.email_outlined,
        'label': 'Email',
        'value': employeeEmail,
      },
      {
        'icon': Icons.phone_outlined,
        'label': 'Phone Number',
        'value': phone,
      },
      {
        'icon': Icons.badge_outlined,
        'label': 'Employee ID',
        'value': employeeId,
      },
      {
        'icon': Icons.work_outline,
        'label': 'Designation',
        'value': designation,
      },
      {
        'icon': Icons.apartment_outlined,
        'label': 'Department',
        'value': department,
      },
      {
        'icon': Icons.supervisor_account_outlined,
        'label': 'Reporting Manager',
        'value': manager,
      },
      {
        'icon': Icons.location_on_outlined,
        'label': 'Work Location',
        'value': workLocation,
      },
      {
        'icon': Icons.calendar_month_outlined,
        'label': 'Joining Date',
        'value': joiningDate,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          for (int i = 0; i < details.length; i++) ...[
            _buildDetailRow(
              icon: details[i]['icon'] as IconData,
              label: details[i]['label'] as String,
              value: details[i]['value'] as String,
            ),
            if (i != details.length - 1)
              Divider(
                height: 1,
                indent: 70,
                endIndent: 16,
                color: Colors.grey.shade200,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: profilePrimaryColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: profilePrimaryColor,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: profileGreyColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: profileDarkColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ACCOUNT ACTIONS
  // ------------------------------------------------------------

  Widget _buildAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final color = isLogout ? Colors.red.shade600 : profilePrimaryColor;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isLogout
                            ? Colors.red.shade600
                            : profileDarkColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: profileGreyColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: profileGreyColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
