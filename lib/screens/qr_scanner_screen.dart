// screens/qr_scanner_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:group_i/models/user_model.dart';
import 'package:group_i/services/auth_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart' as intl;
import 'package:geolocator/geolocator.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final AuthService _authService = AuthService();
  bool _isProcessing = false;

  /// Determine the current position of the device.
  ///
  /// When location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      // If getting a high-accuracy location times out, try a lower accuracy one.
      if (e is TimeoutException) {
        return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      }
      return Future.error('Failed to get location: $e');
    }
  }

  Future<void> _verifyEmployee(String userId) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    // Fetch employee data using the scanned user ID
    final Employee? employee = await _authService.getEmployeeByUid(userId);

    if (!mounted) return;

    if (employee != null) {
      if (employee.status == 'approved') {
        try {
          // Get location before clocking in
          final position = await _getCurrentLocation();
          final locationData = {
            'latitude': position.latitude,
            'longitude': position.longitude,
          };

          // Clock in the employee with location
          final clockInTime = DateTime.now();
          await _authService.clockInEmployee(employee.userID, clockInTime, locationData);

          _showResultDialog(
            'Clock-In Successful',
            '${employee.username} clocked in at ${intl.DateFormat.jm().format(clockInTime)} from your location.',
            Icons.check_circle,
            Colors.green,
          );
        } catch (e) {
          _showResultDialog('Location Error', e.toString(), Icons.location_off, Colors.orange);
        }
      } else {
        _showResultDialog(
          'Verification Pending',
          'Employee ${employee.username} is not yet verified. Status: ${employee.status}',
          Icons.pending,
          Colors.orange,
        );
      }
    } else {
      _showResultDialog(
        'Invalid QR Code',
        'No employee found for the scanned QR code.',
        Icons.error,
        Colors.red,
      );
    }
  }

  void _showResultDialog(String title, String message, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isProcessing = false); // Allow scanning again
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Employee QR Code'),
        backgroundColor: const Color(0xFF36454F),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _verifyEmployee(barcodes.first.rawValue!);
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}