import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';

class ApplyToPartnerScreen extends StatefulWidget {
  const ApplyToPartnerScreen({super.key});

  @override
  State<ApplyToPartnerScreen> createState() => _ApplyToPartnerScreenState();
}

class _ApplyToPartnerScreenState extends State<ApplyToPartnerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessNameController;
  late final TextEditingController _experienceController;

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _cvUrl;
  bool _isCvUploaded = false;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController();
    _experienceController = TextEditingController();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _pickCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        setState(() {
          _cvUrl = file.name;
          _isCvUploaded = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Selected CV: ${file.name}")));
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error selecting CV. Please try again.";
      });
    }
  }

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _errorMessage = null;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isAuthenticated) {
          setState(() {
            _isSubmitting = false;
            _errorMessage = "Please log in.";
          });
          return;
        }

        final userId = authProvider.user!.id;
        final token = await authProvider.authToken;

        if (token == null) {
          setState(() {
            _isSubmitting = false;
            _errorMessage = "Authentication error.";
          });
          return;
        }

        final requestBody = jsonEncode({
          'userId': userId,
          'businessName': _businessNameController.text.trim(),
          'experienceSummary': _experienceController.text.trim(),
          'serviceTypeId': 1,
          'cvUrl': _cvUrl ?? "",
        });

        final response = await http.post(
          Uri.parse('http://localhost:8081/partner/apply'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: requestBody,
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Application submitted successfully!"),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _businessNameController.clear();
          _experienceController.clear();
          setState(() {
            _cvUrl = null;
            _isCvUploaded = false;
          });
        } else {
          setState(() {
            _errorMessage =
                "Application failed (Status ${response.statusCode}). Please try again.";
          });
        }
      } catch (error) {
        setState(() {
          _errorMessage = "Network error. Please check your connection.";
        });
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Become a Partner",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade800, Colors.blue.shade600],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.handshake,
                          size: 28,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Join Our Professional Network",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Expand your business by connecting with customers needing roadside assistance",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Business Details Section
              const Text(
                "Business Information",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                "Tell us about your business or service",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // Business Name Field
              TextFormField(
                controller: _businessNameController,
                decoration: InputDecoration(
                  labelText: "Business/Service Name *",
                  hintText: "e.g., QuickFix Auto Services",
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade400,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) => value?.trim().isEmpty ?? true
                    ? 'Please enter your business name'
                    : null,
              ),
              const SizedBox(height: 16),

              // Experience Field
              const Text(
                "Your Experience",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                "Highlight your qualifications and experience in roadside assistance",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _experienceController,
                decoration: InputDecoration(
                  labelText: "Experience Summary *",
                  hintText:
                      "Describe your skills, certifications, and years of experience...",
                  prefixIcon: const Icon(Icons.work_history),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade400,
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 5,
                validator: (value) => value?.trim().isEmpty ?? true
                    ? 'Please describe your experience'
                    : null,
              ),
              const SizedBox(height: 16),

              // CV Upload Section
              const Text(
                "Professional Documentation",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                "Upload your CV or professional certifications (PDF, DOC)",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              FormField<String>(
                validator: (value) => _isCvUploaded ? null : 'CV is required',
                builder: (FormFieldState<String> field) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Upload CV *',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.blue.shade400,
                          width: 2,
                        ),
                      ),
                      errorText: field.errorText,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _isCvUploaded
                                ? _cvUrl ?? 'Document uploaded'
                                : 'No file selected',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: _isSubmitting ? null : _pickCV,
                          child: Text(
                            _isCvUploaded ? 'Change File' : 'Select File',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade400),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "SUBMIT PARTNER APPLICATION",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Benefits Section
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Partner Benefits",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        Icons.monetization_on,
                        "Earn More Income",
                        "Grow your business with new customers",
                      ),
                      _buildBenefitItem(
                        Icons.schedule,
                        "Flexible Schedule",
                        "Work when you want, as much as you want",
                      ),
                      _buildBenefitItem(
                        Icons.support_agent,
                        "Dedicated Support",
                        "24/7 assistance for your service requests",
                      ),
                      _buildBenefitItem(
                        Icons.verified_user,
                        "Verified Status",
                        "Build trust with verified partner badge",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
