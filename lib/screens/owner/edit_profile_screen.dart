import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/user_provider.dart';
import 'package:micro_society_app/widgets/reusable/loading_button.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _societyNameController;
  late TextEditingController _propertyAddressController;
  late TextEditingController _upiIdController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().userModel;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _societyNameController =
        TextEditingController(text: user?.societyName ?? '');
    _propertyAddressController =
        TextEditingController(text: user?.propertyAddress ?? '');
    _upiIdController =
        TextEditingController(text: user?.bankDetails.upiId ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _societyNameController.dispose();
    _propertyAddressController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'O';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();
    final auth = context.read<AuthProvider>();
    final uid = auth.firebaseUser?.uid;

    if (uid != null) {
      final data = <String, dynamic>{
        'name': name,
        'phone': _phoneController.text.trim(),
        'societyName': _societyNameController.text.trim(),
        'propertyAddress': _propertyAddressController.text.trim(),
        'bankDetails': {
          'upiId': _upiIdController.text.trim(),
        },
      };
      await userProvider.updateUser(uid: uid, data: data);
      await auth.refreshUser();
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white.withAlpha(204),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildAvatar(user?.name),
            const SizedBox(height: 28),
            _buildSectionHeader('Personal Information'),
            const SizedBox(height: 12),
            _buildNameField(),
            const SizedBox(height: 14),
            _buildEmailField(),
            const SizedBox(height: 14),
            _buildPhoneField(),
            const SizedBox(height: 28),
            _buildSectionHeader('Payment'),
            const SizedBox(height: 12),
            _buildUpiIdField(),
            const SizedBox(height: 28),
            _buildSectionHeader('Property Details'),
            const SizedBox(height: 12),
            _buildSocietyNameField(),
            const SizedBox(height: 14),
            _buildPropertyAddressField(),
            const SizedBox(height: 32),
            LoadingButton(
              onPressed: _saveProfile,
              isLoading: _isLoading,
              label: 'Save Changes',
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.onPrimaryContainerColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAvatar(String? name) {
    return Container(
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
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppTheme.secondaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return _buildTextField(
      label: 'Full Name',
      controller: _nameController,
      hintText: 'Enter your name',
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          readOnly: true,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppTheme.onPrimaryContainerColor,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.surfaceContainerLow.withAlpha(128),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: const Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: AppTheme.onPrimaryContainerColor,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Email cannot be changed',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.onPrimaryContainerColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      label: 'Phone Number',
      controller: _phoneController,
      hintText: 'Enter your phone number',
      keyboardType: TextInputType.phone,
      optional: true,
    );
  }

  Widget _buildSocietyNameField() {
    return _buildTextField(
      label: 'Society / Building Name',
      controller: _societyNameController,
      hintText: 'Enter society or building name',
      optional: true,
    );
  }

  Widget _buildPropertyAddressField() {
    return _buildTextField(
      label: 'Property Address',
      controller: _propertyAddressController,
      hintText: 'Enter property address',
      optional: true,
    );
  }

  Widget _buildUpiIdField() {
    return _buildTextField(
      label: 'UPI ID / VPA',
      controller: _upiIdController,
      hintText: 'owner@paytm',
      optional: true,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceColor,
              ),
            ),
            if (optional) ...[
              const SizedBox(width: 6),
              Text(
                '(Optional)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.onPrimaryContainerColor,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppTheme.onSurfaceColor,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              color: AppTheme.onPrimaryContainerColor,
            ),
            filled: true,
            fillColor: AppTheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.secondaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
