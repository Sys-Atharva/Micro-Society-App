import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/event_provider.dart';
import 'package:micro_society_app/providers/flat_provider.dart';
import 'package:micro_society_app/providers/issue_provider.dart';
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

        final events = eventProvider.events.take(3).toList();

        if (events.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_outlined,
            message: 'No upcoming events',
          );
        }

        return Column(
          children: events.map((event) {
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
                      color: const Color(0xFF059669).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.event_rounded,
                      color: Color(0xFF059669),
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
                        if (event.eventDate != null)
                          Text(
                            '${event.eventDate!.day}/${event.eventDate!.month}/${event.eventDate!.year}',
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
            );
          }).toList(),
        );
      },
    );
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

        final issues = issueProvider.issues.take(3).toList();

        if (issues.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline_rounded,
            message: 'No recent issues',
          );
        }

        return Column(
          children: issues.map((issue) {
            Color statusColor;
            switch (issue.status) {
              case 'open':
                statusColor = const Color(0xFFBA1A1A);
                break;
              case 'in_progress':
                statusColor = const Color(0xFFD97706);
                break;
              default:
                statusColor = const Color(0xFF059669);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(color: statusColor, width: 3),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      issue.status.replaceAll('_', ' ').toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
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
