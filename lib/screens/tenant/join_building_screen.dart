import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/models/flat_model.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/flat_provider.dart';
import 'package:micro_society_app/services/firestore_service.dart';
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
  final _firestoreService = FirestoreService();

  bool _isVerifying = false;
  bool _isSubmitting = false;
  bool _buildingVerified = false;
  String? _verifyError;

  List<FlatModel> _vacantFlats = [];
  String? _selectedFlatId;

  @override
  void dispose() {
    _buildingCodeController.dispose();
    super.dispose();
  }

  Future<void> _verifyBuildingCode() async {
    final code = _buildingCodeController.text.trim();
    if (code.isEmpty) {
      setState(() => _verifyError = 'Please enter a building code');
      return;
    }

    setState(() {
      _isVerifying = true;
      _verifyError = null;
      _buildingVerified = false;
      _vacantFlats = [];
      _selectedFlatId = null;
    });

    try {
      final allFlats = await _firestoreService.getDocuments(
        collection: 'flats',
        field: 'buildingCode',
        isEqualTo: code,
      );

      if (!mounted) return;

      if (allFlats.isEmpty) {
        setState(() {
          _verifyError = 'Building code not found. Please check and try again.';
          _isVerifying = false;
        });
        return;
      }

      final vacant = allFlats
          .map((d) => FlatModel.fromMap(d, d['id'] as String))
          .where((f) => f.status == 'vacant')
          .toList();

      if (vacant.isEmpty) {
        setState(() {
          _verifyError = 'No vacant flats available in this building.';
          _isVerifying = false;
        });
        return;
      }

      setState(() {
        _vacantFlats = vacant;
        _buildingVerified = true;
        _isVerifying = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _verifyError = 'Unable to verify building code. Please try again.';
        _isVerifying = false;
      });
    }
  }

  Future<void> _requestAccess() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFlatId == null) {
      setState(() => _verifyError = 'Please select a flat');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _verifyError = null;
    });

    final auth = context.read<AuthProvider>();
    final flatProvider = context.read<FlatProvider>();
    final uid = auth.firebaseUser?.uid;
    if (uid == null) return;

    try {
      await _firestoreService.updateDocument(
        collection: 'users',
        docId: uid,
        data: {
          'buildingCode': _buildingCodeController.text.trim(),
          'flatId': _selectedFlatId,
        },
      );

      if (!mounted) return;

      await flatProvider.requestFlat(
            flatId: _selectedFlatId!,
            tenantId: uid,
          );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/tenant/waiting');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _verifyError = 'Failed to submit request. Please try again.';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: const Color(0xFFF8F9FF),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4648D4).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.hub_rounded,
                            size: 20,
                            color: Color(0xFF4648D4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Micro-Society',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0B1C30),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.help_outline_rounded,
                            color: Color(0xFF45464D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Join Your Building',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0B1C30),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter the details provided by your building manager.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: const Color(0xFF45464D),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFC6C6CD).withAlpha(76),
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
                                  if (_verifyError != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFBA1A1A).withAlpha(15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _verifyError!,
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFFBA1A1A),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  CustomTextField(
                                    controller: _buildingCodeController,
                                    label: 'Unique Building Code',
                                    hint: 'e.g. MS-8829-QX',
                                    prefixIcon: const Icon(Icons.domain_verification_rounded),
                                    textCapitalization: TextCapitalization.characters,
                                    suffixIcon: _buildingVerified
                                        ? const Icon(
                                            Icons.check_circle_rounded,
                                            color: Color(0xFF059669),
                                          )
                                        : _isVerifying
                                            ? const Padding(
                                                padding: EdgeInsets.all(12),
                                                child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Color(0xFF4648D4),
                                                  ),
                                                ),
                                              )
                                            : IconButton(
                                                onPressed: _verifyBuildingCode,
                                                icon: const Icon(
                                                  Icons.search_rounded,
                                                  color: Color(0xFF4648D4),
                                                ),
                                              ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter a building code';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (_buildingVerified && _vacantFlats.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedFlatId,
                                      decoration: InputDecoration(
                                        labelText: 'Select Flat',
                                        prefixIcon: const Icon(Icons.meeting_room_rounded),
                                        suffixIcon: const Icon(Icons.expand_more_rounded),
                                        filled: true,
                                        fillColor: const Color(0xFFEFF4FF),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFC6C6CD)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFC6C6CD)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFF4648D4), width: 2),
                                        ),
                                      ),
                                      items: _vacantFlats.map((flat) {
                                        return DropdownMenuItem(
                                          value: flat.flatId,
                                          child: Text(
                                            '${flat.flatNumber} - Vacant',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              color: const Color(0xFF0B1C30),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() => _selectedFlatId = value);
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF4FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.info_outline_rounded,
                                          size: 18,
                                          color: Color(0xFF4648D4),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Access requests are reviewed by the building administrator. You will receive a notification once your residency is verified.',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: const Color(0xFF45464D),
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  LoadingButton(
                                    label: 'Request Access',
                                    isLoading: _isSubmitting,
                                    onPressed: _buildingVerified ? _requestAccess : null,
                                    trailingIcon: const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Row(
                              children: [
                                _TrustBadge(
                                  icon: Icons.enhanced_encryption_rounded,
                                  label: 'Encrypted',
                                ),
                                SizedBox(width: 12),
                                _TrustBadge(
                                  icon: Icons.verified_user_rounded,
                                  label: 'Verified',
                                ),
                                SizedBox(width: 12),
                                _TrustBadge(
                                  icon: Icons.gpp_good_rounded,
                                  label: 'Secure',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have a code? ",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF45464D),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Contact Property Management',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4648D4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
