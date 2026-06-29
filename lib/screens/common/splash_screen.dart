import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addListener(() {
      setState(() => _progress = _progressAnimation.value);
    });
    _controller.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1500));
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
        if (userModel.buildingCode == null) {
          Navigator.pushReplacementNamed(context, '/tenant/join');
        } else if (!userModel.approved) {
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B1C30),
              Color(0xFF131B2E),
              Color(0xFF07006C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withAlpha(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4648D4).withAlpha(51),
                      blurRadius: 64,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.domain_rounded,
                  size: 48,
                  color: Color(0xFF4648D4),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Micro-Society',
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.02,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'CONNECTED LIVING',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4648D4),
                  letterSpacing: 0.1,
                ),
              ),
              const Spacer(flex: 3),
              Column(
                children: [
                  SizedBox(
                    width: 192,
                    height: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white.withAlpha(25),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4648D4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Initializing secure environment...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withAlpha(153),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
