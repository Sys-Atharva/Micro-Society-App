import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white.withAlpha(204),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy & Security',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              icon: Icons.shield_rounded,
              title: 'Data Protection',
              description:
                  'Your personal information is encrypted and stored securely. We never share your data with third parties without your explicit consent.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.lock_rounded,
              title: 'Account Security',
              description:
                  'Your account is protected by Firebase Authentication. All data transmissions are encrypted using industry-standard TLS protocols.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.visibility_rounded,
              title: 'Privacy Policy',
              description:
                  'We collect only the information necessary to provide our services. Your building code, flat details, and issue reports are visible only to members of your property.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.delete_outline_rounded,
              title: 'Data Deletion',
              description:
                  'To request deletion of your account and all associated data, please contact support through the app.',
            ),
            const SizedBox(height: 32),
            Text(
              'Last updated: January 2025',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.onPrimaryContainerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.outlineVariantColor.withAlpha(76),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.secondaryFixedColor.withAlpha(100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.secondaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.5,
                    color: AppTheme.onSurfaceVariantColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
