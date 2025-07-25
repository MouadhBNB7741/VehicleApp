import 'package:flutter/material.dart';
import 'earnings_screen.dart';
import 'contact_us_screen.dart';
import 'settings_screen.dart';
import 'current_jobs_screen.dart';

class PartnerHomeScreen extends StatefulWidget {
  const PartnerHomeScreen({super.key});

  @override
  State<PartnerHomeScreen> createState() => _PartnerHomeScreenState();
}

class _PartnerHomeScreenState extends State<PartnerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CurrentJobsScreen(),
    const EarningsScreen(),
    const ContactUsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 10,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: [
        _buildNavBarItem(
          icon: Icons.work_outlined,
          activeIcon: Icons.work,
          label: "Jobs",
          index: 0,
        ),
        _buildNavBarItem(
          icon: Icons.account_balance_wallet_outlined,
          activeIcon: Icons.account_balance_wallet,
          label: "Earnings",
          index: 1,
        ),
        _buildNavBarItem(
          icon: Icons.help_outline,
          activeIcon: Icons.help,
          label: "Help",
          index: 2,
        ),
        _buildNavBarItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: "Settings",
          index: 3,
        ),
      ],
    );
  }

  BottomNavigationBarItem _buildNavBarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          _currentIndex == index ? activeIcon : icon,
          key: ValueKey<int>(_currentIndex == index ? 1 : 0),
          size: 24,
        ),
      ),
      label: label,
    );
  }
}
