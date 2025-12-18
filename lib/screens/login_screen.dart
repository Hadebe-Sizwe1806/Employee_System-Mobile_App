import 'package:flutter/material.dart';
import 'package:group_i/services/auth_service.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _employeeNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'employee';
  bool _isLoading = false;

  // --- Dynamic Theme Colors ---
  static const Color _employeePrimaryColor = Colors.blue;
  static const Color _adminPrimaryColor = Color(0xFF36454F); // Charcoal
  static final Color _employeeBackgroundColor = Colors.grey[50]!;
  static final Color _adminBackgroundColor = Colors.grey[200]!;

  Color get _primaryColor =>
      _selectedRole == 'admin' ? _adminPrimaryColor : _employeePrimaryColor;

  Color get _backgroundColor => _selectedRole == 'admin'
      ? _adminBackgroundColor
      : _employeeBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24), // Padding around the entire scrollable content
          child: Center( // Center the login form horizontally
            child: ConstrainedBox( // Constrain the maximum width of the form
              constraints: const BoxConstraints(maxWidth: 600), // Example max width
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: CircleAvatar(
                        radius: 40, // Use dynamic color
                        backgroundColor: _primaryColor,
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Ghost Employee Verification',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor, // Use dynamic color
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Secure Employee Verification System',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Login As',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: 'employee',
                                  child: Row(
                                    children: [ // New Icon
                                      Icon(Icons.badge_outlined),
                                      SizedBox(width: 8),
                                      Text('Employee'),
                                    ],
                                  ),
                                ),
                                const DropdownMenuItem( // New Icon
                                  value: 'admin',
                                  child: Row(
                                    children: [
                                      Icon(Icons.admin_panel_settings_outlined),
                                      SizedBox(width: 8),
                                      Text('Administrator'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            if (_selectedRole == 'admin')
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              )
                            else ...[
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  if (_selectedRole == 'employee') {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _employeeNumberController,
                                decoration: const InputDecoration(
                                  labelText: 'Employee Number',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.pin_outlined),
                                ),
                                validator: (value) {
                                  if (_selectedRole == 'employee') {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Employee Number';
                                    }
                                    if (!value.startsWith('EMP')) {
                                      return 'Must start with "EMP"';
                                    }
                                    if (value.length != 8 || int.tryParse(value.substring(3)) == null) {
                                      return 'Must be EMP followed by 5 digits';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            if (_selectedRole == 'employee')
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _forgotPassword,
                                    child: const Text('Forgot Password?'),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryColor, // Use dynamic color
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_selectedRole == 'employee') ...[
                      const Text(
                        'Demo Credentials:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('Use any new Email and Employee Number to register.'),
                      const Text('---'),
                      const Text('Employee Number: EMP12345'),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authService = AuthService();
      String result;

      if (_selectedRole == 'admin') {
        result = await authService.login(
          role: _selectedRole,
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        result = await authService.login(
          role: _selectedRole,
          employeeId: _employeeNumberController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (result == "PasskeyRequired") {
        // Don't stop loading indicator, show passkey dialog instead
        if (mounted) {
          final biometricResult = await _authenticateWithBiometrics();
          if (biometricResult != "Success") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(biometricResult),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        // The auth wrapper will handle navigation on success,
        // so we just need to stop the loading indicator here.
        setState(() {
          _isLoading = false; // Stop loading indicator after biometric attempt
        });
      } else {
        setState(() {
          _isLoading = false; // Stop loading indicator for other results
        });

        if (result != "Success" && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _forgotPassword() async {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'Enter your email address to receive a password reset link.'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Send Link'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final authService = AuthService();
                  final success = await authService
                      .sendPasswordResetEmail(emailController.text.trim());

                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Password reset link sent to ${emailController.text.trim()}'
                            : 'Failed to send reset link. Please check the email address.'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _employeeNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }  

    Future<String> _authenticateWithBiometrics() async {
      final LocalAuthentication auth = LocalAuthentication();
      final bool canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        // If biometrics aren't available, we must cancel the login.
        // In a real-world scenario, you might offer an alternative 2FA method here.
        await AuthService().logout();
        return 'Biometric authentication is not available on this device.';
      }

      try {
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to complete your login',
          options: const AuthenticationOptions(
            stickyAuth: true, // Keep the prompt open until the user interacts
          ),
        );

        if (didAuthenticate) {
          // If biometrics are successful, finalize the login with the service
          return await AuthService().finalizeBiometricLogin();
        } else {
          // User cancelled the biometric prompt
          await AuthService().logout();
          return 'Authentication cancelled.';
        }
      } catch (e) {
        // Handle any errors from the local_auth plugin
        await AuthService().logout();
        return 'An error occurred during biometric authentication.';
      }
    }
}
