import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/models/event_model.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/event_provider.dart';
import 'package:micro_society_app/widgets/reusable/status_badge.dart';
import 'package:provider/provider.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _showAddEventDialog() {
    final eventProvider = context.read<EventProvider>();
    final auth = context.read<AuthProvider>();
    final buildingCode = auth.userModel?.buildingCode;
    final createdBy = auth.firebaseUser?.uid;

    if (buildingCode == null || buildingCode.isEmpty || createdBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data not ready. Please re-login.')),
      );
      return;
    }

    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add Event',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    hintText: 'Enter event title',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter event description',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (optional)',
                    hintText: 'e.g., Community Hall',
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select Date',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _selectedDate != null
                          ? AppTheme.onSurfaceColor
                          : AppTheme.outlineColor,
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => _selectedDate = date);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select Time (optional)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _selectedTime != null
                          ? AppTheme.onSurfaceColor
                          : AppTheme.outlineColor,
                    ),
                  ),
                  trailing: const Icon(Icons.access_time_rounded),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setDialogState(() => _selectedTime = time);
                    }
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
                if (_titleController.text.trim().isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter an event title')),
                    );
                  }
                  return;
                }
                if (_selectedDate == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an event date')),
                    );
                  }
                  return;
                }

                final eventId =
                    DateTime.now().millisecondsSinceEpoch.toString();

                String eventTimeStr = '';
                if (_selectedTime != null) {
                  eventTimeStr =
                      '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
                }

                final event = EventModel(
                  eventId: eventId,
                  buildingCode: buildingCode,
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                  location: _locationController.text.trim(),
                  eventDate: _selectedDate,
                  eventTime: eventTimeStr,
                  status: 'upcoming',
                  createdBy: createdBy,
                  createdAt: DateTime.now(),
                );
                final error = await eventProvider.addEvent(event);
                if (context.mounted) {
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add event: $error')),
                    );
                    return;
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(EventModel event) {
    final eventProvider = context.read<EventProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete "${event.title}"?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This action cannot be undone. The event will be permanently removed.',
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
              final error = await eventProvider.deleteEvent(event.eventId);
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
                  'Events',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showAddEventDialog,
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
                        'Add Event',
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
          child: Consumer<EventProvider>(
            builder: (context, eventProvider, _) {
              if (eventProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (eventProvider.errorMessage != null) {
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
                        eventProvider.errorMessage!,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.onPrimaryContainerColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final events = eventProvider.sortedEvents;

              if (events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.event_outlined,
                        size: 56,
                        color: AppTheme.outlineVariantColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No events scheduled',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.onPrimaryContainerColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create your first building event',
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
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _EventCard(
                    event: event,
                    onDelete: () => _confirmDelete(event),
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

class _EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onDelete;

  const _EventCard({required this.event, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/tenant/event-detail',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getEventIconColor(event.status).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getEventIcon(event.status),
                    color: _getEventIconColor(event.status),
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
                      ),
                      if (event.description.isNotEmpty)
                        Text(
                          event.description,
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
                StatusBadge(status: event.status),
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
                onSelected: (value) async {
                  if (value == 'delete') {
                    onDelete();
                  } else if (value == 'completed' ||
                      value == 'cancelled' ||
                      value == 'upcoming') {
                    final error = await context
                        .read<EventProvider>()
                        .updateEvent(event.eventId, {'status': value});
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  if (event.status != 'completed')
                    PopupMenuItem(
                      value: 'completed',
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              size: 18, color: Color(0xFF059669)),
                          const SizedBox(width: 10),
                          Text('Mark Completed',
                              style: GoogleFonts.inter(fontSize: 14)),
                        ],
                      ),
                    ),
                  if (event.status != 'cancelled')
                    PopupMenuItem(
                      value: 'cancelled',
                      child: Row(
                        children: [
                          const Icon(Icons.cancel_outlined,
                              size: 18, color: Color(0xFFD97706)),
                          const SizedBox(width: 10),
                          Text('Mark Cancelled',
                              style: GoogleFonts.inter(fontSize: 14)),
                        ],
                      ),
                    ),
                  if (event.status != 'upcoming')
                    PopupMenuItem(
                      value: 'upcoming',
                      child: Row(
                        children: [
                          const Icon(Icons.event_rounded,
                              size: 18, color: AppTheme.secondaryColor),
                          const SizedBox(width: 10),
                          Text('Mark Upcoming',
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
                _formatEventDate(context),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.outlineColor,
                ),
              ),
              if (event.location.isNotEmpty) ...[
                const SizedBox(width: 12),
                const Icon(Icons.location_on_outlined,
                    size: 12, color: AppTheme.outlineColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    event.location,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.outlineColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      ),
    );
  }

  String _formatEventDate(BuildContext context) {
    if (event.eventDate == null) return 'Date not set';
    final dateStr =
        '${event.eventDate!.day}/${event.eventDate!.month}/${event.eventDate!.year}';
    if (event.eventTime.isNotEmpty) {
      final parts = event.eventTime.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      final time = TimeOfDay(hour: hour, minute: minute);
      return '$dateStr at ${time.format(context)}';
    }
    return dateStr;
  }

  Color _getEventIconColor(String status) {
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
