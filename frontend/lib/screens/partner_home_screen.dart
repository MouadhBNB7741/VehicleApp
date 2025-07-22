import 'package:flutter/material.dart';

class PartnerHomeScreen extends StatelessWidget {
  const PartnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Partner Home")),
      body: const Center(child: Text("Welcome, Partner!")),
    );
  }
}
