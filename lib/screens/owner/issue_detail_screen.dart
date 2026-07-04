import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/models/issue_model.dart';
import 'package:micro_society_app/providers/issue_provider.dart';
import 'package:micro_society_app/widgets/reusable/status_badge.dart';
import 'package:provider/provider.dart';

class IssueDetailScreen extends StatelessWidget {
  final String issueId;

  const IssueDetailScreen({super.key, required this.issueId});

  @override
  Widget build(BuildContext context) {
    return Consumer<IssueProvider>(
      builder: (context, issueProvider, _) {
        final issue = issueProvider.issues.firstWhere(
          (i) => i.issueId == issueId,
          orElse: () => const IssueModel(
            issueId: '',
            buildingCode: '',
            flatNumber: '',
            tenantId: '',
            title: 'Issue not found',
            description: '',
            status: 'open',
          ),
        );

        if (issue.issueId.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(
              child: Text('Issue not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Issue Details'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getStatusColor(issue.status).withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(issue.status).withAlpha(60),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  _getStatusColor(issue.status).withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getStatusIcon(issue.status),
                              color: _getStatusColor(issue.status),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  issue.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurfaceColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                StatusBadge(status: issue.status),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow(
                  Icons.flag_rounded,
                  'Priority',
                  _getPriorityLabel(issue.priority),
                  tint: _getPriorityColor(issue.priority),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  _getStatusIcon(issue.status),
                  'Status',
                  _getStatusLabel(issue.status),
                  tint: _getStatusColor(issue.status),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.meeting_room_rounded,
                  'Flat',
                  issue.flatNumber.isNotEmpty
                      ? 'Flat ${issue.flatNumber}'
                      : 'Not set',
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.calendar_today_rounded,
                  'Reported on',
                  _formatDate(issue),
                ),
                const SizedBox(height: 24),
                if (issue.description.isNotEmpty) ...[
                  Text(
                    'Description',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.outlineVariantColor.withAlpha(60),
                      ),
                    ),
                    child: Text(
                      issue.description,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.6,
                        color: AppTheme.onPrimaryContainerColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? tint}) {
    final tileColor = tint ?? AppTheme.secondaryColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tileColor.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: tileColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.onPrimaryContainerColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 15,
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

  String _formatDate(IssueModel issue) {
    if (issue.createdAt == null) return 'Not set';
    final dt = issue.createdAt!;
    final dateStr = '${dt.day}/${dt.month}/${dt.year}';
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$dateStr at $hour:$minute';
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return priority;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return const Color(0xFFBA1A1A);
      case 'in_progress':
        return const Color(0xFFD97706);
      case 'resolved':
        return const Color(0xFF059669);
      default:
        return AppTheme.outlineColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'open':
        return Icons.error_outline_rounded;
      case 'in_progress':
        return Icons.hourglass_top_rounded;
      case 'resolved':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return const Color(0xFFBA1A1A);
      case 'medium':
        return const Color(0xFFD97706);
      case 'low':
        return const Color(0xFF059669);
      default:
        return AppTheme.outlineColor;
    }
  }
}
