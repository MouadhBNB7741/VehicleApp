import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Signing in with Google...")));
    // TODO: Implement real Google login
  }

  Future<void> _signInWithFacebook() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signing in with Facebook...")),
    );
    // TODO: Implement real Facebook login
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final success = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).login(_emailController.text, _passwordController.text);

      if (!success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid credentials")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0079D8), // Dark blue
              Color(0xFF00B4DB), // Lighter blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo & Title
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', height: 80, width: 80),
                      const SizedBox(height: 16),
                      const Text(
                        "VEHICLEHAM",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Welcome back!",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        label: "Email",
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        label: "Password",
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        obscure: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Log In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4, // Add shadow for depth
                    ),
                    child: const Text(
                      "Log In",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // OR Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("OR", style: TextStyle(color: Colors.white)),
                    ),
                    Expanded(child: Divider(color: Colors.white)),
                  ],
                ),

                const SizedBox(height: 24),

                // Social Login Buttons
                _buildSocialButton(
                  context,
                  'Continue with Google',
                  'assets/icons/google.svg',
                  Colors.white,
                  _signInWithGoogle,
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  context,
                  'Continue with Facebook',
                  'assets/icons/facebook.svg',
                  Colors.white,
                  _signInWithFacebook,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white, size: 20),
            filled: true,
            fillColor: Colors.grey[850],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Enter your $label' : null,
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    String label,
    String svgAsset,
    Color bgColor,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white, width: 1),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: bgColor.withOpacity(0.1),
          elevation: 2, // Add subtle shadow
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(svgAsset, width: 24, height: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
