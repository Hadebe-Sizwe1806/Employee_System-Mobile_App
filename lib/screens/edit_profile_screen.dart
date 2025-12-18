// screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cellNoController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _saidController = TextEditingController();
  final _idNumberController = TextEditingController();

  final bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      _usernameController.text = user.username;
      _emailController.text = user.email;

      if (user is Employee) {
        _cellNoController.text = user.cellNo;
        _employeeIdController.text = user.employeeID;
        
        _idNumberController.text = user.idNumber;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF0B2E33),// Employee theme
        foregroundColor: Colors.white, // Employee theme
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 32),
                          if (user is Employee) _buildEmployeeForm(),
                          if (user is Admin) _buildAdminForm(),
                          const SizedBox(height: 32),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      backgroundColor: const Color(0xFF0B2E33), // Employee theme
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: const Color(0xFF0B2E33).withBlue(55),
          child: const Icon(Icons.edit, size: 40, color: Color(0xFF93B1B5)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Edit Your Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Keep your personal information up to date.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildEmployeeForm() {
    return Column(
      children: [
        _buildFormField(
          controller: _usernameController,
          label: 'Full Name',
          icon: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            if (value.length < 2) {
              return 'Name must be at least 2 characters long';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email address';
            }
            if (!value.contains('@') || !value.contains('.')) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _cellNoController,
          label: 'Cell Phone Number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your cell phone number';
            }
            if (value.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: TextEditingController(text: (_authService.currentUser as Employee).department),
          label: 'Department',
          icon: Icons.business,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: TextEditingController(text: (_authService.currentUser as Employee).jobTitle),
          label: 'Job Title',
          icon: Icons.work,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _employeeIdController,
          label: 'Employee ID',
          icon: Icons.school,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your employee ID';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _idNumberController,
          label: 'ID Number',
          icon: Icons.badge,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your ID number';
            } if (value.length != 13) {
              return 'ID must be 13 digits long';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdminForm() {
    return Column(
      children: [
        _buildFormField(
          controller: _usernameController,
          label: 'Full Name',
          icon: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email address';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: readOnly ? Colors.white70 : Colors.white),
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: readOnly ? Colors.white38 : Colors.white70),
        prefixIcon: Icon(icon, color: const Color(0xFF93B1B5)),
        filled: true,
        fillColor: readOnly ? const Color(0xFF0B2E33).withOpacity(0.5) : const Color(0xFF0B2E33).withBlue(55),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF93B1B5))),
        disabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
      ),
      validator: validator,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : _cancelEditing,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF93B1B5)),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF93B1B5), // Accent color
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save Changes', style: TextStyle(fontSize: 16, color: Color(0xFF0B2E33))),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final user = _authService.currentUser;
      bool success = false;

      if (user is Employee) {
        final updatedEmployee = user.copyWith(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          cellNo: _cellNoController.text.trim(),
          employeeID: _employeeIdController.text.trim(),
          idNumber: _idNumberController.text.trim(),
        );
        success = await _authService.updateEmployeeProfile(updatedEmployee);
      } else if (user is Admin) {
        final updatedAdmin = user.copyWith(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
        );
        success = await _authService.updateAdminProfile(updatedAdmin);
      }

      setState(() {
        _isSaving = false;
      });

      if (success) {
        _showSuccessMessage();
      } else {
        _showErrorMessage();
      }
    }
  }

  void _cancelEditing() {
    Navigator.pop(context);
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate back after showing success message
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to update profile. Please try again.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _cellNoController.dispose();
    _employeeIdController.dispose();
    _saidController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }
}
