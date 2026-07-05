import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/models/flat_model.dart';
import 'package:micro_society_app/models/payment_request_model.dart';
import 'package:micro_society_app/providers/flat_provider.dart';
import 'package:micro_society_app/providers/payment_provider.dart';
import 'package:micro_society_app/providers/user_provider.dart';
import 'package:micro_society_app/widgets/reusable/status_badge.dart';
import 'package:provider/provider.dart';

class FlatDetailScreen extends StatefulWidget {
  final String flatId;

  const FlatDetailScreen({super.key, required this.flatId});

  @override
  State<FlatDetailScreen> createState() => _FlatDetailScreenState();
}

class _FlatDetailScreenState extends State<FlatDetailScreen> {
  late TextEditingController _wingController;
  late TextEditingController _floorController;
  late TextEditingController _rentController;
  String? _tenantName;
  DateTime? _rentStartDate;

  @override
  void initState() {
    super.initState();
    _loadFlatDetails();
    _wingController = TextEditingController();
    _floorController = TextEditingController();
    _rentController = TextEditingController();
  }

  void _loadFlatDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final flat = _getFlat();
      if (flat != null) {
        _wingController.text = flat.buildingWing ?? '';
        _floorController.text = flat.flatFloor ?? '';
        _rentController.text =
            flat.rentAmount != null ? flat.rentAmount.toString() : '';
        _rentStartDate = flat.rentStartDate;
        if (flat.tenantId != null) {
          _loadTenantName(flat.tenantId!);
        }
      }
    });
  }

  Future<void> _loadTenantName(String tenantId) async {
    final tenant = await context.read<UserProvider>().getUserById(tenantId);
    if (mounted) {
      setState(() {
        _tenantName = tenant?.name;
      });
    }
  }

  FlatModel? _getFlat() {
    final flatProvider = context.read<FlatProvider>();
    final flats = flatProvider.allFlats;
    try {
      return flats.firstWhere((f) => f.flatId == widget.flatId);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _wingController.dispose();
    _floorController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final flatProvider = context.read<FlatProvider>();
    final data = <String, dynamic>{
      'buildingWing': _wingController.text.trim().isEmpty
          ? null
          : _wingController.text.trim(),
      'flatFloor': _floorController.text.trim().isEmpty
          ? null
          : _floorController.text.trim(),
      'rentAmount': _rentController.text.trim().isNotEmpty
          ? int.tryParse(_rentController.text.trim())
          : null,
      'rentStartDate': _rentStartDate,
    };

    final error = await flatProvider.updateFlat(widget.flatId, data);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $error')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flat updated successfully')),
      );
    }
  }

  Future<void> _removeTenant() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Tenant'),
        content: const Text(
            'Remove tenant from this flat? The flat will be marked vacant.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: AppTheme.onSurfaceVariantColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remove',
                style: GoogleFonts.inter(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final error = await context
        .read<FlatProvider>()
        .removeTenant(widget.flatId);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove tenant: $error')),
      );
    } else {
      setState(() => _tenantName = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tenant removed')),
      );
    }
  }

  Future<void> _deleteFlat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Flat'),
        content: const Text(
            'This action cannot be undone. The flat will be permanently removed.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: AppTheme.onSurfaceVariantColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: GoogleFonts.inter(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final error =
        await context.read<FlatProvider>().deleteFlat(widget.flatId);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete flat: $error')),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flat deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final flat = _getFlat();

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: Text(
          flat != null ? 'Flat ${flat.flatNumber}' : 'Flat Details',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _showEditDialog,
          ),
        ],
      ),
      body: flat == null
          ? const Center(child: Text('Flat not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFlatHeader(flat),
                  const SizedBox(height: 24),
                  _buildDetailsCard(flat),
                  const SizedBox(height: 24),
                  if (flat.tenantId != null) ...[
                    _buildTenantCard(),
                    const SizedBox(height: 16),
                  ],
                  if (flat.tenantId != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _removeTenant,
                        icon: const Icon(Icons.person_remove_rounded,
                            size: 18),
                        label: const Text('Remove Tenant'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(color: AppTheme.errorColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _deleteFlat,
                      icon:
                          const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete Flat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPaymentSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentSection() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, _) {
        final payments = paymentProvider.getPaymentsByFlat(widget.flatId);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PAYMENT REQUESTS',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            if (payments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.outlineVariantColor.withAlpha(60),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.payments_outlined,
                        size: 32, color: AppTheme.outlineVariantColor),
                    const SizedBox(height: 8),
                    Text(
                      'No payment requests yet',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.onPrimaryContainerColor,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...payments.map((payment) =>
                  _buildPaymentCard(payment)),
          ],
        );
      },
    );
  }

  Widget _buildPaymentCard(PaymentRequestModel payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: payment.status == 'declined'
                ? AppTheme.errorColor
                : payment.status == 'approved'
                    ? const Color(0xFF059669)
                    : AppTheme.outlineVariantColor,
            width: 3,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryFixedColor.withAlpha(100),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.tenantName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    Text(
                      '₹${payment.amount} \u2022 ${DateFormat('d MMM yyyy').format(payment.createdAt)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.onPrimaryContainerColor,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: payment.status),
            ],
          ),
          if (payment.status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _approvePayment(payment),
                    icon: const Icon(Icons.check_circle_rounded, size: 16),
                    label: Text(
                      'Approve',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _declinePayment(payment),
                    icon: const Icon(Icons.cancel_rounded, size: 16),
                    label: Text(
                      'Decline',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFBA1A1A),
                      side: const BorderSide(color: Color(0xFFBA1A1A)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (payment.ownerNote != null && payment.ownerNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withAlpha(10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                payment.ownerNote!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.errorColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _approvePayment(PaymentRequestModel payment) async {
    final error = await context.read<PaymentProvider>().updatePaymentStatus(
          paymentId: payment.id,
          status: 'approved',
        );
    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve: $error')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment approved'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    }
  }

  Future<void> _declinePayment(PaymentRequestModel payment) async {
    final noteController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Reason for declining (optional):'),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: 'e.g., Payment not received',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: AppTheme.onSurfaceVariantColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
                ctx, noteController.text.trim()),
            child: Text('Decline',
                style: GoogleFonts.inter(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (result == null || !mounted) return;

    final error = await context.read<PaymentProvider>().updatePaymentStatus(
          paymentId: payment.id,
          status: 'declined',
          ownerNote: result.isNotEmpty ? result : null,
        );
    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to decline: $error')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment declined')),
        );
      }
    }
  }

  Future<void> _showEditDialog() async {
    final wingCtrl = TextEditingController(text: _wingController.text);
    final floorCtrl = TextEditingController(text: _floorController.text);
    final rentCtrl = TextEditingController(text: _rentController.text);
    DateTime? selectedDate = _rentStartDate;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        DateTime? dialogDate = selectedDate;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(
              'Edit Flat',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: wingCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Building Wing',
                      hintText: 'e.g., A',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: floorCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Flat Floor',
                      hintText: 'e.g., 3',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rentCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Rent (₹)',
                      hintText: 'e.g., 8000',
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: dialogDate ?? now,
                        firstDate: DateTime(2020),
                        lastDate: now.add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => dialogDate = picked);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.outlineVariantColor.withAlpha(76),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 18,
                              color: AppTheme.onSurfaceVariantColor),
                          const SizedBox(width: 12),
                          Text(
                            dialogDate != null
                                ? 'Start: ${DateFormat('d MMM yyyy').format(dialogDate!)}'
                                : 'Set rent start date',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: dialogDate != null
                                  ? AppTheme.onSurfaceColor
                                  : AppTheme.outlineColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style: GoogleFonts.inter(
                        color: AppTheme.onSurfaceVariantColor)),
              ),
              ElevatedButton(
                onPressed: () {
                  _wingController.text = wingCtrl.text;
                  _floorController.text = floorCtrl.text;
                  _rentController.text = rentCtrl.text;
                  _rentStartDate = dialogDate;
                  Navigator.pop(ctx, true);
                },
                child: Text('Save',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );

    wingCtrl.dispose();
    floorCtrl.dispose();
    rentCtrl.dispose();

    if (saved == true && mounted) {
      await _save();
    }
  }

  Widget _buildFlatHeader(FlatModel flat) {
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
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    'Building: ${flat.buildingCode}',
                    if (flat.buildingWing != null &&
                        flat.buildingWing!.isNotEmpty)
                      'Wing ${flat.buildingWing}',
                    if (flat.flatFloor != null &&
                        flat.flatFloor!.isNotEmpty)
                      'Floor ${flat.flatFloor}',
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

  Widget _buildDetailsCard(FlatModel flat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineVariantColor.withAlpha(76),
        ),
      ),
      child: Column(
        children: [
          _detailRow(Icons.wallet_rounded, 'Monthly Rent',
              flat.rentAmount != null ? '₹${flat.rentAmount}' : 'Not set'),
          const Divider(height: 24,
              color: AppTheme.outlineVariantColor),
          _detailRow(Icons.calendar_today_rounded, 'Due Day',
              '${flat.rentDueDay}th of each month'),
          const Divider(height: 24,
              color: AppTheme.outlineVariantColor),
          _detailRow(Icons.person_outline_rounded, 'Tenant',
              flat.tenantId != null
                  ? (_tenantName ?? 'Loading...')
                  : 'Vacant'),
          const Divider(height: 24,
              color: AppTheme.outlineVariantColor),
          _detailRow(Icons.calendar_month_rounded, 'Rent Start Date',
              flat.rentStartDate != null
                  ? DateFormat('d MMM yyyy').format(flat.rentStartDate!)
                  : 'Not set'),
          const Divider(height: 24,
              color: AppTheme.outlineVariantColor),
          _detailRow(Icons.badge_outlined, 'Status', flat.status),
        ],
      ),
    );
  }

  Widget _buildTenantCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineVariantColor.withAlpha(76),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.secondaryFixedColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_rounded,
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
                  'Current Tenant',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onPrimaryContainerColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _tenantName ?? 'Loading...',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.onSurfaceVariantColor),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: value == 'Not set' || value == 'Vacant'
                      ? AppTheme.outlineColor
                      : AppTheme.onSurfaceColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
