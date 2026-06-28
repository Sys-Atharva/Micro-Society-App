import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/user_provider.dart';
import 'package:micro_society_app/widgets/reusable/custom_text_field.dart';
import 'package:micro_society_app/widgets/reusable/loading_button.dart';
import 'package:provider/provider.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.userModel;
    if (user != null) {
      _bankNameController.text = user.bankDetails.bankName;
      _accountNumberController.text = user.bankDetails.accountNumber;
      _ifscController.text = user.bankDetails.ifscCode;
    }
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final uid = auth.firebaseUser?.uid;

    if (uid == null) return;

    final error = await userProvider.updateUser(
      uid: uid,
      data: {
        'bankDetails': {
          'bankName': _bankNameController.text.trim(),
          'accountNumber': _accountNumberController.text.trim(),
          'ifscCode': _ifscController.text.trim(),
        },
      },
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      setState(() => _successMessage = 'Bank details saved successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.account_balance_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Bank Account Information',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E1E2C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your bank details for rent collection',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 32),
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
              if (_successMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _successMessage!,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF059669),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              CustomTextField(
                controller: _bankNameController,
                label: 'Bank Name',
                hint: 'Enter your bank name',
                prefixIcon: const Icon(Icons.business_rounded),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter bank name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _accountNumberController,
                label: 'Account Number',
                hint: 'Enter your account number',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.numbers_rounded),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter account number';
                  }
                  if (value.length < 9) {
                    return 'Invalid account number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _ifscController,
                label: 'IFSC Code',
                hint: 'Enter IFSC code',
                prefixIcon: const Icon(Icons.code_rounded),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter IFSC code';
                  }
                  if (value.length < 8) {
                    return 'Invalid IFSC code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              LoadingButton(
                label: 'Save Bank Details',
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
