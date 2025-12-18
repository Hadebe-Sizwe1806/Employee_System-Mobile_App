import 'package:flutter/material.dart';
import 'package:group_i/services/auth_service.dart';

class ContactAdminScreen extends StatefulWidget {
  const ContactAdminScreen({super.key});

  @override
  State<ContactAdminScreen> createState() => _ContactAdminScreenState();
}

class _ContactAdminScreenState extends State<ContactAdminScreen> {
  final AuthService _authService = AuthService();

  Future<void> _resetPassword() async {
    final email = _authService.currentUser?.email;
    if (email == null) {
      _showSnackBar('Could not find your email address.', isError: true);
      return;
    }

    final success = await _authService.sendPasswordResetEmail(email);
    if (mounted) {
      _showSnackBar(
        success
            ? 'Password reset link sent to $email.'
            : 'Failed to send password reset link.',
        isError: !success,
      );
    }
  }

  Future<void> _changePassword() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Old Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your old password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final result = await _authService.changePassword(
                  oldPasswordController.text,
                  newPasswordController.text,
                );
                final isSuccess = result == "Success";

                if (isSuccess) Navigator.pop(context); // Close dialog on success

                _showSnackBar(
                  isSuccess ? 'Password changed successfully.' : result,
                  isError: !isSuccess,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Password Management'),
          Card(
            child: Column(
              children: [
                _buildListTile(
                  'Change Password',
                  Icons.password,
                  Colors.teal,
                  _changePassword,
                ),
                const Divider(height: 1),
                _buildListTile(
                  'Reset Password (via Email)',
                  Icons.mark_email_read,
                  Colors.orange,
                  _resetPassword,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Contact & Settings'),
          Card(
            child: Column(
              children: [
                _buildListTile(
                  'Contact Admin',
                  Icons.support_agent,
                  Colors.blue,
                  () {
                    // This can be replaced with a mailer package later
                    _showSnackBar('Contact email: admin@ghostsystem.com');
                  },
                  subtitle: 'admin@ghostsystem.com',
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  secondary:
                      const Icon(Icons.brightness_6, color: Colors.purple),
                  value: false, // Placeholder for theme state
                  onChanged: (bool value) {
                    // TODO: Implement theme switching logic
                    _showSnackBar('Theme switching will be ready after a restart!');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildListTile(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    String? subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}