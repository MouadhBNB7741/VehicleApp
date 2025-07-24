import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';

class ServiceOption {
  final String id;
  final String name;
  final IconData icon;
  final String description; // More descriptive text
  final Color color;
  final String imageAsset; // Asset image for visual appeal

  ServiceOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
    required this.imageAsset,
  });
}

class RequestHelpScreen extends StatefulWidget {
  const RequestHelpScreen({super.key});

  @override
  State<RequestHelpScreen> createState() => _RequestHelpScreenState();
}

class _RequestHelpScreenState extends State<RequestHelpScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  String? _selectedServiceTypeId;
  bool _isSubmitting = false;

  final List<ServiceOption> _serviceOptions = [
    ServiceOption(
      id: '1',
      name: "Emergency Help",
      icon: Icons.emergency,
      description: "Immediate assistance for critical situations",
      color: Colors.red.shade400,
      imageAsset: 'assets/images/emergency.png',
    ),
    ServiceOption(
      id: '2',
      name: "Battery Jump",
      icon: Icons.battery_charging_full,
      description: "Get your vehicle started quickly",
      color: Colors.amber.shade600,
      imageAsset: 'assets/images/battery.png',
    ),
    ServiceOption(
      id: '3',
      name: "Tire Service",
      icon: Icons.settings,
      description: "Flat tire change or repair",
      color: Colors.orange.shade400,
      imageAsset: 'assets/images/tire.png',
    ),
    ServiceOption(
      id: '4',
      name: "Fuel Delivery",
      icon: Icons.local_gas_station,
      description: "Get fuel delivered to your location",
      color: Colors.blue.shade400,
      imageAsset: 'assets/images/fuel.png',
    ),
    ServiceOption(
      id: '5',
      name: "Towing",
      icon: Icons.local_shipping,
      description: "Vehicle transport to your preferred location",
      color: Colors.indigo.shade400,
      imageAsset: 'assets/images/towing.png',
    ),
    ServiceOption(
      id: '6',
      name: "Lockout Service",
      icon: Icons.lock,
      description: "Help when you're locked out of your vehicle",
      color: Colors.teal.shade400,
      imageAsset: 'assets/images/lockout.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedServiceTypeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a service type")),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        if (!authProvider.isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You need to be logged in")),
          );
          return;
        }

        final userId = authProvider.user!.id;
        final token = await authProvider.authToken;

        if (token == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Authentication error")));
          return;
        }

        final requestBody = jsonEncode({
          'userId': userId,
          'serviceTypeId': int.parse(_selectedServiceTypeId!),
          'locationId': 1,
          'description': _descriptionController.text,
        });

        final response = await http.post(
          Uri.parse('http://localhost:8081/request/create'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: requestBody,
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Help is on the way!")));
          _descriptionController.clear();
          setState(() {
            _selectedServiceTypeId = null;
          });
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
        }
      } catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Network error: $error")));
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
          "Request Roadside Assistance",
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
              // Header
              const Text(
                "Select Service",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose the service you need and we'll connect you with help",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Service Bars
              Column(
                children: _serviceOptions.map((service) {
                  final isSelected = _selectedServiceTypeId == service.id;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? service.color.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? service.color
                            : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          _selectedServiceTypeId = isSelected
                              ? null
                              : service.id;
                        });
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: service.color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          service.icon,
                          color: service.color,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        service.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? service.color : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        service.description,
                        style: TextStyle(
                          color: isSelected
                              ? service.color.withOpacity(0.8)
                              : Colors.grey.shade600,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: service.color)
                          : const Icon(Icons.chevron_right),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Description Section
              const Text(
                "Additional Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                "Help us understand your situation better",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: "Describe your vehicle, location specifics, etc.",
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
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 4,
                validator: (value) => value!.trim().isEmpty
                    ? 'Please provide details to help our team'
                    : null,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                              "REQUEST HELP NOW",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
}
