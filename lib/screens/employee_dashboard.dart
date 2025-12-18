import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'verification_submission_screen.dart';
import 'profile_screen.dart';
import 'verification_status_screen.dart';
import 'submitted_documents_screen.dart';
import 'edit_profile_screen.dart';
import 'contact_admin_screen.dart';
import 'staff_card_screen.dart';
import 'package:intl/intl.dart' as intl;

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final AuthService _authService = AuthService();
  int _currentIndex = 1; // Default to Dashboard screen

  final List<Widget> _screens = [
    const VerificationSubmissionScreen(),
    const EmployeeHomeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Portal'),
        backgroundColor: const Color(0xFF0B2E33), // Dark Theme Color
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _screens[_currentIndex],
      backgroundColor: const Color(0xFF0B2E33), // Dark background
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF0B2E33).withOpacity(0.95),
        selectedItemColor: const Color(0xFF93B1B5), // Light accent
        unselectedItemColor: Colors.white.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'Verification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    // The AuthWrapper will handle navigation automatically.
    await _authService.logout();
  }
}

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser as Employee?;

    // Define dashboard items
    final List<Map<String, dynamic>> dashboardItems = [
      // Conditionally show "Submit Verification" or "My Staff Card"
      if (user?.status == 'approved')
        {
          'title': 'My Staff Card',
          'icon': Icons.badge,
          'color': Colors.cyan,
          'screen': const StaffCardScreen()
        }
      else
        {
          'title': 'Submit Verification',
          'icon': Icons.verified_user,
          'color': Colors.blue,
          'screen': const VerificationSubmissionScreen()
        },
      {'title': 'My Profile', 'icon': Icons.person, 'color': Colors.orange, 'screen': const ProfileScreen()},
      {'title': 'Edit Profile', 'icon': Icons.edit, 'color': Colors.teal, 'screen': const EditProfileScreen()},
      {'title': 'View Status', 'icon': Icons.track_changes, 'color': Colors.green, 'screen': const VerificationStatusScreen()},
      {'title': 'My Documents', 'icon': Icons.folder, 'color': Colors.purple, 'screen': const SubmittedDocumentsScreen()},
      {'title': 'Contact Admin', 'icon': Icons.support_agent, 'color': Colors.red, 'screen': const ContactAdminScreen()},
    ];
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B2E33), Color(0xFF104A51)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(user),
            const SizedBox(height: 24),
            if (user?.staffCardPhotoStatus == 'requested') ...[
              _buildStaffCardBanner(),
              const SizedBox(height: 24),
            ],
            LayoutBuilder(builder: (context, constraints) {
              final bool isMobile = constraints.maxWidth < 600;
              final actionButtons = _buildActionButtons(dashboardItems, isMobile: isMobile);
              final verificationReview = _buildVerificationReview(user, isMobile: isMobile);

              if (isMobile) {
                // On phone: Stack the verification review on top of the buttons
                return Column(
                  children: [
                    verificationReview,
                    const SizedBox(height: 24),
                    actionButtons,
                  ],
                );
              } else {
                // On wider screens: Show side-by-side
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: actionButtons),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: verificationReview),
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(Employee? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.waving_hand_rounded, color: Color(0xFF93B1B5), size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.username.isNotEmpty == true
                        ? user!.username[0].toUpperCase() + user.username.substring(1)
                        : 'Employee',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF93B1B5)),
                  ),
                ],
              ),
            ],
          ),
          if (user != null) ...[
            const Divider(height: 32, color: Colors.white24),
            _buildStatusIndicator(user.status),
          ]
        ],
      ),
    );
  }

  Widget _buildStaffCardBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF93B1B5).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF93B1B5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.camera_alt_outlined, color: Color(0xFF93B1B5), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Action Required: Please visit the admin office for your new staff card photo.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'approved':
        statusColor = Colors.green.shade300;
        statusText = 'Profile Verified';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red.shade300;
        statusText = 'Verification Rejected';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange.shade300;
        statusText = 'Verification Pending';
        statusIcon = Icons.pending;
    }
    return Row(
      children: [
        Icon(statusIcon, color: statusColor, size: 20),
        const SizedBox(width: 12),
        Text(
          'Status:',
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
        ),
        const SizedBox(width: 8),
        Text(
          statusText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: statusColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(List<Map<String, dynamic>> dashboardItems, {required bool isMobile}) {
    return Column(
      children: List.generate(dashboardItems.length, (index) {
        final item = dashboardItems[index];
        // Alternating "chess" pattern for checkered colors
        final bool isLight = (index % 2 == 0);
        return _BuildDashboardButton(
          item['title'],
          item['icon'] as IconData,
          isLight,
          () {
            // The context will be handled by the button widget itself
          },
          item['screen'] as Widget,
        );
      }),
    );
  }
  Widget _buildVerificationReview(Employee? user, {required bool isMobile}) {
    final String status = user?.status ?? 'unknown';
    // In a real app, you'd check each document's status.
    // For this design, we'll assume all are approved if the user is approved.
    final bool docsComplete = status == 'approved';

    return Card( // Added return statement
      color: const Color(0xFF0B2E33).withBlue(55),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification Review',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Divider(height: 24, color: Colors.white24),
            _buildDocumentCheck('ID Document', docsComplete),
            _buildDocumentCheck('Selfie Photo', docsComplete),
 _buildDocumentCheck('Employment Proof', docsComplete),
            const Divider(height: 24, color: Colors.white24),
            _buildLastClockIn(user?.lastClockIn),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCheck(String title, bool isComplete) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.circle_outlined,
            color: isComplete ? Colors.green.shade300 : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(fontSize: 14, color: isComplete ? Colors.white : Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildLastClockIn(DateTime? lastClockIn) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Color(0xFF93B1B5), size: 20),
          const SizedBox(width: 12),
          const Text('Last Clock-In:', style: TextStyle(fontSize: 14, color: Colors.white70)),
          const Spacer(),
          Text(
            lastClockIn != null
                ? intl.DateFormat('MMM d, hh:mm a').format(lastClockIn)
                : 'N/A',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildDashboardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isLight;
  final VoidCallback onTap;
  final Widget screen;

  const _BuildDashboardButton(this.title, this.icon, this.isLight, this.onTap, this.screen);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isLight ? Colors.white.withOpacity(0.9) : const Color(0xFF93B1B5);
    final Color foregroundColor = isLight ? const Color(0xFF0B2E33) : Colors.white;

    return Card(
      color: backgroundColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 24, color: foregroundColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: foregroundColor,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: foregroundColor.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }
}