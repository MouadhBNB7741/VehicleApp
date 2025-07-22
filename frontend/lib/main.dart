import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
//screens
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/partner/partner_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set window size only on desktop
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    setWindowTitle('VehicleHam App');
    setWindowMinSize(const Size(400, 812));
    setWindowMaxSize(const Size(400, 812));
    setWindowFrame(const Rect.fromLTWH(600, 100, 375, 812));
  }

  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: authProvider)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VehicleHam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    // User is authenticated — check role
    final role = auth.userRole;

    switch (role) {
      case 'USER':
        return const UserHomeScreen();
      case 'PARTNER':
        return const PartnerHomeScreen();
      case 'ADMIN':
        // ❌ Admin not allowed in mobile app
        // Log out automatically and redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Admin access not allowed on mobile."),
            ),
          );
          auth.logout(); // Auto logout admin
        });
        return const LoginScreen();

      default:
        // Unknown role — logout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          auth.logout();
        });
        return const LoginScreen();
    }
  }
}

// Placeholder until you create it
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: const Center(child: Text("Welcome!")),
    );
  }
}
