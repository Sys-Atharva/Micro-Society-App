import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class TenantDashboard extends StatelessWidget {
  const TenantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Society'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${auth.userModel?.name ?? 'Tenant'}',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1E2C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Flat: ${auth.userModel?.flatId ?? 'Not assigned'}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 32),
                _TenantGrid(
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        Navigator.pushNamed(context, '/tenant/issues');
                        break;
                      case 1:
                        Navigator.pushNamed(context, '/tenant/payments');
                        break;
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TenantGrid extends StatelessWidget {
  final void Function(int index) onTap;

  const _TenantGrid({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _TenantItem(
        icon: Icons.report_problem_rounded,
        title: 'Report Issue',
        subtitle: 'Report a building issue',
        color: Color(0xFFD97706),
      ),
      const _TenantItem(
        icon: Icons.payment_rounded,
        title: 'Payments',
        subtitle: 'View payment history',
        color: Color(0xFF059669),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => onTap(index),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E1E2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TenantItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _TenantItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
