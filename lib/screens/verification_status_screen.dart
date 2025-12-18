// screens/verification_status_screen.dart
import 'package:flutter/material.dart';
import 'package:group_i/models/user_model.dart';
import 'package:group_i/services/auth_service.dart';

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() =>
      _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null || user is! Employee) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verification Status')),
        body: const Center(
          child: Text('Could not load employee information.'),
        ),
      );
    }

    final employee = user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Status'), // Employee theme
        backgroundColor: const Color(0xFF0B2E33),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF0B2E33), // Employee theme
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(employee.status),
            const SizedBox(height: 20),
            _buildTimeline(employee.status),
            const SizedBox(height: 20),
            _buildRemarksSection(employee.status),
          ],
        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;

    switch (status) {
      case 'approved':
        statusColor = const Color(0xFF93B1B5);
        statusIcon = Icons.verified;
        statusText = 'Verified & Approved';
        statusDescription = 'Your employee verification has been approved.';
        break;
      case 'rejected':
        statusColor = Colors.red.shade300;
        statusIcon = Icons.cancel;
        statusText = 'Verification Rejected';
        statusDescription = 'Your verification request has been rejected.';
        break;
      case 'under_review':
        statusColor = Colors.orange.shade300;
        statusIcon = Icons.pending;
        statusText = 'Submission Under Review';
        statusDescription = 'Your documents are being reviewed by our team.';
        break;
      case 'registered':
      default:
        statusColor = Colors.orange.shade300;
        statusIcon = Icons.schedule;
        statusText = 'Submission Received';
        statusDescription = 'Your documents have been received and are pending review.';
        break;
    }

    return Card(
      color: const Color(0xFF0B2E33).withBlue(55), // Dark card background
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, size: 40, color: statusColor),
            ),
            const SizedBox(height: 16),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Use white for better contrast on dark bg
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(String status) {
    return Card(
      color: const Color(0xFF0B2E33).withBlue(55), // Dark card background
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text( // Title style
              'Verification Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              'Documents Submitted',
              Icons.check_circle,
              Colors.green,
              isCompleted: true, // Always true if they can see this screen
            ),
            _buildTimelineItem(
              'Under Review',
              Icons.pending,
              Colors.orange.shade300,
              isCompleted: status == 'approved' || status == 'rejected',
            ),
            _buildTimelineItem(
              'Verification Complete',
              Icons.verified,
              status == 'approved' ? Colors.green : (status == 'rejected' ? Colors.red.shade300 : Colors.white38),
              isCompleted: status == 'approved' || status == 'rejected',
              finalItem: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    IconData icon,
    Color color, {
    bool isCompleted = true,
    bool finalItem = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? Colors.white : Colors.white54,
                  ),
                ),
                if (finalItem)
                  Text(
                    'You will be notified of the outcome.',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarksSection(String status) {
    String remarks;
    switch (status) {
      case 'rejected':
        remarks =
            'Your verification was rejected. Please check your documents and resubmit, or contact an administrator for more details.';
        break;
      case 'approved':
        remarks = 'Congratulations! Your profile has been successfully verified.';
        break;
      default:
        remarks =
            'Your documents are currently with the HR department for review. This process can take up to 3 business days. You will be notified via email once the review is complete.';
    }

    return Card(
      color: const Color(0xFF0B2E33).withBlue(55), // Dark card background
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text( // Title style
              'Status Details & Remarks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text( // Remarks text style
              remarks,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
