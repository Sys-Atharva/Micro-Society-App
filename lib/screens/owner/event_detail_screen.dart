import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/models/event_model.dart';
import 'package:micro_society_app/providers/event_provider.dart';
import 'package:micro_society_app/widgets/reusable/status_badge.dart';
import 'package:provider/provider.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        final event = eventProvider.events.firstWhere(
          (e) => e.eventId == eventId,
          orElse: () => const EventModel(
            eventId: '',
            buildingCode: '',
            title: 'Event not found',
          ),
        );

        if (event.eventId.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(
              child: Text('Event not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Event Details'),
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
                    color: _getEventHeaderColor(event.status).withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getEventHeaderColor(event.status).withAlpha(60),
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
                              color: _getEventHeaderColor(event.status)
                                  .withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getEventIcon(event.status),
                              color: _getEventHeaderColor(event.status),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurfaceColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                StatusBadge(status: event.status),
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
                  Icons.calendar_today_rounded,
                  'Date',
                  event.eventDate != null
                      ? '${event.eventDate!.day}/${event.eventDate!.month}/${event.eventDate!.year}'
                      : 'Not set',
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.access_time_rounded,
                  'Time',
                  event.eventTime.isNotEmpty ? _formatTime(context, event) : 'Not set',
                ),
                if (event.location.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    'Location',
                    event.location,
                  ),
                ],
                const SizedBox(height: 24),
                if (event.description.isNotEmpty) ...[
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
                      event.description,
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
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

  String _formatTime(BuildContext context, EventModel event) {
    if (event.eventTime.isEmpty) return 'Not set';
    final parts = event.eventTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }

  Color _getEventHeaderColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF059669);
      case 'cancelled':
        return const Color(0xFFD97706);
      default:
        return AppTheme.secondaryColor;
    }
  }

  IconData _getEventIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.event_rounded;
    }
  }
}
