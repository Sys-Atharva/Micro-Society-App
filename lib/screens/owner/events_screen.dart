import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/models/event_model.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/event_provider.dart';
import 'package:provider/provider.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final eventProvider = context.read<EventProvider>();
    if (auth.userModel?.buildingCode != null) {
      eventProvider.streamEventsByBuilding(auth.userModel!.buildingCode!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _showAddEventDialog() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() => _selectedDate = null);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              onTap: _pickDate,
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
              final eventId = DateTime.now()
                  .millisecondsSinceEpoch
                  .toString();
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddEventDialog,
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          if (eventProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (eventProvider.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No events scheduled',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first building event',
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
            itemCount: eventProvider.events.length,
            itemBuilder: (context, index) {
              final event = eventProvider.events[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.event_rounded,
                      color: Color(0xFF059669),
                    ),
                  ),
                  title: Text(
                    event.title,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.description,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        event.eventDate != null
                            ? '${event.eventDate!.day}/${event.eventDate!.month}/${event.eventDate!.year}'
                            : 'Date not set',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFDC2626)),
                    onPressed: () async {
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
                      if (confirmed == true) {
                        if (context.mounted) {
                          context
                              .read<EventProvider>()
                              .deleteEvent(event.eventId);
                        }
                      }
                    },
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
