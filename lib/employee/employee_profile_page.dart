import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../login_screen.dart';

const Color profilePrimaryColor = Color(0xFF3157D5);
const Color profileDarkColor = Color(0xFF172033);
const Color profileGreyColor = Color(0xFF6B7280);
const Color profileBackgroundColor = Color(0xFFF6F8FC);

class EmployeeProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EmployeeProfilePage({
    super.key,
    this.userData,
  });

  @override
  State<EmployeeProfilePage> createState() =>
      _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;

  // ============================================================
  // USER DATA
  // ============================================================

  String get employeeName {
    final name = widget.userData?['name'];

    if (name == null || name.toString().trim().isEmpty) {
      return 'Employee';
    }

    return name.toString();
  }

  String get employeeEmail {
    final email = widget.userData?['email'];

    if (email == null || email.toString().trim().isEmpty) {
      return 'No email available';
    }

    return email.toString();
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

      if (pickedImage == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _profileImage = File(pickedImage.path);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open image picker: $error',
          ),
          behavior: SnackBarBehavior.floating,
        ),
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
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
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
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);

                        setState(() {
                          _profileImage = null;
                        });
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                      ),
                      label: const Text(
                        'Remove Photo',
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

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: profileBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
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
  // ACCOUNT SECURITY
  // ============================================================

  void _openAccountSecurity() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              20,
              24,
              30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

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
                  text:
                      'Your account is secured with authenticated login.',
                  iconColor: Colors.green,
                ),

                const SizedBox(height: 12),

                _buildSecurityItem(
                  icon: Icons.lock_outline,
                  text:
                      'Keep your login credentials private and secure.',
                  iconColor: profilePrimaryColor,
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
          Icon(
            icon,
            color: iconColor,
          ),
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
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: profilePrimaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

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
              child: const Text(
                'Logout',
              ),
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
    final String firstLetter =
        employeeName.trim().isNotEmpty
            ? employeeName.trim()[0].toUpperCase()
            : 'E';

    return Scaffold(
      backgroundColor: profileBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: profileDarkColor,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(
          color: profileDarkColor,
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            30,
          ),
          child: Column(
            children: [
              // ==================================================
              // PROFILE PHOTO
              // ==================================================

              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: profilePrimaryColor.withOpacity(
                          0.10,
                        ),
                        border: Border.all(
                          color: profilePrimaryColor.withOpacity(
                            0.20,
                          ),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: _profileImage != null
                            ? Image.file(
                                _profileImage!,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Text(
                                  firstLetter,
                                  style: const TextStyle(
                                    fontSize: 46,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        profilePrimaryColor,
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: profilePrimaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // NAME
              // ==================================================

              Text(
                employeeName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: profileDarkColor,
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // EMAIL
              // ==================================================

              _buildEmailCard(),

              const SizedBox(height: 16),

              // ==================================================
              // ACCOUNT SECURITY
              // ==================================================

              _buildActionCard(
                icon: Icons.security_outlined,
                title: 'Account Security',
                subtitle:
                    'Manage your account security',
                onTap: _openAccountSecurity,
              ),

              const SizedBox(height: 16),

              // ==================================================
              // LOGOUT
              // ==================================================

              _buildActionCard(
                icon: Icons.logout,
                title: 'Logout',
                subtitle:
                    'Sign out from your account',
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
  // EMAIL CARD
  // ============================================================

  Widget _buildEmailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: profilePrimaryColor.withOpacity(
                0.10,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.email_outlined,
              color: profilePrimaryColor,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 13,
                    color: profileGreyColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        employeeEmail,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: profileDarkColor,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Icon(
                      Icons.verified,
                      color: Colors.green,
                      size: 21,
                    ),
                  ],
                ),
              ],
            ),
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
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
