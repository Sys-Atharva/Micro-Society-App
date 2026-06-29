import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/widgets/reusable/loading_button.dart';
import 'package:provider/provider.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedRole;
  String? _errorMessage;
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonAnimation = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  void _selectRole(String role) {
    HapticFeedback.mediumImpact();
    setState(() => _selectedRole = role);
    if (_selectedRole != null) {
      _buttonController.forward(from: 0);
    }
  }

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
    } else {
      if (_selectedRole == 'owner') {
        Navigator.pushReplacementNamed(
          context,
          '/owner/bank-details',
          arguments: {'onboarding': true},
        );
      } else {
        Navigator.pushReplacementNamed(context, '/tenant/join');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FF),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 200,
              left: -200,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF4648D4).withAlpha(20),
                      const Color(0xFF4648D4).withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4648D4).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.hub_rounded,
                            size: 20,
                            color: Color(0xFF4648D4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Micro-Society',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0B1C30),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          'Who are you?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0B1C30),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose your role to get started.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: const Color(0xFF45464D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_errorMessage != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBA1A1A).withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(
                            color: const Color(0xFFBA1A1A),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _RoleCard(
                            icon: Icons.domain_rounded,
                            title: 'Owner',
                            description:
                                'Manage your properties, handle maintenance requests, and oversee community developments efficiently',
                            iconBgColor: const Color(0xFFE1E0FF),
                            isSelected: _selectedRole == 'owner',
                            onTap: () => _selectRole('owner'),
                          ),
                          const SizedBox(height: 16),
                          _RoleCard(
                            icon: Icons.house_rounded,
                            title: 'Tenant',
                            description:
                                'Report issues, browse local events, pay rent, and connect with your neighbors',
                            iconBgColor: const Color(0xFFE5EEFF),
                            isSelected: _selectedRole == 'tenant',
                            onTap: () => _selectRole('tenant'),
                          ),
                          const SizedBox(height: 24),
                          const Row(
                            children: [
                              _TrustBadge(
                                icon: Icons.verified_user_rounded,
                                label: 'Verified\nIdentities',
                              ),
                              SizedBox(width: 12),
                              _TrustBadge(
                                icon: Icons.lock_rounded,
                                label: 'Secure Data\nEncryption',
                              ),
                              SizedBox(width: 12),
                              _TrustBadge(
                                icon: Icons.bolt_rounded,
                                label: 'Real-time\nCoordination',
                              ),
                            ],
                          ),
                          if (_selectedRole != null) ...[
                            const SizedBox(height: 16),
                            FadeTransition(
                              opacity: _buttonAnimation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.2),
                                  end: Offset.zero,
                                ).animate(_buttonAnimation),
                                child: Consumer<AuthProvider>(
                                  builder: (context, auth, _) {
                                    return LoadingButton(
                                      label: 'Continue to Dashboard',
                                      isLoading:
                                          auth.status == AuthStatus.loading,
                                      onPressed: _completeRegistration,
                                      trailingIcon: const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconBgColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconBgColor,
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
          color: isSelected ? Colors.white : Colors.white.withAlpha(178),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF4648D4) : const Color(0xFFE5EEFF),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4648D4).withAlpha(30),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: const Color(0xFF4648D4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0B1C30),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF45464D),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select $title Access',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4648D4),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Color(0xFF4648D4),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE1E0FF).withAlpha(50),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF4648D4),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4648D4),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
