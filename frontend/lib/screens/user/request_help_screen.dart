import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestHelpScreen extends StatefulWidget {
  const RequestHelpScreen({super.key});

  @override
  State<RequestHelpScreen> createState() => _RequestHelpScreenState();
}

class _RequestHelpScreenState extends State<RequestHelpScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  String _serviceTypeId = '1'; // Example

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

  Future<void> _createRequest() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8081/request/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_JWT_TOKEN',
        },
        body: jsonEncode({
          'userId': 'user-123',
          'serviceTypeId': int.parse(_serviceTypeId),
          'locationId': 1,
          'description': _descriptionController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Request created!")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request Help")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createRequest,
                child: const Text("Submit Request"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
