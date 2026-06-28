import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/models/issue_model.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/issue_provider.dart';
import 'package:micro_society_app/widgets/reusable/status_badge.dart';
import 'package:provider/provider.dart';

class OwnerIssuesScreen extends StatefulWidget {
  const OwnerIssuesScreen({super.key});

  @override
  State<OwnerIssuesScreen> createState() => _OwnerIssuesScreenState();
}

class _OwnerIssuesScreenState extends State<OwnerIssuesScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final issueProvider = context.read<IssueProvider>();
    if (auth.userModel?.buildingCode != null) {
      issueProvider.streamIssuesByBuilding(auth.userModel!.buildingCode!);
    }
  }

  Future<void> _updateIssueStatus(IssueModel issue, String newStatus) async {
    final issueProvider = context.read<IssueProvider>();
    await issueProvider.updateIssue(issue.issueId, {'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issues'),
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
                      const SizedBox(height: 8),
                      Text(
                        'Flat ${issue.flatNumber}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      if (issue.status != 'resolved') ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (issue.status == 'open')
                              TextButton(
                                onPressed: () => _updateIssueStatus(
                                    issue, 'in_progress'),
                                child: const Text('Mark In Progress'),
                              ),
                            if (issue.status == 'in_progress')
                              TextButton(
                                onPressed: () => _updateIssueStatus(
                                    issue, 'resolved'),
                                child: const Text('Mark Resolved'),
                              ),
                          ],
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
