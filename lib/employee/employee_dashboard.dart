import 'package:flutter/material.dart';
import 'existing_employee_home.dart';
import 'new_employee_home.dart';

class EmployeeDashboard extends StatelessWidget {
  final bool isNewUser;

  // Existing employee ka data
  final Map<String, dynamic>? userData;

  const EmployeeDashboard({
    super.key,
    required this.isNewUser,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    // NEW USER
    if (isNewUser) {
      return NewEmployeeHome(
        userData: userData,
      );
    }

    // OLD / EXISTING EMPLOYEE
    return ExistingEmployeeHome(
      userData: userData,
    );
  }
}