import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/models/event_model.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/event_provider.dart';
import 'package:micro_society_app/providers/flat_provider.dart';
import 'package:micro_society_app/providers/issue_provider.dart';
import 'package:micro_society_app/providers/tenant_request_provider.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${auth.userModel?.name ?? 'Owner'}',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurfaceColor,
                  letterSpacing: -0.01,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Building Code: ${auth.userModel?.buildingCode ?? 'Not set'}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.onPrimaryContainerColor,
                ),
              ),
              const SizedBox(height: 24),
              _StatsGrid(),
              const SizedBox(height: 28),
              _buildSectionHeader('Pending Approvals', Icons.person_add_rounded),
              const SizedBox(height: 12),
              _PendingApprovalsList(),
              const SizedBox(height: 28),
              _buildSectionHeader('Upcoming Events', Icons.event_rounded),
              const SizedBox(height: 12),
              _UpcomingEventsList(),
              const SizedBox(height: 28),
              _buildSectionHeader('Recent Issues', Icons.report_problem_rounded),
              const SizedBox(height: 12),
              _RecentIssuesList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.secondaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceColor,
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FlatProvider>(
      builder: (context, flatProvider, _) {
        final allFlats = flatProvider.allFlats;
        final totalFlats = allFlats.length;
        final occupied = allFlats.where((f) => f.status == 'occupied').length;
        final vacant = allFlats.where((f) => f.status == 'vacant').length;

        return Consumer<IssueProvider>(
          builder: (context, issueProvider, _) {
            final openIssues = issueProvider.issues
                .where((i) => i.status == 'open')
                .length;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _StatCard(
                  icon: Icons.domain_rounded,
                  label: 'Total Flats',
                  value: totalFlats.toString(),
                  color: AppTheme.secondaryColor,
                ),
                _StatCard(
                  icon: Icons.home_rounded,
                  label: 'Occupied',
                  value: occupied.toString(),
                  color: const Color(0xFF059669),
                ),
                _StatCard(
                  icon: Icons.meeting_room_rounded,
                  label: 'Vacant',
                  value: vacant.toString(),
                  color: const Color(0xFFD97706),
                ),
                _StatCard(
                  icon: Icons.report_problem_rounded,
                  label: 'Open Issues',
                  value: openIssues.toString(),
                  color: const Color(0xFFBA1A1A),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineVariantColor.withAlpha(76),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1C30).withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.onPrimaryContainerColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingEventsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        if (eventProvider.isLoading) {
          return _buildShimmer();
        }

        final events = eventProvider.upcomingEvents.take(3).toList();

        if (events.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_outlined,
            message: 'No upcoming events',
          );
        }

        return Column(
          children: events.map((event) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/owner/event-detail',
                  arguments: event.eventId,
                );
              },
              child: Container(
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
                        Icons.event_rounded,
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
                            event.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurfaceColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatRelativeDate(event),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.onPrimaryContainerColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.outlineColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatRelativeDate(EventModel event) {
    if (event.eventDate == null) return 'Date not set';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(
        event.eventDate!.year, event.eventDate!.month, event.eventDate!.day);
    final diff = eventDay.difference(today).inDays;

    String dateLabel;
    if (diff == 0) {
      dateLabel = 'Today';
    } else if (diff == 1) {
      dateLabel = 'Tomorrow';
    } else if (diff <= 7) {
      dateLabel = 'In $diff days';
    } else {
      dateLabel =
          '${event.eventDate!.day}/${event.eventDate!.month}/${event.eventDate!.year}';
    }

    if (event.eventTime.isNotEmpty) {
      final parts = event.eventTime.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final ampm = hour >= 12 ? 'PM' : 'AM';
      final m = minute.toString().padLeft(2, '0');
      return '$dateLabel at $h:$m $ampm';
    }

    return dateLabel;
  }
}

class _RecentIssuesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<IssueProvider>(
      builder: (context, issueProvider, _) {
        if (issueProvider.isLoading) {
          return _buildShimmer();
        }

        final issues = issueProvider.sortedIssues.take(3).toList();

        if (issues.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline_rounded,
            message: 'No recent issues',
          );
        }

        return Column(
          children: issues.map((issue) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/owner/issue-detail',
                  arguments: issue.issueId,
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
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
                child: Row(
                  children: [
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Flat ${issue.flatNumber}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.onPrimaryContainerColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(issue.status).withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        issue.status.replaceAll('_', ' ').toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _getStatusColor(issue.status),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.outlineColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
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

class _PendingApprovalsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TenantRequestProvider>(
      builder: (context, requestProvider, _) {
        if (requestProvider.isLoading) {
          return _buildShimmer();
        }

        final pending = requestProvider.pendingRequests;

        if (pending.isEmpty) {
          return _buildEmptyState(
            icon: Icons.person_add_disabled_rounded,
            message: 'No pending requests',
          );
        }

        return Column(
          children: pending.map((request) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706).withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFFD97706),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.tenant.name,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurfaceColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Flat ${request.flat.flatNumber}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.onPrimaryContainerColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final error = await requestProvider
                                .approveTenant(
                              tenantId: request.tenant.uid,
                              flatId: request.flat.flatId,
                            );
                            if (error != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error)),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                          ),
                          label: Text(
                            'Approve',
                            style: GoogleFonts.inter(
                              fontSize: 13,
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
                          onPressed: () async {
                            final error = await requestProvider
                                .rejectTenant(
                              tenantId: request.tenant.uid,
                              flatId: request.flat.flatId,
                            );
                            if (error != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error)),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.cancel_rounded,
                            size: 18,
                          ),
                          label: Text(
                            'Reject',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFBA1A1A),
                            side: const BorderSide(
                              color: Color(0xFFBA1A1A),
                            ),
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
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

Widget _buildEmptyState({required IconData icon, required String message}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 32),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppTheme.outlineVariantColor.withAlpha(60),
      ),
    ),
    child: Column(
      children: [
        Icon(icon, size: 40, color: AppTheme.outlineVariantColor),
        const SizedBox(height: 8),
        Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.onPrimaryContainerColor,
          ),
        ),
      ],
    ),
  );
}

Widget _buildShimmer() {
  return Column(
    children: List.generate(
      2,
      (_) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 60,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
