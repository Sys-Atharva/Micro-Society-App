import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            color: const Color(0xFFF8F9FF),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(204),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B1C30).withAlpha(8),
                          blurRadius: 16,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Micro-Society',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0B1C30),
                                ),
                              ),
                              Text(
                                'Owner Dashboard',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF7C839B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded,
                              color: Color(0xFF45464D)),
                          onPressed: () async {
                            await auth.logout();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context, '/login');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${auth.userModel?.name ?? 'Owner'}',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0B1C30),
                              letterSpacing: -0.01,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Building: ${auth.userModel?.buildingCode ?? 'Not set'}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF7C839B),
                            ),
                          ),
                          const SizedBox(height: 24),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            children: [
                              _DashboardCard(
                                icon: Icons.meeting_room_rounded,
                                title: 'Manage Flats',
                                subtitle: 'View and manage your flats',
                                color: const Color(0xFF4648D4),
                                onTap: () => Navigator.pushNamed(
                                    context, '/owner/flats'),
                              ),
                              _DashboardCard(
                                icon: Icons.report_problem_rounded,
                                title: 'Issues',
                                subtitle: 'Track reported issues',
                                color: const Color(0xFFD97706),
                                onTap: () => Navigator.pushNamed(
                                    context, '/owner/issues'),
                              ),
                              _DashboardCard(
                                icon: Icons.event_rounded,
                                title: 'Events',
                                subtitle: 'Organize building events',
                                color: const Color(0xFF059669),
                                onTap: () => Navigator.pushNamed(
                                    context, '/owner/events'),
                              ),
                              _DashboardCard(
                                icon: Icons.account_balance_rounded,
                                title: 'Bank Details',
                                subtitle: 'Manage your bank info',
                                color: const Color(0xFF45464D),
                                onTap: () => Navigator.pushNamed(
                                    context, '/owner/bank-details'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFC6C6CD).withAlpha(76),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B1C30).withAlpha(8),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0B1C30),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF7C839B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
