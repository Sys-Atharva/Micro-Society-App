import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';

class FlatsTab extends StatelessWidget {
  const FlatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.domain_rounded,
            size: 64,
            color: AppTheme.outlineVariantColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Flats',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.onPrimaryContainerColor,
            ),
          ),
        ],
      ),
    );
  }
}
