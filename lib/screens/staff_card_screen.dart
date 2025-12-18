// screens/staff_card_screen.dart
import 'package:flutter/material.dart';
import 'package:group_i/models/user_model.dart';
import 'package:group_i/services/auth_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StaffCardScreen extends StatefulWidget {
  const StaffCardScreen({super.key});

  @override
  State<StaffCardScreen> createState() => _StaffCardScreenState();
}

class _StaffCardScreenState extends State<StaffCardScreen> {
  final AuthService _authService = AuthService();
  bool _isEmployeeNumberVisible = false;

  Future<void> _toggleEmployeeNumberVisibility() async {
    if (_isEmployeeNumberVisible) {
      setState(() => _isEmployeeNumberVisible = false);
      return;
    }

    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Password to View'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // In a real app, you'd re-authenticate with Firebase Auth.
                // For this mock setup, we'll just check a hardcoded password for demo.
                // This is NOT secure for production.
                final result = await _authService.login(
                  role: 'employee',
                  email: _authService.currentUser!.email,
                  employeeId: (_authService.currentUser as Employee).employeeID,
                  password: passwordController.text,
                );

                if (mounted) {
                  if (result == 'Success') {
                    Navigator.pop(context, true);
                  } else {
                    Navigator.pop(context, false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Incorrect password.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isEmployeeNumberVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser as Employee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Staff Card'),
        backgroundColor: const Color(0xFF0B2E33),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF0B2E33),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            color: const Color(0xFF0B2E33).withBlue(55),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStaffPhoto(user),
                  const SizedBox(height: 24),
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.jobTitle.isNotEmpty ? user.jobTitle : 'Employee',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF93B1B5),
                    ),
                  ),
                  const Divider(height: 40, color: Colors.white24),
                  _buildInfoRow(
                    'Employee Number',
                    _isEmployeeNumberVisible
                        ? user.employeeID
                        : '********',
                    IconButton(
                      icon: Icon(
                        _isEmployeeNumberVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: _toggleEmployeeNumberVisibility,
                    ),
                  ),
                  const Divider(height: 40, color: Colors.white24),
                  _buildQrCode(user),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffPhoto(Employee user) {
    // If a photo URL exists and is valid, show the image.
    // For now, we check the status.
    bool hasPhoto = user.staffCardPhotoStatus == 'completed';

    if (hasPhoto) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: const Color(0xFF93B1B5),
        // In a real app, you would use Image.network(user.photoUrl)
        child: Icon(Icons.person, size: 60, color: const Color(0xFF0B2E33)),
      );
    } else {
      // If no photo, show the message.
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Column(
          children: [
            Icon(Icons.error, color: Colors.red.shade300, size: 40),
            const SizedBox(height: 12),
            Text(
              'You are due for a staff profile photo. Please report to the admin office ASAP.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade200,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value, Widget trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16),
            ),
            const SizedBox(width: 4),
            trailing,
          ],
        ),
      ],
    );
  }

  Widget _buildQrCode(Employee user) {
    return Column(
      children: [
        const Text(
          'Admin Verification QR Code',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: QrImageView(
            data: user.userID, // Using the unique userID for the QR code
            version: QrVersions.auto,
            size: 120.0,
            gapless: false,
            eyeStyle: const QrEyeStyle(color: Colors.black, eyeShape: QrEyeShape.square),
            dataModuleStyle: const QrDataModuleStyle(color: Colors.black, dataModuleShape: QrDataModuleShape.square),
          ),
        ),
      ],
    );
  }
}