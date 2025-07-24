import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';

class VerifyVehicleScreen extends StatefulWidget {
  const VerifyVehicleScreen({super.key});

  @override
  State<VerifyVehicleScreen> createState() => _VerifyVehicleScreenState();
}

class _VerifyVehicleScreenState extends State<VerifyVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _vinController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _mileageController;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _vinController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController();
    _mileageController = TextEditingController();
  }

  @override
  void dispose() {
    _vinController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _submitVerification() async {
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
          'vinNumber': _vinController.text.trim(),
          'carModel': _modelController.text.trim(),
          'year': int.tryParse(_yearController.text.trim()) ?? 0,
          'mileage': int.tryParse(_mileageController.text.trim()) ?? 0,
        });

        print("Sending verification request: $requestBody");

        final response = await http.post(
          Uri.parse(
            'http://10.0.2.2:8081/carVerification/request',
          ), // Adjust IP if needed
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: requestBody,
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Verification submitted successfully!"),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _vinController.clear();
          _modelController.clear();
          _yearController.clear();
          _mileageController.clear();
        } else {
          print(
            'Verification failed. Status: ${response.statusCode}. Body: ${response.body}',
          );
          setState(() {
            _errorMessage =
                "Verification failed (Status ${response.statusCode}). Please try again.";
          });
        }
      } catch (error) {
        print("Network error: $error");
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
          "Vehicle Verification",
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
              // Verification Header Card
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_user,
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
                              "Vehicle Verification",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Verify your vehicle to access all features",
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

              // Input Fields Section
              const Text(
                "Vehicle Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                "Provide accurate information for verification",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // VIN Number Field
              TextFormField(
                controller: _vinController,
                decoration: InputDecoration(
                  labelText: "VIN Number",
                  hintText: "Enter 17-character VIN",
                  prefixIcon: const Icon(Icons.pin),
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'VIN is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Enter valid VIN (min 10 chars)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Model Field
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: "Car Model",
                  hintText: "e.g., Toyota Camry",
                  prefixIcon: const Icon(Icons.directions_car),
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
                validator: (value) =>
                    value?.trim().isEmpty ?? true ? 'Model is required' : null,
              ),
              const SizedBox(height: 16),

              // Year Field
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(
                  labelText: "Manufacturing Year",
                  hintText: "e.g., 2020",
                  prefixIcon: const Icon(Icons.calendar_today),
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
                keyboardType: TextInputType.number,
                validator: (value) {
                  final year = int.tryParse(value?.trim() ?? '');
                  if (year == null ||
                      year < 1886 ||
                      year > DateTime.now().year + 1) {
                    return 'Enter valid year (1886-${DateTime.now().year + 1})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mileage Field
              TextFormField(
                controller: _mileageController,
                decoration: InputDecoration(
                  labelText: "Current Mileage",
                  hintText: "e.g., 35000",
                  prefixIcon: const Icon(Icons.speed),
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
                keyboardType: TextInputType.number,
                validator: (value) {
                  final mileage = int.tryParse(value?.trim() ?? '');
                  if (mileage == null || mileage < 0) {
                    return 'Enter valid mileage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitVerification,
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
                            Icon(Icons.verified_user, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "VERIFY VEHICLE",
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Why Verify Your Vehicle?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        Icons.verified,
                        "Official verification badge",
                        "Get a verified status for your vehicle",
                      ),
                      _buildBenefitItem(
                        Icons.security,
                        "Increased trust",
                        "Build credibility when applying as a partner",
                      ),
                      _buildBenefitItem(
                        Icons.history,
                        "History tracking",
                        "Maintain a record of your vehicle's status",
                      ),
                      _buildBenefitItem(
                        Icons.help_center,
                        "Support priority",
                        "Get faster help for verified vehicles",
                      ),
                    ],
                  ),
                ),
              ),
            ], // This closes the Column's children list correctly
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
