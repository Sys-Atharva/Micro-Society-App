import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/models/issue_model.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/issue_provider.dart';
import 'package:micro_society_app/widgets/reusable/status_badge.dart';
import 'package:provider/provider.dart';

class IssuesTab extends StatefulWidget {
  const IssuesTab({super.key});

  @override
  State<IssuesTab> createState() => _IssuesTabState();
}

class _IssuesTabState extends State<IssuesTab> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'medium';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddIssueDialog() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() => _selectedPriority = 'medium');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Report Issue',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Issue Title',
                    hintText: 'e.g., No water supply',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the issue',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => _selectedPriority = value ?? 'medium');
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_titleController.text.trim().isEmpty) return;

                final issueProvider = context.read<IssueProvider>();
                final auth = context.read<AuthProvider>();
                final issueId =
                    DateTime.now().millisecondsSinceEpoch.toString();

                final issue = IssueModel(
                  issueId: issueId,
                  buildingCode: auth.userModel?.buildingCode ?? '',
                  flatNumber: auth.userModel?.flatId ?? '',
                  tenantId: auth.firebaseUser?.uid ?? '',
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                  status: 'open',
                  priority: _selectedPriority,
                );
                await issueProvider.addIssue(issue);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Report'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(IssueModel issue) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete "${issue.title}"?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This action cannot be undone. The issue will be permanently removed.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.onPrimaryContainerColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: AppTheme.onSurfaceColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final error = await context
                  .read<IssueProvider>()
                  .deleteIssue(issue.issueId);
              if (error != null && ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(error)),
                );
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Issues',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showAddIssueDialog,
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
                        'Report Issue',
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
        Expanded(
          child: Consumer<IssueProvider>(
            builder: (context, issueProvider, _) {
              if (issueProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (issueProvider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 56,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        issueProvider.errorMessage!,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.onPrimaryContainerColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final issues = issueProvider.sortedIssues;

              if (issues.isEmpty) {
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
                      const SizedBox(height: 4),
                      Text(
                        'All clear! Report an issue if needed.',
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
                itemCount: issues.length,
                itemBuilder: (context, index) {
                  final issue = issues[index];
                  return _IssueCard(
                    issue: issue,
                    onDelete: () => _confirmDelete(issue),
                    onStatusUpdate: (newStatus) {
                      context.read<IssueProvider>().updateIssue(
                          issue.issueId, {'status': newStatus});
                    },
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
  final IssueModel issue;
  final VoidCallback onDelete;
  final Function(String) onStatusUpdate;

  const _IssueCard({
    required this.issue,
    required this.onDelete,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: _getPriorityColor(issue.priority),
            width: 3,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor(issue.status).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getStatusIcon(issue.status),
                    color: _getStatusColor(issue.status),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                      if (issue.description.isNotEmpty)
                        Text(
                          issue.description,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.onPrimaryContainerColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                StatusBadge(status: issue.status),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppTheme.onSurfaceVariantColor,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    } else if (value == 'in_progress' ||
                        value == 'resolved' ||
                        value == 'open') {
                      onStatusUpdate(value);
                    }
                  },
                  itemBuilder: (context) => [
                    if (issue.status != 'in_progress')
                      PopupMenuItem(
                        value: 'in_progress',
                        child: Row(
                          children: [
                            const Icon(Icons.hourglass_top_rounded,
                                size: 18, color: Color(0xFFD97706)),
                            const SizedBox(width: 10),
                            Text('Mark In Progress',
                                style: GoogleFonts.inter(fontSize: 14)),
                          ],
                        ),
                      ),
                    if (issue.status != 'resolved')
                      PopupMenuItem(
                        value: 'resolved',
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline_rounded,
                                size: 18, color: Color(0xFF059669)),
                            const SizedBox(width: 10),
                            Text('Mark Resolved',
                                style: GoogleFonts.inter(fontSize: 14)),
                          ],
                        ),
                      ),
                    if (issue.status != 'open')
                      PopupMenuItem(
                        value: 'open',
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                size: 18, color: AppTheme.secondaryColor),
                            const SizedBox(width: 10),
                            Text('Mark Open',
                                style: GoogleFonts.inter(fontSize: 14)),
                          ],
                        ),
                      ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded,
                              size: 18, color: AppTheme.errorColor),
                          const SizedBox(width: 10),
                          Text('Delete',
                              style: GoogleFonts.inter(
                                  fontSize: 14, color: AppTheme.errorColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 12, color: AppTheme.outlineColor),
                const SizedBox(width: 4),
                Text(
                  _formatDate(issue),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.outlineColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.meeting_room_rounded,
                    size: 12, color: AppTheme.outlineColor),
                const SizedBox(width: 4),
                Text(
                  'Flat ${issue.flatNumber}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.outlineColor,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(issue.priority).withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    issue.priority.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _getPriorityColor(issue.priority),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(IssueModel issue) {
    if (issue.createdAt == null) return 'Date not set';
    final now = DateTime.now();
    final diff = now.difference(issue.createdAt!);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${issue.createdAt!.day}/${issue.createdAt!.month}/${issue.createdAt!.year}';
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
