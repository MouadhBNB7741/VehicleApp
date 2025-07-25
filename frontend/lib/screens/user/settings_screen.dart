import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailUpdatesEnabled = false;
  bool _darkModeEnabled = false;
  bool _locationSharingEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
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
        child: Column(
          children: [
            // Profile Card
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
                        Icons.person,
                        size: 28,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'email@example.com',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue.shade600),
                      onPressed: () {
                        // Navigate to edit profile
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App Settings Section
            _buildSectionHeader("App Preferences"),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              child: Column(
                children: [
                  _buildSettingsSwitchItem(
                    icon: Icons.notifications,
                    title: "Push Notifications",
                    subtitle: "Receive instant alerts for new requests",
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  _buildSettingsSwitchItem(
                    icon: Icons.email,
                    title: "Email Updates",
                    subtitle: "Get weekly summaries and news",
                    value: _emailUpdatesEnabled,
                    onChanged: (value) {
                      setState(() {
                        _emailUpdatesEnabled = value;
                      });
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  _buildSettingsSwitchItem(
                    icon: Icons.dark_mode,
                    title: "Dark Mode",
                    subtitle: "Switch between light and dark theme",
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _darkModeEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Privacy Section
            _buildSectionHeader("Privacy & Security"),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              child: Column(
                children: [
                  _buildSettingsSwitchItem(
                    icon: Icons.location_on,
                    title: "Location Services",
                    subtitle:
                        "Allow access to your location for better service",
                    value: _locationSharingEnabled,
                    onChanged: (value) {
                      setState(() {
                        _locationSharingEnabled = value;
                      });
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  _buildSettingsActionItem(
                    icon: Icons.lock,
                    title: "Change Password",
                    onTap: () {
                      // Navigate to change password
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  _buildSettingsActionItem(
                    icon: Icons.visibility,
                    title: "Data Privacy",
                    onTap: () {
                      // Navigate to privacy policy
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader("Support"),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              child: Column(
                children: [
                  _buildSettingsActionItem(
                    icon: Icons.help,
                    title: "Help Center",
                    onTap: () {
                      // Navigate to help center
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  _buildSettingsActionItem(
                    icon: Icons.contact_support,
                    title: "Contact Support",
                    onTap: () {
                      // Navigate to contact support
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  _buildSettingsActionItem(
                    icon: Icons.description,
                    title: "Terms of Service",
                    onTap: () {
                      // Navigate to terms
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account Section
            _buildSectionHeader("Account"),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              child: Column(
                children: [
                  _buildSettingsActionItem(
                    icon: Icons.logout,
                    title: "Sign Out",
                    color: Colors.red,
                    onTap: () async {
                      await Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).logout();

                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Info
            Text(
              "Vehicle Assistance v1.0.0",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              "© 2025 All Rights Reserved",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSettingsSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade600),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildSettingsActionItem({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.blue.shade600),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: color),
      ),
      trailing: Icon(Icons.chevron_right, color: color ?? Colors.grey.shade400),
      onTap: onTap,
    );
  }
}
