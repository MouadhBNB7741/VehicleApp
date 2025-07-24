import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:frontend/models/request.dart';
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
  List<Request> _recentRequests = [];
  bool _isLoadingRequests = true;
  String? _errorMessage;
  bool _hasFetchedInitialData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchUserRequests());
  }

  Future<void> _fetchUserRequests() async {
    if (!mounted) return;

    setState(() {
      _isLoadingRequests = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        setState(() {
          _isLoadingRequests = false;
          _errorMessage = "Please log in.";
        });
        return;
      }

      final userId = authProvider.user!.id;
      final token = await authProvider.authToken;
      if (token == null) {
        setState(() {
          _isLoadingRequests = false;
          _errorMessage = "Session error.";
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8081/request/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> requestsData = jsonDecode(response.body);
        setState(() {
          _recentRequests = requestsData
              .map((data) => Request.fromJson(data, {}))
              .toList();
          _isLoadingRequests = false;
          _hasFetchedInitialData = true;
        });
      } else if (response.statusCode == 401) {
        authProvider.logout();
        setState(() {
          _errorMessage = "Session expired. Please log in again.";
          _isLoadingRequests = false;
        });
      } else {
        setState(() {
          _errorMessage =
              "Failed to load history (Status ${response.statusCode}).";
          _isLoadingRequests = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error. Please try again.";
        _isLoadingRequests = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        toolbarHeight: 100,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade700, Colors.blue.shade500],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade800.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 28,
                  color: Colors.white,
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
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Roadside Assistance',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserRequests,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Services Section
              _buildSectionHeader('Quick Services'),
              const SizedBox(height: 8),
              _buildServicesSection(),
              const SizedBox(height: 24),

              // Recent Activity Section
              _buildSectionHeader('Recent Requests'),
              const SizedBox(height: 8),
              _buildRecentActivitySection(),
              const SizedBox(height: 24),

              // Support Section
              _buildSectionHeader('Support'),
              const SizedBox(height: 8),
              _buildSupportSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      children: [
        _buildServiceTile(
          icon: Icons.emergency,
          title: 'Request Help',
          subtitle: 'Get immediate roadside assistance',
          color: Colors.red.shade400,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RequestHelpScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _buildServiceTile(
          icon: Icons.car_repair,
          title: 'Vehicle Check',
          subtitle: 'Verify your vehicle status',
          color: Colors.blue.shade400,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VerifyVehicleScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      children: [
        _buildServiceTile(
          icon: Icons.handshake,
          title: 'Become a Partner',
          subtitle: 'Join our network of service providers',
          color: Colors.green.shade400,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ApplyToPartnerScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _buildServiceTile(
          icon: Icons.phone,
          title: 'Contact Support',
          subtitle: 'Get in touch with our team',
          color: Colors.purple.shade400,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ContactUsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      children: [
        if (_isLoadingRequests && !_hasFetchedInitialData)
          const Center(child: CircularProgressIndicator())
        else if (_errorMessage != null)
          _buildErrorState()
        else if (_recentRequests.isEmpty)
          _buildEmptyState()
        else
          ..._recentRequests.take(3).map(_buildRequestItem),
        if (_recentRequests.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextButton(
              onPressed: () {}, // TODO: Implement view all
              child: const Text(
                'VIEW ALL REQUESTS',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRequestItem(Request request) {
    final statusInfo = _getStatusInfo(request.status);
    final date = request.createdAt;
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final formattedTime =
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildServiceIcon(request.serviceType),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    request.serviceType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.status,
                    style: TextStyle(
                      color: statusInfo.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.location_on, request.locationAddress),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.calendar_today,
              '$formattedDate at $formattedTime',
            ),
            if (statusInfo.icon != null) ...[
              const SizedBox(height: 8),
              _buildStatusIndicator(statusInfo),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServiceIcon(String serviceType) {
    IconData icon;
    Color color;

    switch (serviceType.toLowerCase()) {
      case 'towing':
        icon = Icons.local_shipping;
        color = Colors.orange;
        break;
      case 'fuel delivery':
        icon = Icons.local_gas_station;
        color = Colors.blue;
        break;
      case 'jump start':
        icon = Icons.battery_charging_full;
        color = Colors.green;
        break;
      case 'tire change':
        icon = Icons.settings;
        color = Colors.red;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(({Color color, IconData? icon}) statusInfo) {
    return Row(
      children: [
        Icon(statusInfo.icon, size: 18, color: statusInfo.color),
        const SizedBox(width: 8),
        Text(
          _getStatusText(statusInfo),
          style: TextStyle(
            fontSize: 14,
            color: statusInfo.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getStatusText(({Color color, IconData? icon}) statusInfo) {
    switch (statusInfo.icon) {
      case Icons.check_circle:
        return 'Service completed successfully';
      case Icons.timer:
        return 'Helper is on the way';
      case Icons.cancel:
        return 'Request was cancelled';
      case Icons.pending:
        return 'Waiting for helper';
      default:
        return 'Status: ${statusInfo.icon != null ? 'Processing' : 'Unknown'}';
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "No Recent Requests",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Your service history will appear here after your first request",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? "Error loading requests",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.red.shade700),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchUserRequests,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  ({Color color, IconData? icon}) _getStatusInfo(String status) {
    switch (status) {
      case 'COMPLETED':
        return (color: Colors.green.shade600, icon: Icons.check_circle);
      case 'ACCEPTED':
        return (color: Colors.blue.shade600, icon: Icons.timer);
      case 'CANCELLED':
        return (color: Colors.red.shade600, icon: Icons.cancel);
      case 'PENDING':
        return (color: Colors.orange.shade600, icon: Icons.pending);
      default:
        return (color: Colors.grey.shade600, icon: null);
    }
  }
}
