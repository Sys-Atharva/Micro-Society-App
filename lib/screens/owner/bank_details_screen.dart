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
  String _accountType = 'Savings';
  bool _isSaving = false;
  bool _confirmationChecked = false;
  String? _errorMessage;
  String? _successMessage;

  bool get _isOnboarding {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['onboarding'] == true;
  }

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
    if (!_confirmationChecked) {
      setState(() =>
          _errorMessage = 'Please confirm the verification checkbox');
      return;
    }

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
          'ifscCode': _ifscController.text.trim().toUpperCase(),
          'accountType': _accountType,
        },
      },
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      if (_isOnboarding) {
        Navigator.pushReplacementNamed(context, '/owner/dashboard');
      } else {
        setState(() => _successMessage = 'Bank details saved successfully');
      }
    }
  }

  void _skipForLater() {
    Navigator.pushReplacementNamed(context, '/owner/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isOnboarding
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _skipForLater,
              )
            : null,
        title: const Text('Payment Setup'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE1E0FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.security_rounded,
                  size: 14,
                  color: Color(0xFF4648D4),
                ),
                const SizedBox(width: 4),
                Text(
                  'Secure Connection',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4648D4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF8F9FF),
        child: Column(
          children: [
            if (_isOnboarding)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Step 2 of 3',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF45464D),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Onboarding',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF7C839B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: 0.66,
                        backgroundColor:
                            const Color(0xFFE1E0FF).withAlpha(127),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4648D4),
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1E0FF).withAlpha(76),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4648D4).withAlpha(25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6063EE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.account_balance_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Verify Bank Details',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0B1C30),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Please provide your settlement account details for society fund transfers.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF45464D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                const Color(0xFFC6C6CD).withAlpha(76),
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBA1A1A)
                                      .withAlpha(15),
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
                              const SizedBox(height: 16),
                            ],
                            if (_successMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4648D4)
                                      .withAlpha(15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _successMessage!,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF4648D4),
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
                              prefixIcon: const Icon(
                                  Icons.business_rounded),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
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
                              prefixIcon:
                                  const Icon(Icons.credit_card_rounded),
                              helperText:
                                  'We encrypt your sensitive data with AES-256 standards',
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Please enter account number';
                                }
                                if (value.length < 9) {
                                  return 'Invalid account number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _ifscController,
                                    label: 'IFSC Code',
                                    hint: 'ABCD0123456',
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    prefixIcon:
                                        const Icon(Icons.code_rounded),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter IFSC code';
                                      }
                                      if (value.length < 8) {
                                        return 'Invalid IFSC code';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _accountType,
                                    decoration: InputDecoration(
                                      labelText: 'Account Type',
                                      filled: true,
                                      fillColor:
                                          const Color(0xFFEFF4FF),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color:
                                                Color(0xFFC6C6CD)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color:
                                                Color(0xFFC6C6CD)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF4648D4),
                                            width: 2),
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'Savings',
                                          child: Text('Savings')),
                                      DropdownMenuItem(
                                          value: 'Current',
                                          child: Text('Current')),
                                      DropdownMenuItem(
                                          value: 'Business',
                                          child: Text('Business')),
                                    ],
                                    onChanged: (value) {
                                      setState(() =>
                                          _accountType = value ?? 'Savings');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Checkbox(
                                  value: _confirmationChecked,
                                  onChanged: (value) {
                                    setState(() => _confirmationChecked =
                                        value ?? false);
                                  },
                                  activeColor: const Color(0xFF4648D4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'I confirm this account will receive penny-drop verification transaction',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color:
                                          const Color(0xFF45464D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          _AssuranceBadge(
                            icon: Icons.verified_user_rounded,
                            label: 'PCI-DSS\nCompliant',
                          ),
                          SizedBox(width: 12),
                          _AssuranceBadge(
                            icon: Icons.lock_rounded,
                            label: 'SSL\nEncrypted',
                          ),
                          SizedBox(width: 12),
                          _AssuranceBadge(
                            icon: Icons.visibility_off_rounded,
                            label: 'Private\nData',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B1C30).withAlpha(8),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (_isOnboarding)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _skipForLater,
                          child: const Text('Save for later'),
                        ),
                      ),
                    if (_isOnboarding) const SizedBox(width: 12),
                    Expanded(
                      flex: _isOnboarding ? 2 : 1,
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return LoadingButton(
                            label: 'Save & Continue',
                            isLoading: _isSaving,
                            onPressed: _save,
                            trailingIcon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssuranceBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AssuranceBadge({
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
