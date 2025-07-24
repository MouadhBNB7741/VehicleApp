import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              // Navigate to profile
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            onTap: () {
              // Navigate to change password
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text("Email Preferences"),
            onTap: () {
              // Update email settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
