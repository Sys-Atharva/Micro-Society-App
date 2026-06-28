import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/models/issue_model.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/issue_provider.dart';
import 'package:micro_society_app/widgets/reusable/status_badge.dart';
import 'package:provider/provider.dart';

class TenantIssuesScreen extends StatefulWidget {
  const TenantIssuesScreen({super.key});

  @override
  State<TenantIssuesScreen> createState() => _TenantIssuesScreenState();
}

class _TenantIssuesScreenState extends State<TenantIssuesScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final issueProvider = context.read<IssueProvider>();
    if (auth.firebaseUser != null) {
      issueProvider.streamIssuesByTenant(auth.firebaseUser!.uid);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showReportIssueDialog() {
    _titleController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Report Issue',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Issue Title',
                hintText: 'Brief title for the issue',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the issue in detail',
              ),
              maxLines: 3,
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
              );
              await issueProvider.addIssue(issue);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Issues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showReportIssueDialog,
          ),
        ],
      ),
      body: Consumer<IssueProvider>(
        builder: (context, issueProvider, _) {
          if (issueProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (issueProvider.issues.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No issues reported',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to report a new issue',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: issueProvider.issues.length,
            itemBuilder: (context, index) {
              final issue = issueProvider.issues[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              issue.title,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          StatusBadge(status: issue.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        issue.description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      if (issue.createdAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Reported on ${issue.createdAt!.day}/${issue.createdAt!.month}/${issue.createdAt!.year}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
