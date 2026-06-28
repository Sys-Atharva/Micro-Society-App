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
          appBar: AppBar(
            title: const Text('Owner Dashboard'),
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
                  'Welcome, ${auth.userModel?.name ?? 'Owner'}',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1E2C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Building: ${auth.userModel?.buildingCode ?? 'Not set'}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 32),
                _DashboardGrid(
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        Navigator.pushNamed(context, '/owner/flats');
                        break;
                      case 1:
                        Navigator.pushNamed(context, '/owner/issues');
                        break;
                      case 2:
                        Navigator.pushNamed(context, '/owner/events');
                        break;
                      case 3:
                        Navigator.pushNamed(context, '/owner/bank-details');
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

class _DashboardGrid extends StatelessWidget {
  final void Function(int index) onTap;

  const _DashboardGrid({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _DashboardItem(
        icon: Icons.meeting_room_rounded,
        title: 'Manage Flats',
        subtitle: 'View and manage your flats',
        color: Color(0xFF4F46E5),
      ),
      const _DashboardItem(
        icon: Icons.report_problem_rounded,
        title: 'Issues',
        subtitle: 'Track reported issues',
        color: Color(0xFFD97706),
      ),
      const _DashboardItem(
        icon: Icons.event_rounded,
        title: 'Events',
        subtitle: 'Organize building events',
        color: Color(0xFF059669),
      ),
      const _DashboardItem(
        icon: Icons.account_balance_rounded,
        title: 'Bank Details',
        subtitle: 'Manage your bank info',
        color: Color(0xFF6B7280),
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

class _DashboardItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _DashboardItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
