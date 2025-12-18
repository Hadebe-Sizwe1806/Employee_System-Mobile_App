// services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/verification_model.dart';
import '../models/activity_log_model.dart';
import '../models/user_model.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:intl/intl.dart' as intl;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    // Listen to auth state changes to automatically load/clear user data and notify listeners.
    _firebaseAuth.authStateChanges().listen(_onAuthStateChangedAndNotify);
  }

  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  // A controller to broadcast the current user state.
  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();

  // A stream that emits the current user when the auth state changes
  Stream<User?> get onUserChanged => _userController.stream;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isEmployee => _currentUser?.role == 'employee';

  Future<String> login({
    required String role,
    String? email,
    String? username,
    String? employeeId,
    required String password,
  }) async {
    // Mock authentication for admin, Firebase for employee
    await Future.delayed(const Duration(seconds: 1));

    if (role == 'admin' &&
        email != null &&
        email == 'admin@ghostsystem.com' &&
        password == 'admin123') {
      _currentUser = Admin(
        userID: 'ADM001',
        username: 'System Admin',
        email: email,
        password: password,
        department: 'HR',
      );
      // Notify listeners about the user change for the mock admin login
      _userController.add(_currentUser);
      return "Success";
    } else if (role == 'employee' && email != null && employeeId != null) {
      // Secure "Sign-in or Register" flow using Firebase Auth
      try {
        // Try to sign in first
        final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          await _loadCurrentUser(userCredential.user!.uid);
          // If user exists, require passkey (SA ID Number) verification
          if (_currentUser != null) {
            return "PasskeyRequired";
          }
        }
      } on fb_auth.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          try {
            // --- START: New User Validation ---
            final username = email.split('@').first;

            // Check for unique employee ID
            final idQuery = await _firestore
                .collection('employees')
                .where('employeeID', isEqualTo: employeeId)
                .limit(1)
                .get();
            if (idQuery.docs.isNotEmpty) {
              return "An employee with this ID already exists.";
            }

            // Check for unique username
            final usernameQuery = await _firestore
                .collection('employees')
                .where('username', isEqualTo: username)
                .limit(1)
                .get();
            if (usernameQuery.docs.isNotEmpty) {
              return "An employee with this username already exists.";
            }
            // --- END: New User Validation ---

            // If validation passes, register the new user
            final newUserCredential = await _firebaseAuth
                .createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );

            // Now, create the corresponding employee document in Firestore
            final newEmployee = Employee(
              userID: newUserCredential.user!.uid, // Use the UID from Auth
              employeeID: employeeId,
              email: email,
              password: '', // DO NOT STORE PLAINTEXT PASSWORD
              username: email.split('@').first,
              cellNo: '',
              idNumber: '',
              status: 'registered',
            );

            await _firestore
                .collection('employees')
                .doc(newUserCredential.user!.uid) // Use UID as document ID
                .set(newEmployee.toMap());

            // The _onAuthStateChanged listener will set the user, but we can set it here
            // to ensure it's available immediately after registration.
            await logActivity(
              'Employee profile created for ${newEmployee.username} (ID: ${newEmployee.employeeID}).',
            );
            _currentUser = newEmployee;
            return "Success";
          } catch (regError) {
            print("Error during employee registration: $regError");
            return "Registration failed. Please try again.";
          }
        } else {
          // Other auth errors (e.g., wrong-password)
          print("Error during employee sign-in: $e");
          return "Login failed. Please check your credentials.";
        }
      }
    }
    return "An unknown error occurred.";
  }

  Future<String> finalizeBiometricLogin() async {
    await logActivity(
      'Employee ${_currentUser!.username} logged in via biometrics.',
    );
    return "Success";
  }

  // Private method to handle auth state changes
  Future<void> _onAuthStateChangedAndNotify(fb_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      await _loadCurrentUser(firebaseUser.uid);
    }
    _userController.add(_currentUser);
  }

  // Helper to load user data from Firestore after login
  Future<void> _loadCurrentUser(String uid) async {
    final doc = await _firestore.collection('employees').doc(uid).get();
    if (doc.exists) {
      _currentUser = Employee.fromMap(uid, doc.data()!);
    }
  }

  Future<Employee?> getEmployeeByUid(String uid) async {
    try {
      final doc = await _firestore.collection('employees').doc(uid).get();
      if (doc.exists) {
        return Employee.fromMap(uid, doc.data()!);
      }
      return null;
    } catch (e) {
      print("Error fetching employee by UID: $e");
      return null;
    }
  }

  Future<bool> updateEmployeeProfile(Employee updatedEmployee) async {
    // Allow update if the current user is an admin, or if the employee is updating their own profile.
    if (!isAdmin &&
        (_currentUser == null ||
            _currentUser!.userID != updatedEmployee.userID)) {
      return false; // Not an admin and not updating own profile
    }

    try {
      await _firestore
          .collection('employees')
          .doc(updatedEmployee.userID)
          .update(updatedEmployee.toMap());
      // Only update the local _currentUser if the employee is updating their own profile.
      // Do NOT change the current user if an admin is making the change.
      if (_currentUser?.userID == updatedEmployee.userID) {
        _currentUser = updatedEmployee; // Update local state
        _userController.add(_currentUser); // Notify listeners of the change
      }
      return true;
    } catch (e) {
      print("Error updating employee profile: $e");
      return false;
    }
  }

  Future<bool> updateAdminProfile(Admin updatedAdmin) async {
    // Mock API call to update profile
    await Future.delayed(const Duration(seconds: 2));

    if (_currentUser is Admin) {
      _currentUser = updatedAdmin;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    if (isAdmin) {
      // For mock admin, manually clear the user and notify listeners.
      _currentUser = null;
      _userController.add(null);
    } else {
      // For Firebase users, signOut will trigger the auth state listener.
      await _firebaseAuth.signOut();
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      print("Error sending password reset email: $e");
      return false;
    }
  }

  Future<String> changePassword(String oldPassword, String newPassword) async {
    final user = _firebaseAuth.currentUser;
    final email = user?.email;

    if (user == null || email == null) {
      return "User not found. Please log in again.";
    }

    try {
      // Re-authenticate the user with their old password
      final cred = fb_auth.EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // If re-authentication is successful, update the password
      await user.updatePassword(newPassword);
      return "Success";
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return "Incorrect old password. Please try again.";
      }
      print("Error changing password: $e");
      return "An error occurred. Please try again later.";
    }
  }

  Future<bool> submitVerificationDocuments({
    required dynamic idDocument,
    required dynamic selfiePhoto,
    required dynamic employmentProof,
  }) async {
    // Mock API call to submit documents
    await Future.delayed(const Duration(seconds: 2));
    // In a real app, you would upload files to storage and create a verification record in Firestore.
    print('Submitting documents for user: ${_currentUser?.userID}');
    return true; // Simulate success
  }

  Stream<List<Employee>> getVerifiableEmployeesStream() {
    return _firestore
        .collection('employees')
        .where(
          'status',
          isNotEqualTo: 'deleted',
        ) // Fetch all non-deleted employees
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Employee.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  Future<bool> updateEmployeeStatus(
    String employeeUid,
    String newStatus,
  ) async {
    // For mock admin, we can't update Firestore due to permissions.
    // We will simulate a successful update for a better UX during testing.
    if (isAdmin) {
      await Future.delayed(const Duration(seconds: 1));
      print(
        'Mock Admin: Simulating status update for $employeeUid to $newStatus',
      );
      return true;
    }
    try {
      await _firestore.collection('employees').doc(employeeUid).update({
        'status': newStatus,
      });
      // If the updated user is the current user, refresh local data
      if (_currentUser?.userID == employeeUid) {
        await _loadCurrentUser(employeeUid);
        _userController.add(_currentUser);
      }
      return true;
    } catch (e) {
      print("Error updating employee status: $e");
      return false;
    }
  }

  Future<List<DocumentUpload>> getDocumentsForEmployee(
    String employeeId,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('documents')
          .where('userId', isEqualTo: employeeId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DocumentUpload(
          uploadId: data['uploadId'],
          requestId: data['requestId'],
          documentType: data['documentType'],
          filePath: data['filePath'],
          fileName: data['fileName'],
          fileSize: data['fileSize'],
          uploadDate: (data['uploadDate'] as Timestamp).toDate(),
          status: data['status'],
          verificationNotes: data['verificationNotes'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching documents: $e');
      throw Exception('Failed to fetch documents: $e');
    }
  }

  Future<void> logActivity(String message) async {
    try {
      await _firestore.collection('activity_logs').add({
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error logging activity: $e");
    }
  }

  Stream<List<ActivityLog>> getActivityLogs() {
    return _firestore
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .limit(100) // Get the last 100 activities
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ActivityLog.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<ActivityLog>> getScanActivityLogs() {
    return _firestore
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .limit(200) // Fetch a larger batch to filter on the client
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ActivityLog.fromFirestore(doc))
              // Filter for messages that start with the clock-in prefix
              .where((log) => log.message.startsWith('Admin clocked in'))
              .toList();
        });
  }

  Stream<Map<String, int>> getDashboardStats() {
    return _firestore.collection('employees').snapshots().map((snapshot) {
      int total = 0;
      int pending = 0;
      int approved = 0;
      int rejected = 0;

      total = snapshot.docs.length;

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String?;
        switch (status) {
          case 'registered':
            pending++;
            break;
          case 'approved':
            approved++;
            break;
          case 'rejected':
            rejected++;
            break;
        }
      }
      // 'Approved Today' would require storing an approval timestamp.
      // For now, we'll just show the total approved count.
      return {
        'total': total,
        'pending': pending,
        'approved': approved,
        'rejected': rejected,
      };
    });
  }

  Future<bool> requestStaffCardPhoto(String employeeId) async {
    try {
      await _firestore.collection('employees').doc(employeeId).update({
        'staffCardPhotoStatus': 'requested',
      });
      return true;
    } catch (e) {
      print("Error requesting staff card photo: $e");
      return false;
    }
  }

  Future<String> createEmployeeByAdmin({
    required String username,
    required String email,
    required String employeeId,
    required String department,
    required String jobTitle,
  }) async {
    try {
      // --- New User Validation ---
      final idQuery = await _firestore
          .collection('employees')
          .where('employeeID', isEqualTo: employeeId)
          .limit(1)
          .get();
      if (idQuery.docs.isNotEmpty) {
        return "An employee with this ID already exists.";
      }
      final emailQuery = await _firestore
          .collection('employees')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (emailQuery.docs.isNotEmpty) {
        return "An employee with this email already exists.";
      }
      // --- END: New User Validation ---

      final newEmployee = Employee(
        userID: _firestore
            .collection('employees')
            .doc()
            .id, // Generate a new UID
        employeeID: employeeId,
        email: email,
        password: '', // No password for admin-created users initially
        username: username,
        cellNo: '',
        idNumber: '',
        status: 'registered', // They still need to submit documents
        department: department,
        jobTitle: jobTitle,
      );

      await _firestore
          .collection('employees')
          .doc(newEmployee.userID)
          .set(newEmployee.toMap());
      await logActivity(
        'Admin created profile for ${newEmployee.username} (ID: ${newEmployee.employeeID}).',
      );
      return 'Employee created successfully.';
    } catch (e) {
      print("Error creating employee by admin: $e");
      return 'An unexpected error occurred.';
    }
  }

  Future<bool> clockInEmployee(
    String employeeId,
    DateTime clockInTime,
    Map<String, double>? location,
  ) async {
    if (!isAdmin) return false;

    try {
      final employeeDoc = await _firestore
          .collection('employees')
          .doc(employeeId)
          .get();
      if (!employeeDoc.exists) return false;

      final employeeName = employeeDoc.data()?['username'] ?? 'Unknown';

      await _firestore.collection('employees').doc(employeeId).update({
        'lastClockIn': clockInTime.toIso8601String(),
        'lastClockInLocation': location,
      });

      String logMessage =
          'Admin clocked in $employeeName at ${intl.DateFormat('yyyy-MM-dd - hh:mm a').format(clockInTime)}.';
      if (location != null) {
        logMessage +=
            ' from location: ${location['latitude']?.toStringAsFixed(5)}, ${location['longitude']?.toStringAsFixed(5)}.';
      }
      await logActivity(logMessage);
      return true;
    } catch (e) {
      print("Error during employee clock-in: $e");
      return false;
    }
  }

  Future<bool> deleteEmployeeProfile(String employeeId, String reason) async {
    if (!isAdmin) {
      return false; // Only admins can delete profiles.
    }

    try {
      // Get employee details to log username before deletion
      final doc = await _firestore
          .collection('employees')
          .doc(employeeId)
          .get();
      final username = doc.data()?['username'] ?? 'Unknown';

      await _firestore.collection('employees').doc(employeeId).update({
        'status': 'deleted', // Note: This is a soft delete.
        'deletionReason': reason,
        'deletedAt':
            FieldValue.serverTimestamp(), // Keep track of when it was deleted
      });
      await logActivity(
        'Admin deleted profile for $username (ID: $employeeId) for reason: $reason.',
      );
      return true;
    } catch (e) {
      print("Error deleting employee profile: $e");
      return false;
    }
  }

  // Add this method to save documents
  Future<void> saveDocument(DocumentUpload document) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('documents')
          .doc(document.uploadId);

      await docRef.set({
        'uploadId': document.uploadId,
        'requestId': document.requestId,
        'documentType': document.documentType,
        'filePath': document.filePath,
        'fileName': document.fileName,
        'fileSize': document.fileSize,
        'uploadDate': Timestamp.fromDate(document.uploadDate),
        'status': document.status,
        'verificationNotes': document.verificationNotes,
        'userId': currentUser?.userID,
      });
    } catch (e) {
      // Handle any errors
      print('Error saving document: $e');
      throw Exception('Failed to save document: $e');
    }
  }
}
