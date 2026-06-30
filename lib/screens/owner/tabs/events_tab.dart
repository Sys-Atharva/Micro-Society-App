import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/models/event_model.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/event_provider.dart';
import 'package:provider/provider.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddEventDialog() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() => _selectedDate = null);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add Event',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Column(
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select Date',
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_titleController.text.trim().isEmpty ||
                    _selectedDate == null) {
                  return;
                }

                final eventProvider = context.read<EventProvider>();
                final auth = context.read<AuthProvider>();
                final eventId =
                    DateTime.now().millisecondsSinceEpoch.toString();
                final event = EventModel(
                  eventId: eventId,
                  buildingCode: auth.userModel?.buildingCode ?? '',
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                  eventDate: _selectedDate,
                );
                await eventProvider.addEvent(event);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
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

              if (eventProvider.events.isEmpty) {
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
                itemCount: eventProvider.events.length,
                itemBuilder: (context, index) {
                  final event = eventProvider.events[index];
                  return _EventCard(
                    event: event,
                    onDelete: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Event'),
                          content: const Text(
                              'Are you sure you want to delete this event?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        context
                            .read<EventProvider>()
                            .deleteEvent(event.eventId);
                      }
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

class _EventCard extends StatelessWidget {
  final dynamic event;
  final VoidCallback onDelete;

  const _EventCard({required this.event, required this.onDelete});

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
                const SizedBox(height: 2),
                Text(
                  event.eventDate != null
                      ? '${event.eventDate!.day}/${event.eventDate!.month}/${event.eventDate!.year}'
                      : 'Date not set',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.outlineColor,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
