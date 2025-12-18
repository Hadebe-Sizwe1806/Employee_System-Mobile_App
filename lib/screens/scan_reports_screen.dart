// screens/scan_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:group_i/models/activity_log_model.dart';
import 'package:group_i/services/auth_service.dart';
import 'package:group_i/services/csv_export_service.dart';
import 'package:intl/intl.dart' as intl;

class ScanReportsScreen extends StatefulWidget {
  const ScanReportsScreen({super.key});

  @override
  State<ScanReportsScreen> createState() => _ScanReportsScreenState();
}

class _ScanReportsScreenState extends State<ScanReportsScreen> {
  final AuthService _authService = AuthService();
  final CsvExportService _csvExportService = CsvExportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Clock-In Reports'),
        backgroundColor: const Color(0xFF36454F),
        foregroundColor: Colors.white,
        actions: [
          StreamBuilder<List<ActivityLog>>(
            stream: _authService.getScanActivityLogs(),
            builder: (context, snapshot) {
              return IconButton(
                icon: const Icon(Icons.download),
                onPressed: snapshot.hasData && snapshot.data!.isNotEmpty
                    ? () => _csvExportService.exportActivityLogsToCsv(context, snapshot.data!, 'scan_reports.csv')
                    : null,
              );
            }),
        ],
      ),
      body: StreamBuilder<List<ActivityLog>>(
        stream: _authService.getScanActivityLogs(),
        builder: (context, snapshot) {
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
                  Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No clock-in activities found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final logs = snapshot.data!;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: Text(log.message),
                  subtitle: Text(
                    intl.DateFormat('yyyy-MM-dd - hh:mm a')
                        .format(log.timestamp),
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