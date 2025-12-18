import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  final String id;
  final String message;
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.message,
    required this.timestamp,
  });

  factory ActivityLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    DateTime timestamp;
    if (data['timestamp'] is Timestamp) {
      timestamp = (data['timestamp'] as Timestamp).toDate();
    } else {
      timestamp = DateTime.now(); // Fallback for local/pending writes
    }
    return ActivityLog(
      id: doc.id,
      message: data['message'] as String? ?? 'No message',
      timestamp: timestamp,
    );
  }
}