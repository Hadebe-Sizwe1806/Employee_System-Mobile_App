import 'package:flutter/material.dart';
import 'package:group_i/services/auth_service.dart';
import '../models/user_model.dart';
import 'verification_detail_screen.dart';
import 'add_employee_screen.dart';
import 'manage_employees_screen.dart';
import '../models/activity_log_model.dart';
import '../services/csv_export_service.dart';
import 'scan_reports_screen.dart';
import 'qr_scanner_screen.dart';
import 'package:intl/intl.dart' as intl;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0; // Default to Dashboard

  final List<Widget> _screens = [
    const AdminHomeScreen(),
    const VerificationRequestsScreen(),
    const QrScannerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal'),
        backgroundColor: const Color(0xFF36454F), // Charcoal Grey
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _screens[_currentIndex],
      backgroundColor: const Color(0xFF36454F), // Match AppBar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF36454F),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_reg),
            label: 'Verifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    // The AuthWrapper will handle navigation automatically.
    await _authService.logout();
  }
}

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final List<Map<String, dynamic>> dashboardItems = [
      {'title': 'Manage Employees', 'icon': Icons.people, 'screen': const ManageEmployeesScreen()},
      {'title': 'View Reports', 'icon': Icons.analytics, 'screen': const ReportsScreen()},
      {'title': 'Scan / Clock-In Reports', 'icon': Icons.location_on, 'screen': const ScanReportsScreen()},
      {'title': 'Add New Employee', 'icon': Icons.person_add, 'screen': const AddEmployeeScreen()},
    ];

    return Container(
      color: Colors.grey[200],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(authService.currentUser?.username),
            const SizedBox(height: 24),
            _buildActionButtons(context, dashboardItems),
            const SizedBox(height: 24),
            _buildStatsOverview(authService),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String? username) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF36454F),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Admin Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Welcome, ${username ?? 'Admin'}', style: const TextStyle(fontSize: 16, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF36454F))),
        const SizedBox(height: 12),
        ...items.map((item) => _buildDashboardButton(context, item['title'], item['icon'], item['screen'])),
      ],
    );
  }

  Widget _buildDashboardButton(BuildContext context, String title, IconData icon, Widget screen) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF36454F)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      ),
    );
  }

  Widget _buildStatsOverview(AuthService authService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Verification Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF36454F))),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<Map<String, int>>(
              stream: authService.getDashboardStats(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final stats = snapshot.data!;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Pending', stats['pending'].toString(), Icons.pending_actions, Colors.orange),
                    _buildStatItem('Approved', stats['approved'].toString(), Icons.check_circle, Colors.green),
                    _buildStatItem('Rejected', stats['rejected'].toString(), Icons.cancel, Colors.red),
                    _buildStatItem('Total', stats['total'].toString(), Icons.people, Colors.blue),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }
}


class VerificationRequestsScreen extends StatefulWidget {
  const VerificationRequestsScreen({super.key});

  @override
  State<VerificationRequestsScreen> createState() =>
      _VerificationRequestsScreenState();
}

class _VerificationRequestsScreenState
    extends State<VerificationRequestsScreen> {
  final AuthService _authService = AuthService();
  String _searchQuery = '';
  String _selectedStatus = 'registered'; // Default to pending
  final List<String> _statuses = ['registered', 'approved', 'rejected'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Employee>>( // The StreamBuilder should be the body of the Scaffold
      stream: _authService.getVerifiableEmployeesStream(),
      builder: (context, snapshot) {
        // ... existing loading and error handling ...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off_outlined,
                    size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('No pending verifications',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        List<Employee> employees = snapshot.data!;

        // Apply filtering and search
        employees = employees.where((e) => e.status == _selectedStatus).toList();

        if (_searchQuery.isNotEmpty) {
          employees = employees
              .where((e) =>
                  e.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  e.employeeID.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
        }

        return Column(
          children: [
            _buildFilterAndSearch(),
            Expanded(
              child: employees.isEmpty
                  ? const Center(child: Text('No matching requests found.'))
                  : ListView.builder(
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(employee.status).withOpacity(0.8),
                              child: Icon(_getStatusIcon(employee.status), color: Colors.white),
                            ),
                            title: Text(employee.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'ID: ${employee.employeeID} • Dept: ${employee.department ?? 'N/A'}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        VerificationDetailScreen(
                                            employee: employee))),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEmployeeScreen()));
      },
      label: const Text('Add Employee'),
      icon: const Icon(Icons.add),
      backgroundColor: const Color(0xFF36454F),
      foregroundColor: Colors.white,
    ));
  }

  Widget _buildFilterAndSearch() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                labelText: 'Search by Name or ID',
                prefixIcon: Icon(Icons.search, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: DropdownButton<String>(
              icon: const Icon(Icons.filter_list),
              value: _selectedStatus,
              underline: const SizedBox.shrink(),
              items: _statuses.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value[0].toUpperCase() + value.substring(1)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedStatus = value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'registered':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check;
      case 'rejected':
        return Icons.close;
      case 'registered':
      default:
        return Icons.pending_actions;
    }
  }
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Reports'),
        actions: [
          StreamBuilder<List<ActivityLog>>(
            stream: _authService.getActivityLogs(),
            builder: (context, snapshot) {
              return IconButton(
                icon: const Icon(Icons.download),
                onPressed: snapshot.hasData && snapshot.data!.isNotEmpty
                    ? () => CsvExportService().exportActivityLogsToCsv(context, snapshot.data!, 'activity_reports.csv')
                    : null,
              );
            }
          ),
        ],
      ),
      body: StreamBuilder<List<ActivityLog>>(
        stream: _authService.getActivityLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No recent activity found.',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }
    
          final logs = snapshot.data!;
    
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.blueGrey),
                  title: Text(log.message),
                  subtitle: Text(
                    intl.DateFormat('yyyy-MM-dd - hh:mm a').format(log.timestamp),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
