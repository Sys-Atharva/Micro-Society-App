import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'O';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.userModel;
        return Scaffold(
          backgroundColor: AppTheme.surfaceColor,
          appBar: AppBar(
            backgroundColor: Colors.white.withAlpha(204),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Profile',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceColor,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildProfileHeader(user?.name, user?.email),
                const SizedBox(height: 32),
                _buildInfoCard(context, user),
                const SizedBox(height: 24),
                _buildMenuList(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(String? name, String? email) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.secondaryFixedColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.secondaryColor.withAlpha(60),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              _getInitials(name),
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.secondaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name ?? 'Owner',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email ?? '',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.onPrimaryContainerColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.secondaryFixedColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'OWNER',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.secondaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineVariantColor.withAlpha(76),
        ),
      ),
      child: Row(
        children: [
          _InfoItem(
            icon: Icons.domain_rounded,
            label: 'Building Code',
            value: user?.buildingCode ?? 'Not set',
            trailing: user?.buildingCode != null
                ? GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: user.buildingCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Building code copied!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryFixedColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  )
                : null,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.outlineVariantColor.withAlpha(60),
          ),
          _InfoItem(
            icon: Icons.verified_rounded,
            label: 'Status',
            value: user?.approved == true ? 'Verified' : 'Pending',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineVariantColor.withAlpha(76),
        ),
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.edit_rounded,
            label: 'Edit Profile',
            onTap: () {},
          ),
          _buildDivider(),
          _MenuItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            onTap: () {},
          ),
          _buildDivider(),
          _MenuItem(
            icon: Icons.privacy_tip_rounded,
            label: 'Privacy Policy',
            onTap: () {},
          ),
          _buildDivider(),
          _MenuItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            isDestructive: true,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: AppTheme.outlineVariantColor.withAlpha(40),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppTheme.secondaryColor),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.onPrimaryContainerColor,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFBA1A1A) : AppTheme.onSurfaceColor;
    final iconColor = isDestructive ? const Color(0xFFBA1A1A) : AppTheme.onSurfaceVariantColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDestructive
                    ? const Color(0xFFBA1A1A).withAlpha(15)
                    : AppTheme.secondaryFixedColor.withAlpha(100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppTheme.outlineVariantColor,
            ),
          ],
        ),
      ),
    );
  }
}
