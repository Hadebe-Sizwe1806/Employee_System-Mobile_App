import 'package:flutter/material.dart';
import 'package:group_i/models/user_model.dart';
import 'package:group_i/services/auth_service.dart';
import 'package:group_i/screens/submitted_documents_screen.dart';
import 'package:intl/intl.dart' as intl;

class VerificationDetailScreen extends StatefulWidget {
  final Employee employee;

  const VerificationDetailScreen({super.key, required this.employee});

  @override
  State<VerificationDetailScreen> createState() =>
      _VerificationDetailScreenState();
}

class _VerificationDetailScreenState extends State<VerificationDetailScreen> {
  final AuthService _authService = AuthService();
  bool _isProcessing = false;
  final _jobTitleController = TextEditingController();
  String? _selectedDepartment;
  final List<String> _departments = ['HR', 'IT', 'FINANCE', 'MARKETING'];

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing data if available
    // If department is an empty string, treat it as null for the dropdown's value
    final initialDepartment = widget.employee.department;
    _selectedDepartment = (initialDepartment != null && initialDepartment.isNotEmpty) ? initialDepartment : null;
    _jobTitleController.text = widget.employee.jobTitle;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _isProcessing = true;
    });

    // Create an updated employee object with the new status and profile info
    final updatedEmployee = widget.employee.copyWith(
      status: newStatus,
      jobTitle: _jobTitleController.text.trim(),
      department: _selectedDepartment,
    );

    // Call the service to update the entire profile
    final success = await _authService.updateEmployeeProfile(updatedEmployee);

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Employee status updated to "$newStatus"'
              : 'Failed to update status.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        // Go back to the list screen after a successful update
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Details'),
        backgroundColor: const Color(0xFF36454F), // Admin theme
        foregroundColor: Colors.white, // Admin theme
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 24),
            _buildAssignmentCard(),
            const SizedBox(height: 24),
            if (widget.employee.status == 'approved') ...[
              _buildClockInCard(),
              const SizedBox(height: 24),
            ],
            _buildDocumentsCard(),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    super.dispose();
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employee Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildInfoRow('Username', widget.employee.username),
            _buildInfoRow('Email', widget.employee.email),
            _buildInfoRow('Employee Number', widget.employee.employeeID),
            _buildInfoRow('SA ID Number', widget.employee.idNumber),
            _buildInfoRow('Cell Number', widget.employee.cellNo),
            _buildInfoRow('Current Status', widget.employee.status,
                isStatus: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not Provided' : value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isStatus ? Colors.blue : Colors.grey[700],
                fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign Department & Role',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedDepartment,
              hint: const Text('Select Department'),
              items: _departments.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedDepartment = value);
              },
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _jobTitleController,
              decoration: const InputDecoration(
                labelText: 'Job Title (e.g., Software Developer)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveProfileChanges,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF36454F),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfileChanges() async {
    final updatedEmployee = widget.employee.copyWith(
      jobTitle: _jobTitleController.text.trim(),
      department: _selectedDepartment,
    );
    final success = await _authService.updateEmployeeProfile(updatedEmployee);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Profile changes saved.' : 'Failed to save changes.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
    }
  }

  Widget _buildClockInCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manual Clock-In',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Last clock-in: ${widget.employee.lastClockIn != null ? intl.DateFormat('yyyy-MM-dd - hh:mm a').format(widget.employee.lastClockIn!) : 'Never'}',
              style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            if (widget.employee.lastClockInLocation != null) ...[
              const SizedBox(height: 4),
              Text(
                'Location: ${widget.employee.lastClockInLocation!['latitude']?.toStringAsFixed(5)}, ${widget.employee.lastClockInLocation!['longitude']?.toStringAsFixed(5)}',
                style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showClockInPicker,
                icon: const Icon(Icons.timer),
                label: const Text('Set Clock-In Time'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClockInPicker() async {
    final now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
    );

    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (pickedTime == null) return;

    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() => _isProcessing = true);

    // Manual clock-in from admin screen does not include location
    final success = await _authService.clockInEmployee(
      widget.employee.userID,
      finalDateTime,
      null, // No location for manual entry
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Employee clocked in successfully.'
              : 'Failed to clock in employee.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildDocumentsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Submitted Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubmittedDocumentsScreen(
                        employeeId: widget.employee.userID),
                  ),
                );
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('View Submitted Documents'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            if (widget.employee.status == 'approved') ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final success = await _authService
                      .requestStaffCardPhoto(widget.employee.userID);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success
                          ? 'Photo request sent to employee.'
                          : 'Failed to send request.'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ));
                  }
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Request Staff Card Photo'),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Verification Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_isProcessing)
          const Center(child: CircularProgressIndicator())
        else
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus('rejected'),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus('approved'),
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDeleteButton(),
              ),
            ],
          ),
      ],
    );
  }

    Widget _buildDeleteButton() {
      return ElevatedButton.icon(
        onPressed: _showDeleteConfirmationDialog,
        icon: const Icon(Icons.delete_forever),
        label: const Text('Delete'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[800],
          foregroundColor: Colors.white,
        ),
      );
    }
  
    Future<void> _showDeleteConfirmationDialog() async {
      String? selectedReason;
      final reasons = ['hacker', 'retired', 'deceased', 'fired', 'other'];
  
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Delete Employee Profile'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      const Text('Are you sure you want to permanently delete this employee\'s profile? This action cannot be undone.'),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        initialValue: selectedReason,
                        hint: const Text('Select reason for deletion'),
                        items: reasons.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value[0].toUpperCase() + value.substring(1)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedReason = value;
                          });
                        },
                        validator: (v) => v == null ? 'Reason is required' : null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: selectedReason == null
                        ? null
                        : () async {
                            Navigator.of(context).pop(); // Close dialog
                            await _deleteProfile(selectedReason!);
                          },
                    child: const Text('Delete Profile'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  
    Future<void> _deleteProfile(String reason) async {
      setState(() => _isProcessing = true);
      final success = await _authService.deleteEmployeeProfile(widget.employee.userID, reason);
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Employee profile deleted.' : 'Failed to delete profile.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          Navigator.pop(context);
        }
      }
    }
}