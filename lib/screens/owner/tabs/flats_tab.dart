import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/models/flat_model.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/flat_provider.dart';
import 'package:micro_society_app/widgets/reusable/status_badge.dart';
import 'package:provider/provider.dart';

class FlatsTab extends StatefulWidget {
  const FlatsTab({super.key});

  @override
  State<FlatsTab> createState() => _FlatsTabState();
}

class _FlatsTabState extends State<FlatsTab> {
  final _flatNumberController = TextEditingController();

  @override
  void dispose() {
    _flatNumberController.dispose();
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
                status: 'vacant',
                ownerId: auth.firebaseUser?.uid ?? '',
              );
              await flatProvider.addFlat(flat);
              if (context.mounted) Navigator.pop(context);
              _flatNumberController.clear();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Flats',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showAddFlatDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Add Flat',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildFilterChips(),
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
                        size: 56,
                        color: AppTheme.outlineVariantColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No flats found',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.onPrimaryContainerColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add your first flat to get started',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.outlineColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: flatProvider.flats.length,
                itemBuilder: (context, index) {
                  final flat = flatProvider.flats[index];
                  return _FlatCard(flat: flat);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Consumer<FlatProvider>(
      builder: (context, flatProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: flatProvider.statusFilter == 'All',
                  onSelected: () => flatProvider.setStatusFilter('All'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Vacant',
                  isSelected: flatProvider.statusFilter == 'Vacant',
                  onSelected: () => flatProvider.setStatusFilter('Vacant'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Occupied',
                  isSelected: flatProvider.statusFilter == 'Occupied',
                  onSelected: () => flatProvider.setStatusFilter('Occupied'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending',
                  isSelected: flatProvider.statusFilter == 'Pending',
                  onSelected: () => flatProvider.setStatusFilter('Pending'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FlatCard extends StatelessWidget {
  final FlatModel flat;

  const _FlatCard({required this.flat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.outlineVariantColor.withAlpha(60),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.meeting_room_rounded,
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
                  'Flat ${flat.flatNumber}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                Text(
                  'Building: ${flat.buildingCode}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
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
