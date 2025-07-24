import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'request_help_screen.dart';
import 'settings_screen.dart';
import 'apply_to_partner_screen.dart';
import 'contact_us_screen.dart';
import 'verify_vehicle_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final AuthProvider _userProvider =
      AuthProvider(); // Replace with your actual provider

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome back!', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Navigate to settings
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/48', // Replace with actual user avatar
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Normal User',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Main Cards
            _buildCard(
              icon: Icon(Icons.warning_amber_rounded, color: Colors.red),
              title: 'Request Help',
              subtitle: 'Get immediate roadside assistance',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RequestHelpScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCard(
              icon: Icon(Icons.directions_car, color: Colors.blue),
              title: 'Vehicle Check',
              subtitle: 'Check your vehicle status',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VerifyVehicleScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCard(
              icon: Icon(Icons.person_add_alt_1, color: Colors.green),
              title: 'Apply to Be Partner',
              subtitle: 'Join our network of helpers',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ApplyToPartnerScreen()),
                );
              },
            ),

            const SizedBox(height: 24),

            // Recent Activity Section
            Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              title: 'Emergency Help',
              status: 'completed',
              location: 'Downtown Seattle',
              date: '2025-01-20',
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              title: 'Vehicle Check',
              status: 'pending',
              location: 'Capitol Hill',
              date: '2025-01-22',
            ),

            const SizedBox(height: 24),

            // Footer Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SettingsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Settings'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ContactUsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Contact Us'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required Icon icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String status,
    required String location,
    required String date,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'completed'
                        ? Colors.green[100]
                        : Colors.amber[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: status == 'completed'
                          ? Colors.green
                          : Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(location, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Text(date, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
