import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/models/flat_model.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/flat_provider.dart';
import 'package:micro_society_app/widgets/reusable/status_badge.dart';
import 'package:provider/provider.dart';

class ManageFlatsScreen extends StatefulWidget {
  const ManageFlatsScreen({super.key});

  @override
  State<ManageFlatsScreen> createState() => _ManageFlatsScreenState();
}

class _ManageFlatsScreenState extends State<ManageFlatsScreen> {
  final _flatNumberController = TextEditingController();
  final _wingController = TextEditingController();
  final _floorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final flatProvider = context.read<FlatProvider>();
    if (auth.userModel?.buildingCode != null) {
      flatProvider.streamFlatsByBuilding(auth.userModel!.buildingCode!);
    }
  }

  @override
  void dispose() {
    _flatNumberController.dispose();
    _wingController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  void _showAddFlatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Flat',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _flatNumberController,
              decoration: const InputDecoration(
                labelText: 'Flat Number',
                hintText: 'e.g., 101',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _wingController,
              decoration: const InputDecoration(
                labelText: 'Building Wing',
                hintText: 'e.g., A',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _floorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Flat Floor',
                hintText: 'e.g., 3',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final flatProvider = context.read<FlatProvider>();
              final auth = context.read<AuthProvider>();
              final buildingCode = auth.userModel?.buildingCode ?? '';
              final flatId =
                  '${buildingCode}_${_flatNumberController.text.trim()}';
              final flat = FlatModel(
                flatId: flatId,
                flatNumber: _flatNumberController.text.trim(),
                buildingCode: buildingCode,
                buildingWing: _wingController.text.trim().isEmpty
                    ? null
                    : _wingController.text.trim(),
                flatFloor: _floorController.text.trim().isEmpty
                    ? null
                    : _floorController.text.trim(),
                status: 'vacant',
                ownerId: auth.firebaseUser?.uid ?? '',
              );
              await flatProvider.addFlat(flat);
              if (context.mounted) Navigator.pop(context);
              _flatNumberController.clear();
              _wingController.clear();
              _floorController.clear();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(FlatModel flat) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Flat ${flat.flatNumber}?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This action cannot be undone. The flat will be permanently removed.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.onPrimaryContainerColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: AppTheme.onSurfaceColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Flats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddFlatDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: context.watch<FlatProvider>().statusFilter == 'All',
                    onSelected: () {
                      context.read<FlatProvider>().setStatusFilter('All');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Vacant',
                    isSelected: context.watch<FlatProvider>().statusFilter == 'Vacant',
                    onSelected: () {
                      context.read<FlatProvider>().setStatusFilter('Vacant');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Occupied',
                    isSelected: context.watch<FlatProvider>().statusFilter == 'Occupied',
                    onSelected: () {
                      context.read<FlatProvider>().setStatusFilter('Occupied');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pending',
                    isSelected: context.watch<FlatProvider>().statusFilter == 'Pending',
                    onSelected: () {
                      context.read<FlatProvider>().setStatusFilter('Pending');
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<FlatProvider>(
              builder: (context, flatProvider, _) {
                if (flatProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (flatProvider.flats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.meeting_room_outlined,
                          size: 64,
                          color: AppTheme.outlineVariantColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No flats found',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: AppTheme.onPrimaryContainerColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first flat to get started',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.outlineColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: flatProvider.flats.length,
                  itemBuilder: (context, index) {
                    final flat = flatProvider.flats[index];
                    return Dismissible(
                      key: Key(flat.flatId),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _showDeleteConfirmation(flat),
                      onDismissed: (_) async {
                        final error = await context
                            .read<FlatProvider>()
                            .deleteFlat(flat.flatId);
                        if (error != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error)),
                          );
                        }
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.meeting_room_rounded,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          title: Text(
                            'Flat ${flat.flatNumber}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
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
                              fontSize: 12,
                              color: AppTheme.onPrimaryContainerColor,
                            ),
                          ),
                          trailing: StatusBadge(status: flat.status),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.secondaryColor
              : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.onSurfaceVariantColor,
          ),
        ),
      ),
    );
  }
}
