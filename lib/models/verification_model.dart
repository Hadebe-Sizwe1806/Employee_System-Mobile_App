import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationRecord {
  final String verificationId;
  final String employeeId;
  final String adminId;
  final String status; // 'pending', 'approved', 'rejected', 'under_review'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? remarks;
  final List<DocumentUpload> documents;

  VerificationRecord({
    required this.verificationId,
    required this.employeeId,
    required this.adminId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.remarks,
    required this.documents,
  });
}

class DocumentUpload {
  final String uploadId;
  final String requestId;
  final String documentType;
  final String filePath;
  final String fileName;
  final String fileSize;
  final DateTime uploadDate;
  final String status;
  final String? verificationNotes;
  final IconData documentIcon;

  // Add this getter
  String get documentTypeName {
    switch (documentType) {
      case 'ID_DOCUMENT':
        return 'ID Document';
      case 'EMPLOYMENT_PROOF':
        return 'Employment Proof';
      case 'SELFIE_PHOTO':
        return 'Selfie Photo';
      default:
        return 'Unknown Document';
    }
  }

  DocumentUpload({
    required this.uploadId,
    required this.requestId,
    required this.documentType,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.uploadDate,
    this.status = 'under_review',
    this.verificationNotes,
    this.documentIcon = Icons.description,
  });

  // Add this factory method to create from Firestore data
  factory DocumentUpload.fromMap(Map<String, dynamic> data) {
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
      documentIcon: data['documentType'] == 'ID_DOCUMENT'
          ? Icons.credit_card
          : data['documentType'] == 'EMPLOYMENT_PROOF'
          ? Icons.work
          : Icons.face,
    );
  }

  // Add this method to convert to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'uploadId': uploadId,
      'requestId': requestId,
      'documentType': documentType,
      'filePath': filePath,
      'fileName': fileName,
      'fileSize': fileSize,
      'uploadDate': Timestamp.fromDate(uploadDate),
      'status': status,
      'verificationNotes': verificationNotes,
    };
  }
}
