import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:micro_society_app/config/app_config.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/issue_provider.dart';
import 'package:provider/provider.dart';

class TenantProfileScreen extends StatefulWidget {
  const TenantProfileScreen({super.key});

  @override
  State<TenantProfileScreen> createState() => _TenantProfileScreenState();
}

class _TenantProfileScreenState extends State<TenantProfileScreen> {
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'T';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _formatMemberSince(DateTime? date) {
    if (date == null) return '';
    return 'Member since ${DateFormat('MMMM yyyy').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.userModel;
        final issueProvider = context.watch<IssueProvider>();

        final myIssues = issueProvider.issues
            .where((i) => i.tenantId == auth.firebaseUser?.uid)
            .toList();
        final activeIssues = myIssues
            .where((i) => i.isOpen || i.isInProgress)
            .length;

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
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () =>
                    Navigator.pushNamed(context, '/owner/settings'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                _buildProfileHeader(
                  name: user?.name,
                  email: user?.email,
                  role: user?.role,
                ),
                const SizedBox(height: 28),
                _buildStatsGrid(activeIssues),
                const SizedBox(height: 24),
                _buildPersonalDetails(user),
                const SizedBox(height: 24),
                _buildFooters(user?.createdAt),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader({
    String? name,
    String? email,
    String? role,
  }) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.secondaryFixedColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.surfaceContainer,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryColor.withAlpha(30),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getInitials(name),
                  style: GoogleFonts.inter(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name ?? 'Tenant',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
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
        const SizedBox(height: 6),
        Text(
          (role ?? 'tenant').toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondaryColor,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(int activeIssues) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.warning_amber_rounded,
            iconColor: AppTheme.errorColor,
            count: activeIssues,
            label: 'Active Issues',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required int count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurfaceVariantColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails(dynamic user) {
    final details = <_DetailItem>[
      _DetailItem(
        icon: Icons.person_outline_rounded,
        label: 'Full Name',
        value: user?.name,
      ),
      _DetailItem(
        icon: Icons.email_outlined,
        label: 'Email',
        value: user?.email,
      ),
      if (user?.phone != null && user!.phone!.isNotEmpty)
        _DetailItem(
          icon: Icons.phone_outlined,
          label: 'Phone No.',
          value: user.phone,
        ),
      if (user?.societyName != null && user!.societyName!.isNotEmpty)
        _DetailItem(
          icon: Icons.apartment_rounded,
          label: 'Society / Building',
          value: user.societyName,
        ),
      if (user?.propertyAddress != null &&
          user!.propertyAddress!.isNotEmpty)
        _DetailItem(
          icon: Icons.location_on_outlined,
          label: 'Property Address',
          value: user.propertyAddress,
        ),
      const _DetailItem(
        icon: Icons.badge_outlined,
        label: 'Role',
        value: 'Tenant',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'PERSONAL DETAILS',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.onPrimaryContainerColor,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.outlineVariantColor.withAlpha(76),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < details.length; i++) ...[
                _buildDetailRow(details[i]),
                if (i < details.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(
                      height: 1,
                      color: AppTheme.outlineVariantColor.withAlpha(40),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(_DetailItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            item.icon,
            size: 20,
            color: AppTheme.onSurfaceVariantColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onPrimaryContainerColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value ?? 'Not provided',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: (item.value != null && item.value!.isNotEmpty)
                        ? AppTheme.onSurfaceColor
                        : AppTheme.outlineColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooters(DateTime? createdAt) {
    final memberSince = _formatMemberSince(createdAt);
    return Column(
      children: [
        if (memberSince.isNotEmpty)
          Text(
            memberSince,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.onPrimaryContainerColor,
            ),
          ),
        const SizedBox(height: 8),
        Text(
          '${AppConfig.appName} v${AppConfig.appVersion}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.outlineColor,
          ),
        ),
      ],
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String? value;

  const _DetailItem({
    required this.icon,
    required this.label,
    this.value,
  });
}
