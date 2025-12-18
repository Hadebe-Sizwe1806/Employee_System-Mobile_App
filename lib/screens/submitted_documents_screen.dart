// screens/submitted_documents_screen.dart
import 'package:flutter/material.dart';
import 'package:group_i/models/verification_model.dart';
import 'package:group_i/services/auth_service.dart';
import 'package:group_i/screens/document_viewer_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SubmittedDocumentsScreen extends StatefulWidget {
  final String? employeeId;

  const SubmittedDocumentsScreen({super.key, this.employeeId});

  @override
  State<SubmittedDocumentsScreen> createState() =>
      _SubmittedDocumentsScreenState();
}

class _SubmittedDocumentsScreenState extends State<SubmittedDocumentsScreen> {
  final AuthService _authService = AuthService();
  late Future<List<DocumentUpload>> _documentsFuture;
  List<DocumentUpload> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() {
    // If employeeId is provided (admin view), fetch for that employee.
    // Otherwise, fetch for the currently logged-in user.
    final targetEmployeeId =
        widget.employeeId ?? _authService.currentUser?.userID;

    if (targetEmployeeId != null) {
      _documentsFuture = _authService.getDocumentsForEmployee(targetEmployeeId);
    } else {
      // Handle case where no user is logged in and no ID is passed
      _documentsFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.employeeId != null
              ? 'Employee Documents'
              : 'My Submitted Documents',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchDocuments,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _filterDocuments,
          ),
        ],
      ),
      body: FutureBuilder<List<DocumentUpload>>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          _documents = snapshot.data!;

          return SingleChildScrollView(
            child: Column(children: [_buildStatsCard(), _buildDocumentsList()]),
          );
        },
      ),
      floatingActionButton: widget.employeeId == null
          ? FloatingActionButton(
              onPressed: uploadDocument,
              tooltip: 'Upload Document',
              child: const Icon(Icons.upload_file),
            )
          : null,
    );
  }

  Widget _buildStatsCard() {
    final verifiedCount = _documents
        .where((doc) => doc.status == 'verified')
        .length;
    final pendingCount = _documents
        .where((doc) => doc.status == 'under_review')
        .length;
    final totalCount = _documents.length;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total', totalCount.toString(), Colors.blue),
            _buildStatItem('Verified', verifiedCount.toString(), Colors.green),
            _buildStatItem('Pending', pendingCount.toString(), Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No documents found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    if (_documents.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true, // Important when inside a SingleChildScrollView
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        return _buildDocumentCard(_documents[index]);
      },
    );
  }

  Widget _buildDocumentCard(DocumentUpload document) {
    Color statusColor;
    String statusText;

    switch (document.status) {
      case 'verified':
        statusColor = Colors.green;
        statusText = 'Verified';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rejected';
        break;
      case 'under_review':
        statusColor = Colors.orange;
        statusText = 'Under Review';
        break;
      default:
        statusColor = Colors.blue;
        statusText = 'Uploaded';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewDocument(document),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          // Changed from Row to Column to stack content vertically
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      document.documentIcon,
                      size: 30,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.documentTypeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          document.fileName,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              document.fileSize,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${document.uploadDate.day}/${document.uploadDate.month}/${document.uploadDate.year}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        onPressed: () => _viewDocument(document),
                        tooltip: 'View Document',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildAdminActions(
              document,
            ), // Add this line to include admin actions
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActions(DocumentUpload document) {
    // Only show actions if in admin view
    if (widget.employeeId == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {}, // TODO: Implement approve logic
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Approve'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {}, // TODO: Implement reject logic
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Reject'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _viewDocument(DocumentUpload document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(document: document),
      ),
    );
  }

  void _searchDocuments() {
    showSearch(context: context, delegate: DocumentSearchDelegate(_documents));
  }

  void _filterDocuments() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Documents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFilterOption('All Documents', Icons.all_inclusive),
          _buildFilterOption(
            'Verified Only',
            Icons.verified,
            color: Colors.green,
          ),
          _buildFilterOption(
            'Pending Review',
            Icons.pending,
            color: Colors.orange,
          ),
          _buildFilterOption(
            'ID Documents',
            Icons.credit_card,
            color: Colors.blue,
          ),
          _buildFilterOption(
            'Employment Proof',
            Icons.work,
            color: Colors.purple,
          ),
          _buildFilterOption('Selfie Photos', Icons.face, color: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    String title,
    IconData icon, {
    Color color = Colors.grey,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        // Implement filter logic here
      },
    );
  }

  Future<void> uploadDocument() async {
    try {
      // First let user select document type
      String? selectedDocType = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Document Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: const Text('ID Document'),
                  onTap: () => Navigator.pop(context, 'ID_DOCUMENT'),
                ),
                ListTile(
                  leading: const Icon(Icons.work),
                  title: const Text('Employment Proof'),
                  onTap: () => Navigator.pop(context, 'EMPLOYMENT_PROOF'),
                ),
                ListTile(
                  leading: const Icon(Icons.face),
                  title: const Text('Selfie Photo'),
                  onTap: () => Navigator.pop(context, 'SELFIE_PHOTO'),
                ),
              ],
            ),
          );
        },
      ); // User cancelled

      if (selectedDocType == null) return;

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Handle file upload based on platform
      late final UploadTask uploadTask;
      if (kIsWeb) {
        // For web, use bytes
        final bytes = await image.readAsBytes();
        final storageRef = FirebaseStorage.instance.ref().child(
          'documents/${_authService.currentUser?.userID}/$selectedDocType/${image.name}',
        );
        uploadTask = storageRef.putData(bytes);
      } else {
        // For mobile, use file
        final file = File(image.path);
        final storageRef = FirebaseStorage.instance.ref().child(
          'documents/${_authService.currentUser?.userID}/$selectedDocType/${image.name}',
        );
        uploadTask = storageRef.putFile(file);
      }

      // Continue with upload
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Create document record
      final DocumentUpload newDocument = DocumentUpload(
        uploadId: DateTime.now().millisecondsSinceEpoch.toString(),
        requestId: 'REQ_${DateTime.now().millisecondsSinceEpoch}',
        documentType: selectedDocType,
        filePath: downloadUrl,
        fileName: image.name,
        fileSize: kIsWeb
            ? 'Unknown'
            : '${(await File(image.path).length() / 1024 / 1024).toStringAsFixed(2)} MB',
        uploadDate: DateTime.now(),
        status: 'under_review',
        verificationNotes: null,
        documentIcon: Icons.description,
      );

      // Save to Firestore
      await _authService.saveDocument(newDocument);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      setState(() {
        _loadDocuments();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading document: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class DocumentSearchDelegate extends SearchDelegate {
  final List<DocumentUpload> documents;

  DocumentSearchDelegate(this.documents);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = documents
        .where(
          (doc) =>
              doc.documentTypeName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              doc.fileName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final document = results[index];
        return ListTile(
          leading: Icon(document.documentIcon),
          title: Text(document.documentTypeName),
          subtitle: Text(document.fileName),
          trailing: Text(
            '${document.uploadDate.day}/${document.uploadDate.month}/${document.uploadDate.year}',
          ),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentViewerScreen(document: document),
              ),
            );
          },
        );
      },
    );
  }
}
