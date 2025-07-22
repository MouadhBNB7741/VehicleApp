import 'package:flutter/material.dart';
import 'verify_vehicle_screen.dart';
import 'request_help_screen.dart';
import 'apply_to_partner_screen.dart';
import 'contact_us_screen.dart';
import 'settings_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const RequestHelpScreen(),
    const VerifyVehicleScreen(),
    const ApplyToPartnerScreen(),
    const ContactUsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "Request"),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Verify",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center),
            label: "Apply",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: "Contact"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
