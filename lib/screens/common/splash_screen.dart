import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.status == AuthStatus.authenticated) {
      final userModel = authProvider.userModel;
      if (userModel == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      if (userModel.role == 'owner') {
        Navigator.pushReplacementNamed(context, '/owner/dashboard');
      } else if (userModel.role == 'tenant') {
        if (!userModel.approved || userModel.buildingCode == null) {
          Navigator.pushReplacementNamed(context, '/tenant/waiting');
        } else {
          Navigator.pushReplacementNamed(context, '/tenant/dashboard');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/role-selection');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apartment_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Micro Society',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1E2C),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
