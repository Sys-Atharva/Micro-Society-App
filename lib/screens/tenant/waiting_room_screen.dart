import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class WaitingRoomScreen extends StatelessWidget {
  const WaitingRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approval'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_empty_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Waiting for Approval',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1E2C),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your account is pending approval from the building owner. '
                'You will be notified once your account is activated.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return TextButton(
                    onPressed: () async {
                      await auth.refreshUser();
                      if (context.mounted &&
                          auth.userModel?.approved == true &&
                          auth.userModel?.buildingCode != null) {
                        Navigator.pushReplacementNamed(
                            context, '/tenant/dashboard');
                      }
                    },
                    child: const Text('Check Status'),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
