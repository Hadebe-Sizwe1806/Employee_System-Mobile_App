// services/csv_export_service.dart
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:group_i/models/activity_log_model.dart';
import 'package:intl/intl.dart' as intl;
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CsvExportService {
  Future<void> exportActivityLogsToCsv(
    BuildContext context,
    List<ActivityLog> logs,
    String fileName,
  ) async {
    if (logs.isEmpty) {
      _showSnackBar(context, 'There is no data to export.', isError: true);
      return;
    }

    // Check for storage permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        _showSnackBar(context, 'Storage permission is required to export files.', isError: true);
        return;
      }
    }

    // Prepare data for CSV
    List<List<dynamic>> rows = [];
    // Add header row
    rows.add(['Timestamp', 'Message']);
    // Add data rows
    for (var log in logs) {
      rows.add([
        intl.DateFormat('yyyy-MM-dd HH:mm:ss').format(log.timestamp),
        log.message,
      ]);
    }

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(rows);

    try {
      // Get the directory to save the file
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        _showSnackBar(context, 'Could not find a directory to save the file.', isError: true);
        return;
      }
      final path = "${directory.path}/$fileName";
      final file = File(path);

      // Write the file
      await file.writeAsString(csv);

      // Show success message and offer to open the file
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported successfully to $path'),
          action: SnackBarAction(
            label: 'OPEN',
            onPressed: () => OpenFile.open(path),
          ),
        ),
      );
    } catch (e) {
      _showSnackBar(context, 'Error exporting file: $e', isError: true);
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }
}