// screens/manage_employees_screen.dart
import 'package:flutter/material.dart';
import 'package:group_i/models/user_model.dart';
import 'package:group_i/services/auth_service.dart';
import 'package:group_i/screens/verification_detail_screen.dart';

class ManageEmployeesScreen extends StatefulWidget {
  const ManageEmployeesScreen({super.key});

  @override
  State<ManageEmployeesScreen> createState() => _ManageEmployeesScreenState();
}

class _ManageEmployeesScreenState extends State<ManageEmployeesScreen> {
  final AuthService _authService = AuthService();
  String? _selectedDepartment;
  final List<String> _departments = ['All', 'HR', 'IT', 'FINANCE', 'MARKETING'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Employee>>(
        stream: _authService.getVerifiableEmployeesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState('No employees found.');
          }

          List<Employee> employees = snapshot.data!
              .where((e) => e.status == 'approved')
              .toList();

          if (_selectedDepartment != null && _selectedDepartment != 'All') {
            employees = employees
                .where((e) => e.department == _selectedDepartment)
                .toList();
          }

          return Column(
            children: [
              _buildFilter(),
              Expanded(
                child: employees.isEmpty
                    ? _buildEmptyState('No approved employees in this department.')
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          final employee = employees[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(employee.username,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                employee.jobTitle.isNotEmpty
                                    ? employee.jobTitle
                                    : 'Role not yet assigned',
                                style: TextStyle(
                                  color: employee.jobTitle.isNotEmpty
                                      ? Colors.grey[600]
                                      : Colors.orange,
                                  fontStyle: employee.jobTitle.isEmpty
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VerificationDetailScreen(employee: employee),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedDepartment ?? 'All',
        hint: const Text('Filter by Department'),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.filter_list),
        ),
        items: _departments.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedDepartment = value);
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}