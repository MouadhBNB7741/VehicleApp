import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApplyToPartnerScreen extends StatefulWidget {
  const ApplyToPartnerScreen({super.key});

  @override
  State<ApplyToPartnerScreen> createState() => _ApplyToPartnerScreenState();
}

class _ApplyToPartnerScreenState extends State<ApplyToPartnerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessNameController;
  late final TextEditingController _experienceController;
  String _serviceTypeId = '1';

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

  Future<void> _apply() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8081/partner/apply'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_JWT_TOKEN',
        },
        body: jsonEncode({
          'userId': 'user-123',
          'businessName': _businessNameController.text,
          'description': _experienceController.text,
          'serviceTypeId': int.parse(_serviceTypeId),
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Application submitted!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Apply to be Partner")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(labelText: "Business Name"),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _serviceTypeId,
                items: const [
                  DropdownMenuItem(value: '1', child: Text("Car Repair")),
                  DropdownMenuItem(value: '2', child: Text("Tire Change")),
                ],
                onChanged: (value) {
                  setState(() {
                    _serviceTypeId = value!;
                  });
                },
                decoration: const InputDecoration(labelText: "Service Type"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(labelText: "Experience"),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _apply,
                child: const Text("Submit Application"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
