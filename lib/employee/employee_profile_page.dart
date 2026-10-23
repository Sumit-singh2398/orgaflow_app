import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../login_screen.dart';

const Color profilePrimaryColor = Color(0xFF3157D5);
const Color profileSecondaryColor = Color(0xFF5B7CFA);
const Color profileDarkColor = Color(0xFF172033);
const Color profileGreyColor = Color(0xFF6B7280);
const Color profileBackgroundColor = Color(0xFFF6F8FC);
const Color profileSuccessColor = Color(0xFF16A34A);
const Color profileWarningColor = Color(0xFFF59E0B);
const Color profileDangerColor = Color(0xFFDC2626);

const String kAppVersion = '1.0.0';

/// Employee profile screen.
///
/// Expected keys inside [userData] (all optional, safe fallbacks are used):
/// name, email, employeeId, designation (or role), department, phone,
/// joiningDate, manager, location, tasksAssigned, tasksCompleted, tasksPending
///
/// Optional hooks so you can connect your backend / Firebase:
///  - [onChangePassword] -> return null on success, or an error message.
///  - [onLogout]         -> called before navigating to the login screen
///                          (e.g. FirebaseAuth.instance.signOut()).
///  - [onProfileUpdated] -> called after the user edits name / phone.
class EmployeeProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Future<String?> Function(String currentPassword, String newPassword)?
      onChangePassword;
  final Future<void> Function()? onLogout;
  final void Function(String name, String phone)? onProfileUpdated;

  const EmployeeProfilePage({
    super.key,
    this.userData,
    this.onChangePassword,
    this.onLogout,
    this.onProfileUpdated,
  });

  @override
  State<EmployeeProfilePage> createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;

  bool _taskNotifications = true;
  bool _emailNotifications = false;

  // Local overrides after the user edits the profile.
  String? _editedName;
  String? _editedPhone;

  // ============================================================
  // USER DATA HELPERS
  // ============================================================

  String _read(List<String> keys, String fallback) {
    for (final key in keys) {
      final value = widget.userData?[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  int _readInt(String key) {
    final value = widget.userData?[key];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String get employeeName =>
      _editedName ?? _read(['name'], 'Employee');

  String get employeeEmail =>
      _read(['email'], 'No email available');

  String get employeeId =>
      _read(['employeeId', 'empId', 'id'], 'Not assigned');

  String get designation =>
      _read(['designation', 'role'], 'Employee');

  String get department =>
      _read(['department', 'dept'], 'Not assigned');

  String get phone =>
      _editedPhone ?? _read(['phone', 'mobile'], 'Not added');

  String get joiningDate =>
      _read(['joiningDate', 'joinedOn', 'createdAt'], 'Not available');

  String get manager =>
      _read(['manager', 'reportingManager'], 'Not assigned');

  String get workLocation =>
      _read(['location', 'workLocation'], 'Not available');

  int get tasksCompleted => _readInt('tasksCompleted');
  int get tasksPending => _readInt('tasksPending');

  int get tasksAssigned {
    final assigned = _readInt('tasksAssigned');
    final sum = tasksCompleted + tasksPending;
    return assigned > sum ? assigned : sum;
  }

  double get completionRate {
    if (tasksAssigned == 0) return 0;
    return (tasksCompleted / tasksAssigned).clamp(0.0, 1.0);
  }

  String get initials {
    final parts = employeeName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'E';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  // ============================================================
  // COMMON UI HELPERS
  // ============================================================

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? profileDangerColor : profileDarkColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _copyToClipboard(String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    _showMessage('$label copied');
  }

  Widget _sheetHandle() {
    return Center(
      child: Container(
        width: 45,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: profileGreyColor,
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: profilePrimaryColor),
      suffixIcon: suffix,
      filled: true,
      fillColor: profileBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: profilePrimaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: profileDangerColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: profileDangerColor, width: 1.5),
      ),
    );
  }

  // ============================================================
  // PROFILE PHOTO
  // ============================================================

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedImage == null) return;
      if (!mounted) return;

      setState(() {
        _profileImage = File(pickedImage.path);
      });
    } catch (error) {
      _showMessage('Could not open image picker: $error', isError: true);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetHandle(),
                const SizedBox(height: 20),
                const Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: profileDarkColor,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildPhotoOption(
                        icon: Icons.camera_alt_outlined,
                        title: 'Camera',
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPhotoOption(
                        icon: Icons.photo_library_outlined,
                        title: 'Gallery',
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          _pickImage(ImageSource.gallery);
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
                      style: OutlinedButton.styleFrom(
                        foregroundColor: profileDangerColor,
                        side: BorderSide(
                          color: profileDangerColor.withValues(alpha: 0.4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        setState(() {
                          _profileImage = null;
                        });
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove Photo'),
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

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: profileBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: profilePrimaryColor),
            const SizedBox(height: 8),
            Text(
              title,
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

  // ============================================================
  // EDIT PROFILE
  // ============================================================

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sheetHandle(),
                    const SizedBox(height: 22),
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: profileDarkColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Email, department and designation are managed by your admin.',
                      style: TextStyle(
                        fontSize: 13,
                        color: profileGreyColor,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        label: 'Full Name',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Please enter your name';
                        if (text.length < 2) return 'Name is too short';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                        LengthLimitingTextInputFormatter(14),
                      ],
                      decoration: _inputDecoration(
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return null;
                        if (!RegExp(r'^\+?\d{10,13}$').hasMatch(text)) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: profilePrimaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;

                          final newName = nameController.text.trim();
                          final newPhone = phoneController.text.trim();

                          Navigator.pop(bottomSheetContext);

                          setState(() {
                            _editedName = newName;
                            _editedPhone =
                                newPhone.isEmpty ? 'Not added' : newPhone;
                          });

                          widget.onProfileUpdated?.call(newName, newPhone);
                          _showMessage('Profile updated');
                        },
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 15,
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

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  void _openChangePassword() {
    final formKey = GlobalKey<FormState>();
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    bool hideCurrent = true;
    bool hideNew = true;
    bool hideConfirm = true;
    bool isLoading = false;
    String? serverError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Widget eye(bool hidden, VoidCallback toggle) {
              return IconButton(
                onPressed: toggle,
                icon: Icon(
                  hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: profileGreyColor,
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sheetHandle(),
                        const SizedBox(height: 22),
                        const Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: profileDarkColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Use at least 8 characters with a mix of letters and numbers.',
                          style: TextStyle(
                            fontSize: 13,
                            color: profileGreyColor,
                          ),
                        ),
                        const SizedBox(height: 22),
                        TextFormField(
                          controller: currentController,
                          obscureText: hideCurrent,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            label: 'Current Password',
                            icon: Icons.lock_outline,
                            suffix: eye(
                              hideCurrent,
                              () => setSheetState(
                                () => hideCurrent = !hideCurrent,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your current password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: newController,
                          obscureText: hideNew,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            label: 'New Password',
                            icon: Icons.lock_reset_outlined,
                            suffix: eye(
                              hideNew,
                              () => setSheetState(() => hideNew = !hideNew),
                            ),
                          ),
                          validator: (value) {
                            final text = value ?? '';
                            if (text.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            if (!RegExp(r'[A-Za-z]').hasMatch(text) ||
                                !RegExp(r'\d').hasMatch(text)) {
                              return 'Include both letters and numbers';
                            }
                            if (text == currentController.text) {
                              return 'New password must be different';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: confirmController,
                          obscureText: hideConfirm,
                          textInputAction: TextInputAction.done,
                          decoration: _inputDecoration(
                            label: 'Confirm New Password',
                            icon: Icons.check_circle_outline,
                            suffix: eye(
                              hideConfirm,
                              () => setSheetState(
                                () => hideConfirm = !hideConfirm,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value != newController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        if (serverError != null) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: profileDangerColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  serverError!,
                                  style: const TextStyle(
                                    color: profileDangerColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: profilePrimaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }

                                    final handler = widget.onChangePassword;

                                    if (handler == null) {
                                      Navigator.pop(bottomSheetContext);
                                      _showMessage(
                                        'Password change is not connected yet.',
                                        isError: true,
                                      );
                                      return;
                                    }

                                    setSheetState(() {
                                      isLoading = true;
                                      serverError = null;
                                    });

                                    String? error;
                                    try {
                                      error = await handler(
                                        currentController.text,
                                        newController.text,
                                      );
                                    } catch (e) {
                                      error = 'Something went wrong. Try again.';
                                    }

                                    if (!bottomSheetContext.mounted) return;

                                    if (error == null) {
                                      Navigator.pop(bottomSheetContext);
                                      _showMessage(
                                        'Password changed successfully',
                                      );
                                    } else {
                                      setSheetState(() {
                                        isLoading = false;
                                        serverError = error;
                                      });
                                    }
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Update Password',
                                    style: TextStyle(
                                      fontSize: 15,
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
        );
      },
    ).whenComplete(() {
      currentController.dispose();
      newController.dispose();
      confirmController.dispose();
    });
  }

  // ============================================================
  // ACCOUNT SECURITY
  // ============================================================

  void _openAccountSecurity() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(),
                const SizedBox(height: 22),
                const Row(
                  children: [
                    Icon(
                      Icons.security_outlined,
                      color: profilePrimaryColor,
                      size: 27,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Account Security',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: profileDarkColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _buildSecurityItem(
                  icon: Icons.verified_user_outlined,
                  text: 'Your account is secured with authenticated login.',
                  iconColor: profileSuccessColor,
                ),
                const SizedBox(height: 12),
                _buildSecurityItem(
                  icon: Icons.lock_outline,
                  text: 'Keep your login credentials private and secure.',
                  iconColor: profilePrimaryColor,
                ),
                const SizedBox(height: 12),
                _buildSecurityItem(
                  icon: Icons.phonelink_lock_outlined,
                  text:
                      'Never share your password or OTP with anyone, including colleagues.',
                  iconColor: profileWarningColor,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: profilePrimaryColor,
                      side: const BorderSide(color: profilePrimaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      _openChangePassword();
                    },
                    icon: const Icon(Icons.lock_reset_outlined),
                    label: const Text('Change Password'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: profileBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: profileDarkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELP & ABOUT
  // ============================================================

  void _openHelpAndSupport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(),
                const SizedBox(height: 22),
                const Row(
                  children: [
                    Icon(
                      Icons.support_agent_outlined,
                      color: profilePrimaryColor,
                      size: 27,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Help & Support',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: profileDarkColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _buildSecurityItem(
                  icon: Icons.assignment_outlined,
                  text:
                      'Task issues or deadline changes? Contact your reporting manager.',
                  iconColor: profilePrimaryColor,
                ),
                const SizedBox(height: 12),
                _buildSecurityItem(
                  icon: Icons.badge_outlined,
                  text:
                      'To update your department, designation or email, contact your admin / HR.',
                  iconColor: profileWarningColor,
                ),
                const SizedBox(height: 12),
                _buildSecurityItem(
                  icon: Icons.bug_report_outlined,
                  text:
                      'Facing an app problem? Share your Employee ID ($employeeId) with the support team.',
                  iconColor: profileSuccessColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Employee Task Tracker',
      applicationVersion: 'Version $kAppVersion',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: profilePrimaryColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.task_alt_rounded,
          color: profilePrimaryColor,
        ),
      ),
      children: const [
        SizedBox(height: 12),
        Text(
          'Track your assigned tasks, progress and deadlines in one place.',
        ),
      ],
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: profilePrimaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await widget.onLogout?.call();
                } catch (_) {
                  // Continue logout even if the sign-out hook fails.
                }

                if (!mounted) return;

                // ------------------------------------------------
                // LOGOUT -> LOGIN SCREEN
                // ------------------------------------------------
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: profileBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: profileDarkColor,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: profileDarkColor),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: _openEditProfile,
            icon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 16),
              _buildProgressCard(),
              const SizedBox(height: 26),
              _sectionTitle('Contact & Work Details'),
              _buildDetailsCard(),
              const SizedBox(height: 26),
              _sectionTitle('Notifications'),
              _buildNotificationsCard(),
              const SizedBox(height: 26),
              _sectionTitle('Account'),
              _buildActionCard(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your name and phone number',
                onTap: _openEditProfile,
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.lock_reset_outlined,
                title: 'Change Password',
                subtitle: 'Keep your account protected',
                onTap: _openChangePassword,
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.security_outlined,
                title: 'Account Security',
                subtitle: 'Manage your account security',
                onTap: _openAccountSecurity,
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.support_agent_outlined,
                title: 'Help & Support',
                subtitle: 'Get help with tasks and your account',
                onTap: _openHelpAndSupport,
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.info_outline,
                title: 'About App',
                subtitle: 'Version $kAppVersion',
                onTap: _openAbout,
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out from your account',
                iconColor: Colors.red,
                titleColor: Colors.red,
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER CARD (PHOTO + NAME + ROLE)
  // ============================================================

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [profilePrimaryColor, profileSecondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: profilePrimaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _profileImage != null
                      ? Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                          width: 110,
                          height: 110,
                        )
                      : Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: profilePrimaryColor,
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 2,
                child: GestureDetector(
                  onTap: _showPhotoOptions,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: profileDarkColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 18,
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
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            department == 'Not assigned'
                ? designation
                : '$designation  â€¢  $department',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              _headerChip(
                icon: Icons.circle,
                iconSize: 9,
                iconColor: const Color(0xFF4ADE80),
                label: 'Active',
              ),
              GestureDetector(
                onTap: employeeId == 'Not assigned'
                    ? null
                    : () => _copyToClipboard('Employee ID', employeeId),
                child: _headerChip(
                  icon: Icons.badge_outlined,
                  iconSize: 15,
                  iconColor: Colors.white,
                  label: 'ID: $employeeId',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerChip({
    required IconData icon,
    required double iconSize,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TASK STATS
  // ============================================================

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.assignment_outlined,
            value: tasksAssigned,
            label: 'Assigned',
            color: profilePrimaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_outline,
            value: tasksCompleted,
            label: 'Completed',
            color: profileSuccessColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.pending_actions_outlined,
            value: tasksPending,
            label: 'Pending',
            color: profileWarningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required int value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: profileDarkColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: profileGreyColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final int percent = (completionRate * 100).round();

    final Color barColor = percent >= 75
        ? profileSuccessColor
        : percent >= 40
            ? profilePrimaryColor
            : profileWarningColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Task Completion',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: profileDarkColor,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 10,
              backgroundColor: profileBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tasksAssigned == 0
                ? 'No tasks assigned yet.'
                : '$tasksCompleted of $tasksAssigned tasks completed',
            style: const TextStyle(
              fontSize: 13,
              color: profileGreyColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAILS CARD
  // ============================================================

  Widget _buildDetailsCard() {
    final List<Widget> rows = [
      _buildInfoRow(
        icon: Icons.email_outlined,
        label: 'Email',
        value: employeeEmail,
        verified: employeeEmail != 'No email available',
        copyable: employeeEmail != 'No email available',
      ),
      _buildInfoRow(
        icon: Icons.phone_outlined,
        label: 'Phone',
        value: phone,
        copyable: phone != 'Not added',
      ),
      _buildInfoRow(
        icon: Icons.badge_outlined,
        label: 'Employee ID',
        value: employeeId,
        copyable: employeeId != 'Not assigned',
      ),
      _buildInfoRow(
        icon: Icons.work_outline,
        label: 'Designation',
        value: designation,
      ),
      _buildInfoRow(
        icon: Icons.apartment_outlined,
        label: 'Department',
        value: department,
      ),
      _buildInfoRow(
        icon: Icons.supervisor_account_outlined,
        label: 'Reporting Manager',
        value: manager,
      ),
      _buildInfoRow(
        icon: Icons.location_on_outlined,
        label: 'Work Location',
        value: workLocation,
      ),
      _buildInfoRow(
        icon: Icons.event_available_outlined,
        label: 'Joining Date',
        value: joiningDate,
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              Divider(
                height: 1,
                indent: 80,
                endIndent: 18,
                color: Colors.grey.shade200,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool verified = false,
    bool copyable = false,
  }) {
    return InkWell(
      onTap: copyable ? () => _copyToClipboard(label, value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: profilePrimaryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: profilePrimaryColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: profileGreyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: profileDarkColor,
                    ),
                  ),
                ],
              ),
            ),
            if (verified) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.verified,
                color: profileSuccessColor,
                size: 21,
              ),
            ],
            if (copyable) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.copy_rounded,
                color: Colors.grey.shade400,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NOTIFICATIONS CARD
  // ============================================================

  Widget _buildNotificationsCard() {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildSwitchRow(
            icon: Icons.notifications_active_outlined,
            title: 'Task Alerts',
            subtitle: 'New tasks, deadlines and updates',
            value: _taskNotifications,
            onChanged: (v) => setState(() => _taskNotifications = v),
          ),
          Divider(
            height: 1,
            indent: 80,
            endIndent: 18,
            color: Colors.grey.shade200,
          ),
          _buildSwitchRow(
            icon: Icons.mark_email_unread_outlined,
            title: 'Email Updates',
            subtitle: 'Weekly summary of your progress',
            value: _emailNotifications,
            onChanged: (v) => setState(() => _emailNotifications = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: profilePrimaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: profilePrimaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: profileDarkColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: profileGreyColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: profilePrimaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = profilePrimaryColor,
    Color titleColor = profileDarkColor,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
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
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 23),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: profileGreyColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}