import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:group_i/services/auth_service.dart';
import 'dart:io';

class VerificationSubmissionScreen extends StatefulWidget {
  const VerificationSubmissionScreen({super.key});

  @override
  State<VerificationSubmissionScreen> createState() =>
      _VerificationSubmissionScreenState();
}

class _VerificationSubmissionScreenState
    extends State<VerificationSubmissionScreen> {
  final ImagePicker _picker = ImagePicker();

  File? _idDocument;
  File? _selfiePhoto;
  File? _employmentProof;

  bool _isSubmitting = false;
  bool _idUploaded = false;
  bool _selfieUploaded = false;
  bool _employmentUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Verification'),
        backgroundColor: const Color(0xFF0B2E33),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF0B2E33),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildRequirementsSection(),
            const SizedBox(height: 24),
            _buildDocumentSection(
              '1. Certified ID Document',
              'Upload a clear photo of your government-issued ID (National ID, Passport, or Driver\'s License)',
              _idDocument,
              _idUploaded,
              _pickIdDocument,
            ),
            const SizedBox(height: 20),
            _buildDocumentSection(
              '2. Selfie Photo',
              'Take a clear selfie for identity verification. Ensure your face is clearly visible.',
              _selfiePhoto,
              _selfieUploaded,
              _pickSelfie,
            ),
            const SizedBox(height: 20),
            _buildDocumentSection(
              '3. Proof of Employment',
              'Upload employment contract, company ID, or any official document proving your employment',
              _employmentProof,
              _employmentUploaded,
              _pickEmploymentProof,
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Employee Verification',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 8),
        Text(
          'Please upload all required documents for employee verification. All documents will be verified by our HR team.',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildDocumentSection(
    String title,
    String description,
    File? file,
    bool isUploaded,
    VoidCallback onPick,
  ) {
    return Card(
      color: const Color(0xFF0B2E33).withBlue(55),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isUploaded ? Colors.green : const Color(0xFF93B1B5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUploaded ? Icons.check : Icons.upload,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold, color: Colors.white
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Text(
                description,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            if (file != null) _buildFilePreview(file, onPick),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPick,
                icon: Icon(isUploaded ? Icons.change_circle : Icons.upload),
                label: Text(isUploaded ? 'Change Document' : 'Upload Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUploaded ? Colors.orange : const Color(0xFF93B1B5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(File file, VoidCallback onReplace) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          // Image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Document Preview'),
                    ],
                  ),
                );
              },
            ),
          ),
          // Replace button
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              radius: 16,
              child: IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.white),
                onPressed: onReplace,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection() {
    return Card(
      color: const Color(0xFF0B2E33).withBlue(55),
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📋 Document Requirements',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            _buildRequirementItem('ID must be valid and not expired'),
            _buildRequirementItem('Photo must be clear and readable'),
            _buildRequirementItem('Selfie must show your full face clearly'),
            _buildRequirementItem('Employment proof must be recent'),
            _buildRequirementItem('Files must be in JPG, PNG, or PDF format'),
            _buildRequirementItem('Maximum file size: 5MB per document'),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final allUploaded = _idUploaded && _selfieUploaded && _employmentUploaded;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: allUploaded && !_isSubmitting ? _submitVerification : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: allUploaded ? Colors.green : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send),
                  const SizedBox(width: 8),
                  Text(
                    allUploaded
                        ? 'Submit Verification'
                        : 'Upload All Documents',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickIdDocument() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 90,
    );
    if (image != null) {
      setState(() {
        _idDocument = File(image.path);
        _idUploaded = true;
      });
    }
  }

  Future<void> _pickSelfie() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 90,
    );
    if (image != null) {
      setState(() {
        _selfiePhoto = File(image.path);
        _selfieUploaded = true;
      });
    }
  }

  Future<void> _pickEmploymentProof() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 90,
    );
    if (file != null) {
      setState(() {
        _employmentProof = File(file.path);
        _employmentUploaded = true;
      });
    }
  }

  Future<void> _submitVerification() async {
    if (_idDocument == null || _selfiePhoto == null || _employmentProof == null) {
      // This should not happen due to the button's enabled state, but it's a good safeguard.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please ensure all documents are uploaded.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    final authService = AuthService();
    final success = await authService.submitVerificationDocuments(
      idDocument: _idDocument!,
      selfiePhoto: _selfiePhoto!,
      employmentProof: _employmentProof!,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      // Show success or failure dialog
      showDialog(
        context: context,
        barrierDismissible: false, // User must tap button to close
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red),
              const SizedBox(width: 8),
              Text(success ? 'Submission Successful' : 'Submission Failed'),
            ],
          ),
          content: Text(
            success
                ? 'Your documents have been submitted successfully. You will be notified once they are reviewed.'
                : 'An error occurred while submitting your documents. Please try again.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                if (success) Navigator.pop(context); // Go back to dashboard
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
