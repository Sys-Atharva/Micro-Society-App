import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/models/user_model.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  UserModel? _owner;
  bool _isLoadingOwner = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOwnerDetails();
    });
  }

  Future<void> _loadOwnerDetails() async {
    final auth = context.read<AuthProvider>();
    final buildingCode = auth.userModel?.buildingCode;
    if (buildingCode == null) return;

    setState(() => _isLoadingOwner = true);

    final owner = await context.read<UserProvider>().getOwnerByBuilding(buildingCode);

    if (mounted) {
      setState(() {
        _owner = owner;
        _isLoadingOwner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.payment_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Payment History',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E1E2C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your payment records will appear here.\n'
                'This feature is coming soon.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoadingOwner)
                const CircularProgressIndicator()
              else if (_owner != null &&
                  _owner!.bankDetails.bankName.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Owner's Bank Details",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E1E2C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bank: ${_owner!.bankDetails.bankName}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        'Account: ${_owner!.bankDetails.accountNumber}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        'IFSC: ${_owner!.bankDetails.ifscCode}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
