import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/widgets/reusable/loading_button.dart';
import 'package:provider/provider.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  String? _errorMessage;

  Future<void> _completeRegistration() async {
    if (_selectedRole == null) {
      setState(() => _errorMessage = 'Please select a role');
      return;
    }

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) return;

    setState(() => _errorMessage = null);

    final authProvider = context.read<AuthProvider>();
    final error = await authProvider.register(
      email: args['email'] as String,
      password: args['password'] as String,
      name: args['name'] as String,
      role: _selectedRole!,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() => _errorMessage = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Role'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'How will you use Micro Society?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1E2C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your role to personalize your experience',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 40),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFDC2626),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _RoleCard(
                icon: Icons.business_rounded,
                title: 'Owner',
                description: 'Manage your building, flats, and residents',
                isSelected: _selectedRole == 'owner',
                onTap: () => setState(() => _selectedRole = 'owner'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.person_rounded,
                title: 'Tenant',
                description: 'Connect with your building community',
                isSelected: _selectedRole == 'tenant',
                onTap: () => setState(() => _selectedRole = 'tenant'),
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return LoadingButton(
                    label: 'Complete Registration',
                    isLoading: auth.status == AuthStatus.loading,
                    onPressed: _completeRegistration,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5).withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFF1E1E2C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
