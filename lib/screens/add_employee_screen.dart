import 'package:flutter/material.dart';
import 'package:group_i/services/auth_service.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isSaving = false;

  // Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _jobTitleController = TextEditingController();
  String? _selectedDepartment;
  final List<String> _departments = ['HR', 'IT', 'FINANCE', 'MARKETING'];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  Future<void> _createEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final result = await _authService.createEmployeeByAdmin(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      employeeId: _employeeIdController.text.trim(),
      department: _selectedDepartment!,
      jobTitle: _jobTitleController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: result == 'Employee created successfully.' ? Colors.green : Colors.red,
        ),
      );
      if (result == 'Employee created successfully.') {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Employee'),
        backgroundColor: const Color(0xFF36454F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Username is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                validator: (v) => v!.isEmpty || !v.contains('@') ? 'A valid email is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _employeeIdController,
                decoration: const InputDecoration(labelText: 'Employee ID (e.g., EMP12345)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge)),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Employee ID is required';
                  if (!value.startsWith('EMP') || value.length != 8 || int.tryParse(value.substring(3)) == null) {
                    return 'Must be EMP followed by 5 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedDepartment,
                hint: const Text('Select Department'),
                items: _departments.map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (value) => setState(() => _selectedDepartment = value),
                decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder(), prefixIcon: Icon(Icons.business)),
                validator: (v) => v == null ? 'Department is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jobTitleController,
                decoration: const InputDecoration(labelText: 'Job Title', border: OutlineInputBorder(), prefixIcon: Icon(Icons.work)),
                validator: (v) => v!.isEmpty ? 'Job Title is required' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _createEmployee,
                  icon: _isSaving ? const SizedBox.shrink() : const Icon(Icons.person_add),
                  label: _isSaving
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text('Create Employee Record'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF36454F),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}