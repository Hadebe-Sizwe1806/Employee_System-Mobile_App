import 'package:flutter/material.dart';
import 'package:group_i/models/user_model.dart';
import 'package:group_i/services/auth_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isEmployeeNumberVisible = false;
  bool _isIdNumberVisible = false;

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user logged in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF0B2E33),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF0B2E33),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: const Color(0xFF0B2E33).withBlue(55),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF93B1B5),
                      child: Icon(Icons.person, size: 50, color: Color(0xFF0B2E33)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(
                        user.role.toUpperCase(),
                        style: const TextStyle(color: Color(0xFF0B2E33)),
                      ),
                      backgroundColor: const Color(0xFF93B1B5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Employee-specific information
            if (user is Employee) _buildEmployeeInfo(user),

            // Admin-specific information
            if (user is Admin) _buildAdminInfo(user),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF93B1B5),
                  foregroundColor: const Color(0xFF0B2E33),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeInfo(Employee employee) {
    return Card(
      color: const Color(0xFF0B2E33).withBlue(55),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employee Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Employee ID Number',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white70)),
                  Row(
                    children: [
                      Text(
                          _isIdNumberVisible
                              ? employee.idNumber
                              : '*' * employee.employeeID.length,
                          style: const TextStyle(color: Colors.white54)),
                      _buildIdNumberVisibilityToggle(),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Employee Number',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white70)),
                  Row(
                    children: [
                      Text(
                          _isEmployeeNumberVisible
                              ? employee.employeeID
                              : '*' * employee.employeeID.length,
                          style: const TextStyle(color: Colors.white54)),
                      _buildEmployeeNumberVisibilityToggle(),
                    ],
                  ),
                ],
              ),
            ),
            _buildInfoRow('Cell Number', employee.cellNo),
            _buildInfoRow('Status', employee.status),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminInfo(Admin admin) {
    return Card(
      color: const Color(0xFF0B2E33).withBlue(55),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Administrator Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Admin ID', admin.userID),
            _buildInfoRow('Department', admin.department ?? 'Not specified'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildEmployeeNumberVisibilityToggle() {
    return IconButton(
      icon: Icon(
        _isEmployeeNumberVisible ? Icons.visibility_off : Icons.visibility,
        color: Colors.white54,
      ),
      onPressed: () {
        setState(() {
          _isEmployeeNumberVisible = !_isEmployeeNumberVisible;
        });
      },
    );
  }
   Widget _buildIdNumberVisibilityToggle() {
    return IconButton(
      icon: Icon(
        _isIdNumberVisible ? Icons.visibility_off : Icons.visibility,
        color: Colors.white54,
      ),
      onPressed: () {
        setState(() {
          _isIdNumberVisible = !_isIdNumberVisible;
        });
      },
    );
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
  }
}
