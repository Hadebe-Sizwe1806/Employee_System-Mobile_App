// models/user_model.dart
abstract class User {
  String userID;
  String username;
  String email;
  String role;
  String? department;

  User({
    required this.userID,
    required this.username,
    required this.email,
    required this.role,
    this.department,
  });
}

class Employee extends User {
  String employeeID;
  String password;
  
  String cellNo;
  String idNumber;
  String status;
  String jobTitle;
  String? staffCardPhotoStatus;
  DateTime? lastClockIn;
  String? deletionReason;
  Map<String, double>? lastClockInLocation;

  Employee({
    required super.userID,
    required super.username,
    required super.email,
    required this.employeeID,
    required this.password,
    
    required this.cellNo,
    required this.idNumber,
    required this.status,
    this.jobTitle = '',
    this.staffCardPhotoStatus,
    this.lastClockIn,
    this.deletionReason,
    this.lastClockInLocation,
    super.department,
  }) : super(
         role: 'employee',
       );

  // Factory constructor to create an Employee from a map (Firestore data)
  factory Employee.fromMap(String userID, Map<String, dynamic> data) {
    return Employee(
      userID: userID,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      employeeID: data['employeeID'] ?? '',
      password: data['password'] ?? '', // Be cautious with password handling
      cellNo: data['cellNo'] ?? '',
      idNumber: data['idNumber'] ?? '',
      status: data['status'] ?? 'unknown',
      jobTitle: data['jobTitle'] ?? '',
      department: data['department'] ?? '',
      staffCardPhotoStatus: data['staffCardPhotoStatus'],
      lastClockIn: data['lastClockIn'] != null
          ? DateTime.tryParse(data['lastClockIn'] as String)
          : null,
      deletionReason: data['deletionReason'],
      lastClockInLocation: data['lastClockInLocation'] != null
          ? Map<String, double>.from(data['lastClockInLocation'])
          : null,
    );
  }

  // Method to convert Employee object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'employeeID': employeeID,
      // 'password' is intentionally omitted for security
      'cellNo': cellNo,
      'idNumber': idNumber,
      'status': status,
      'jobTitle': jobTitle,
      'department': department,
      'staffCardPhotoStatus': staffCardPhotoStatus,
      'lastClockIn': lastClockIn?.toIso8601String(),
      'deletionReason': deletionReason,
      'lastClockInLocation': lastClockInLocation,
    };
  }

  // Copy with method for easy updates
  Employee copyWith({
    String? username,
    String? email,
    String? employeeID,
    String? password,
    
    String? cellNo,
    String? idNumber,
    String? status,
    String? jobTitle,
    String? staffCardPhotoStatus,
    DateTime? lastClockIn,
    String? department,
    String? deletionReason,
    Map<String, double>? lastClockInLocation,
  }) {
    return Employee(
      userID: userID,
      username: username ?? this.username,
      email: email ?? this.email,
      employeeID: employeeID ?? this.employeeID,
      password: password ?? this.password,
     
      cellNo: cellNo ?? this.cellNo,
      idNumber: idNumber ?? this.idNumber,
      status: status ?? this.status,
      jobTitle: jobTitle ?? this.jobTitle,
      staffCardPhotoStatus: staffCardPhotoStatus ?? this.staffCardPhotoStatus,
      lastClockIn: lastClockIn ?? this.lastClockIn,
      department: department ?? this.department,
      deletionReason: deletionReason ?? this.deletionReason,
      lastClockInLocation: lastClockInLocation ?? this.lastClockInLocation,
    );
  }
}

class Admin extends User {
  String password;

  Admin({
    required super.userID,
    required super.username,
    required super.email,
    required this.password,
    required String super.department,
  }) : super(
         role: 'admin',
       );

  Admin copyWith({
    String? username,
    String? email,
    String? password,
    String? department,
  }) {
    return Admin(
      userID: userID,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      department: department ?? this.department ?? '',
    );
  }
}
