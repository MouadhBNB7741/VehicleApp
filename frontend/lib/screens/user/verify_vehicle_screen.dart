// screens/verify_vehicle_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8081/verification/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_JWT_TOKEN',
        },
        body: jsonEncode({
          'userId': 'user-123',
          'vinNumber': _vinController.text,
          'carModel': _modelController.text,
          'year': int.parse(_yearController.text),
          'mileage': int.parse(_mileageController.text),
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification requested!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Vehicle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(labelText: "VIN Number"),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: "Car Model"),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: "Year"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: "Mileage"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitVerification,
                child: const Text("Request Verification"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
