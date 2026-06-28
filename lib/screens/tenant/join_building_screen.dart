import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/widgets/reusable/custom_text_field.dart';
import 'package:micro_society_app/widgets/reusable/loading_button.dart';
import 'package:provider/provider.dart';

class JoinBuildingScreen extends StatefulWidget {
  const JoinBuildingScreen({super.key});

  @override
  State<JoinBuildingScreen> createState() => _JoinBuildingScreenState();
}

class _JoinBuildingScreenState extends State<JoinBuildingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _buildingCodeController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _buildingCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinBuilding() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isJoining = true);

    final auth = context.read<AuthProvider>();
    await auth.refreshUser();

    if (!mounted) return;

    if (auth.userModel?.approved == true &&
        auth.userModel?.buildingCode != null) {
      Navigator.pushReplacementNamed(context, '/tenant/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/tenant/waiting');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Building'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.apartment_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Join Your Building',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1E2C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the building code provided by your owner',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _buildingCodeController,
                  label: 'Building Code',
                  hint: 'Enter building code',
                  prefixIcon: const Icon(Icons.vpn_key_rounded),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a building code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  label: 'Join Building',
                  isLoading: _isJoining,
                  onPressed: _joinBuilding,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
