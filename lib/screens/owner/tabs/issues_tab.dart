import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/providers/issue_provider.dart';
import 'package:micro_society_app/widgets/reusable/status_badge.dart';
import 'package:provider/provider.dart';

class IssuesTab extends StatefulWidget {
  const IssuesTab({super.key});

  @override
  State<IssuesTab> createState() => _IssuesTabState();
}

class _IssuesTabState extends State<IssuesTab> {
  Future<void> _updateIssueStatus(String issueId, String newStatus) async {
    final issueProvider = context.read<IssueProvider>();
    await issueProvider.updateIssue(issueId, {'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            'Issues',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceColor,
            ),
          ),
        ),
        Expanded(
          child: Consumer<IssueProvider>(
            builder: (context, issueProvider, _) {
              if (issueProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (issueProvider.issues.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 56,
                        color: AppTheme.outlineVariantColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No issues reported',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.onPrimaryContainerColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: issueProvider.issues.length,
                itemBuilder: (context, index) {
                  final issue = issueProvider.issues[index];
                  return _IssueCard(
                    issue: issue,
                    onStatusUpdate: _updateIssueStatus,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _IssueCard extends StatelessWidget {
  final dynamic issue;
  final Function(String, String) onStatusUpdate;

  const _IssueCard({required this.issue, required this.onStatusUpdate});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return const Color(0xFFBA1A1A);
      case 'in_progress':
        return AppTheme.secondaryContainerColor;
      case 'resolved':
        return const Color(0xFF059669);
      default:
        return AppTheme.outlineColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(issue.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: statusColor, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1C30).withAlpha(4),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    issue.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceColor,
                    ),
                  ),
                ),
                StatusBadge(status: issue.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              issue.description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.onPrimaryContainerColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              'Flat ${issue.flatNumber}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.outlineColor,
              ),
            ),
            if (issue.status != 'resolved') ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (issue.status == 'open')
                    _buildActionButton(
                      label: 'Mark In Progress',
                      onTap: () => onStatusUpdate(issue.issueId, 'in_progress'),
                    ),
                  if (issue.status == 'in_progress')
                    _buildActionButton(
                      label: 'Mark Resolved',
                      onTap: () => onStatusUpdate(issue.issueId, 'resolved'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor.withAlpha(15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondaryColor,
          ),
        ),
      ),
    );
  }
}
