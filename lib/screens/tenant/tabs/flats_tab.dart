import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/models/flat_model.dart';
import 'package:micro_society_app/models/payment_request_model.dart';
import 'package:micro_society_app/models/user_model.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/flat_provider.dart';
import 'package:micro_society_app/providers/payment_provider.dart';
import 'package:micro_society_app/providers/user_provider.dart';
import 'package:micro_society_app/widgets/reusable/status_badge.dart';
import 'package:provider/provider.dart';
import 'package:upi_pro_sdk/upi_pro_sdk.dart';

class FlatsTab extends StatefulWidget {
  const FlatsTab({super.key});

  @override
  State<FlatsTab> createState() => _FlatsTabState();
}

class _FlatsTabState extends State<FlatsTab> {
  UserModel? _owner;
  bool _historyExpanded = false;
  bool _contactExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOwner();
    });
  }

  Future<void> _loadOwner() async {
    final auth = context.read<AuthProvider>();
    final buildingCode = auth.userModel?.buildingCode;
    if (buildingCode == null) return;
    final owner =
        await context.read<UserProvider>().getOwnerByBuilding(buildingCode);
    if (mounted) {
      setState(() => _owner = owner);
    }
  }

  FlatModel? _getMyFlat() {
    final auth = context.read<AuthProvider>();
    final uid = auth.firebaseUser?.uid;
    if (uid == null) return null;
    final flatProvider = context.read<FlatProvider>();
    try {
      return flatProvider.allFlats.firstWhere((f) => f.tenantId == uid);
    } catch (_) {
      return null;
    }
  }

  String _currentMonth() {
    return DateFormat('MMMM yyyy').format(DateTime.now());
  }

  String _currentMonthKey() {
    return DateFormat('yyyy-MM').format(DateTime.now());
  }

  bool _isOverdue() {
    final now = DateTime.now();
    return now.day > 5;
  }

  PaymentRequestModel? _currentMonthRequest(
      List<PaymentRequestModel> requests) {
    final monthKey = _currentMonthKey();
    try {
      return requests.firstWhere((r) => r.rentMonth == monthKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> _payRent(FlatModel flat) async {
    final upiId = _owner?.bankDetails.upiId;
    if (upiId == null || upiId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Owner has not set up UPI ID yet')),
        );
      }
      return;
    }

    final upiSdk = UpiProSdk();

    final request = UpiPaymentRequest(
      upiId: upiId,
      name: _owner?.name ?? 'Owner',
      amount: (flat.rentAmount ?? 0).toDouble(),
      note: 'Rent ${_currentMonth()} - Flat ${flat.flatNumber}',
    );

    try {
      final response = await upiSdk.payWithAppPicker(context, request);
      if (response.isSuccess || response.isPending) {
        _showConfirmationSheet(flat);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.statusMessage ??
                  'Payment failed or cancelled'),
            ),
          );
        }
      }
    } on NoUpiAppFoundException {
      if (mounted) {
        _showManualPaySheet(flat, upiId);
      }
    } catch (e) {
      if (mounted) {
        _showConfirmationSheet(flat);
      }
    }
  }

  void _showConfirmationSheet(FlatModel flat) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.outlineVariantColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 56,
              color: AppTheme.secondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Did you complete the payment?',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pay ₹${flat.rentAmount ?? 0} for ${_currentMonth()}?',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.onPrimaryContainerColor,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _markAsPaid(flat);
                },
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text("Yes, I've Paid"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Not yet',
                  style: GoogleFonts.inter(
                    color: AppTheme.onSurfaceVariantColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualPaySheet(FlatModel flat, String upiId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.outlineVariantColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.info_outline_rounded,
              size: 56,
              color: AppTheme.secondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Pay Manually',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pay ₹${flat.rentAmount ?? 0} to $upiId and confirm below.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.onPrimaryContainerColor,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: upiId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('UPI ID copied')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      upiId,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: AppTheme.secondaryColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _markAsPaid(flat);
                },
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text("I've Paid"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    color: AppTheme.onSurfaceVariantColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsPaid(FlatModel flat) async {
    final auth = context.read<AuthProvider>();
    final tenantId = auth.firebaseUser?.uid;
    final tenantName = auth.userModel?.name;
    if (tenantId == null || tenantName == null) return;

    final now = DateTime.now();
    final data = {
      'buildingCode': flat.buildingCode,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'flatId': flat.flatId,
      'flatNumber': flat.flatNumber,
      'amount': flat.rentAmount ?? 0,
      'rentMonth': _currentMonthKey(),
      'dueDate': DateTime(now.year, now.month, flat.rentDueDay),
      'status': 'pending',
      'createdAt': now,
    };

    final error = await context
        .read<PaymentProvider>()
        .createPaymentRequest(data);

    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $error')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Payment confirmation sent to owner for approval'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flat = _getMyFlat();
    final paymentProvider = context.watch<PaymentProvider>();
    final payments = paymentProvider.paymentRequests;
    final currentRequest = _currentMonthRequest(payments);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: flat == null
          ? _buildEmptyFlat()
          : Column(
              children: [
                _buildHeroCard(flat),
                const SizedBox(height: 16),
                _buildRentCard(flat, currentRequest),
                const SizedBox(height: 16),
                _buildOwnerContact(),
                const SizedBox(height: 16),
                _buildPaymentHistory(payments),
              ],
            ),
    );
  }

  Widget _buildEmptyFlat() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            const Icon(
              Icons.home_work_outlined,
              size: 64,
              color: AppTheme.outlineVariantColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No flat assigned yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contact your owner to get assigned\nto a flat in your building.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.onPrimaryContainerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(FlatModel flat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainerColor.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.secondaryContainerColor.withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.meeting_room_rounded,
              color: AppTheme.secondaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flat ${flat.flatNumber}',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (flat.buildingWing != null &&
                        flat.buildingWing!.isNotEmpty)
                      'Wing ${flat.buildingWing}',
                    if (flat.flatFloor != null &&
                        flat.flatFloor!.isNotEmpty)
                      'Floor ${flat.flatFloor}',
                    'Building: ${flat.buildingCode}',
                  ].join(' \u2022 '),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.onPrimaryContainerColor,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(status: flat.status),
        ],
      ),
    );
  }

  Widget _buildRentCard(FlatModel flat, PaymentRequestModel? current) {
    final rentAmount = flat.rentAmount;
    final status = current?.status ?? 'unpaid';
    final isOverdue = _isOverdue() && status == 'unpaid';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineVariantColor.withAlpha(76),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryFixedColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.secondaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rent for ${_currentMonth()}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Due: ${flat.rentDueDay}th of every month',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.onPrimaryContainerColor,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                  status: isOverdue ? 'overdue' : status),
            ],
          ),
          if (rentAmount != null) ...[
            const SizedBox(height: 20),
            Center(
              child: Text(
                '₹$rentAmount',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Rent not configured',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.onPrimaryContainerColor,
                ),
              ),
            ),
          ],
          if (status == 'unpaid' || current == null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    rentAmount != null ? () => _payRent(flat) : null,
                icon: const Icon(Icons.payments_rounded, size: 18),
                label: Text(
                    'Pay ₹${rentAmount ?? 0} via UPI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You'll be redirected to your UPI app. After paying, confirm here so your owner can verify.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.onPrimaryContainerColor,
              ),
            ),
          ],
          if (status == 'pending') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_empty_rounded,
                      size: 18,
                      color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Waiting for owner approval',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFFD97706),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (status == 'approved') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 18,
                      color: Color(0xFF059669)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Payment approved by owner',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF059669),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (status == 'declined') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFBA1A1A).withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cancel_rounded,
                      size: 18, color: Color(0xFFBA1A1A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment declined',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFFBA1A1A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (current?.ownerNote != null &&
                            current!.ownerNote!.isNotEmpty)
                          Text(
                            current.ownerNote!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFFBA1A1A),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(List<PaymentRequestModel> payments) {
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
          GestureDetector(
            onTap: () =>
                setState(() => _historyExpanded = !_historyExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded,
                      size: 20,
                      color: AppTheme.onSurfaceVariantColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Payment History (${payments.length})',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _historyExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppTheme.outlineVariantColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _historyExpanded
                ? payments.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          'No payment history yet',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.onPrimaryContainerColor,
                          ),
                        ),
                      )
                    : Column(
                        children: payments.map((p) {
                          final isDeclined = p.status == 'declined';
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border(
                                left: BorderSide(
                                  color: isDeclined
                                      ? AppTheme.errorColor
                                      : AppTheme.outlineVariantColor,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryFixedColor
                                        .withAlpha(100),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_rounded,
                                    color: AppTheme.secondaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatMonth(p.rentMonth),
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.onSurfaceColor,
                                        ),
                                      ),
                                      Text(
                                        '₹${p.amount}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppTheme
                                              .onPrimaryContainerColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: p.status),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerContact() {
    if (_owner == null) return const SizedBox.shrink();

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
          GestureDetector(
            onTap: () =>
                setState(() => _contactExpanded = !_contactExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.contact_phone_rounded,
                      size: 20,
                      color: AppTheme.onSurfaceVariantColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Owner Contact',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _contactExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppTheme.outlineVariantColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _contactExpanded
                ? Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        _contactRow(
                          Icons.person_outline_rounded,
                          'Name',
                          _owner!.name,
                        ),
                        const SizedBox(height: 8),
                        if (_owner!.phone != null &&
                            _owner!.phone!.isNotEmpty)
                          _contactRow(
                            Icons.phone_outlined,
                            'Phone',
                            _owner!.phone!,
                          ),
                        if (_owner!.phone != null &&
                            _owner!.phone!.isNotEmpty)
                          const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.payments_rounded,
                              size: 18,
                              color: AppTheme.onSurfaceVariantColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'UPI ID',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme
                                          .onPrimaryContainerColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _owner!.bankDetails.upiId
                                            .isNotEmpty
                                        ? _owner!.bankDetails.upiId
                                        : 'Not set',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _owner!
                                              .bankDetails.upiId
                                              .isNotEmpty
                                          ? AppTheme.secondaryColor
                                          : AppTheme.outlineColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_owner!.bankDetails.upiId
                                .isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text: _owner!
                                          .bankDetails.upiId));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('UPI ID copied')),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme
                                        .secondaryFixedColor,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.copy_rounded,
                                    size: 16,
                                    color:
                                        AppTheme.secondaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18,
            color: AppTheme.onSurfaceVariantColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onPrimaryContainerColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatMonth(String monthKey) {
    try {
      final parts = monthKey.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat('MMMM yyyy').format(date);
    } catch (_) {
      return monthKey;
    }
  }
}
