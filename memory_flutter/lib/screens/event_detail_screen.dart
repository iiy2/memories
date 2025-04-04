import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memory_flutter/models/event.dart';
import 'package:memory_flutter/models/event_type.dart';
import 'package:memory_flutter/providers/event_provider.dart';
import 'package:memory_flutter/providers/event_type_provider.dart';
import 'package:memory_flutter/utils/date_utils.dart';
import 'package:memory_flutter/widgets/life_timer.dart';
import 'package:memory_flutter/widgets/life_timer_alt.dart';
import 'package:memory_flutter/widgets/compact_life_timer.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Event? _event;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final event = await eventProvider.getEvent(widget.eventId);
      
      if (mounted) {
        setState(() {
          _event = event;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteEvent() async {
    if (_event == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete "${_event!.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final eventProvider = Provider.of<EventProvider>(context, listen: false);
        final success = await eventProvider.deleteEvent(_event!.id);
        
        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event deleted')),
          );
        } else if (mounted) {
          setState(() {
            _errorMessage = eventProvider.error ?? 'Failed to delete event';
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString();
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventTypeProvider = Provider.of<EventTypeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_event?.title ?? 'Event Details'),
        actions: [
          if (_event != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDeleteEvent,
              tooltip: 'Delete Event',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading event',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEvent,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _event == null
                  ? const Center(
                      child: Text('Event not found'),
                    )
                  : _buildEventDetails(context, _event!, eventTypeProvider.eventTypes),
    );
  }

  Widget _buildEventDetails(
    BuildContext context, 
    Event event, 
    List<EventType> eventTypes,
  ) {
    // Find the event type for this event
    final eventType = eventTypes.firstWhere(
      (type) => type.name == event.category,
      orElse: () => eventTypes.first,
    );
    
    final color = eventType.getColor();
    final icon = _getIconData(eventType.icon);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event header card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category banner
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Event info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Date
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            DateFormatUtils.formatDate(event.date),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Life Timer with light background and colored text
          Container(
            width: double.infinity,
            child: LifeTimerAlt(
              key: ValueKey('event-timer-${event.id}'),
              eventDate: event.date,
              accentColor: color,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Description section
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                event.description.isEmpty
                    ? 'No description provided'
                    : event.description,
                style: TextStyle(
                  fontSize: 16,
                  color: event.description.isEmpty ? Colors.grey : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Event metadata section
          Text(
            'Event Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Created time
                  _buildInfoRow(
                    context,
                    'Created',
                    DateFormatUtils.formatDateTime(event.createdAt),
                    Icons.access_time,
                  ),
                  const Divider(),
                  
                  // Last updated
                  _buildInfoRow(
                    context,
                    'Last Updated',
                    DateFormatUtils.formatDateTime(event.updatedAt),
                    Icons.update,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // Convert string icon name to IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'account': return Icons.person;
      case 'briefcase': return Icons.work;
      case 'home': return Icons.home;
      case 'heart': return Icons.favorite;
      case 'heart-pulse': return Icons.monitor_heart;
      case 'home-heart': return Icons.family_restroom;
      case 'airplane': return Icons.airplanemode_active;
      case 'school': return Icons.school;
      case 'book': return Icons.book;
      case 'food': return Icons.restaurant;
      case 'basketball': return Icons.sports_basketball;
      case 'party-popper': return Icons.celebration;
      case 'music': return Icons.music_note;
      case 'movie': return Icons.movie;
      case 'gamepad-variant': return Icons.sports_esports;
      case 'cart': return Icons.shopping_cart;
      case 'car': return Icons.directions_car;
      case 'beach': return Icons.beach_access;
      case 'hiking': return Icons.hiking;
      case 'star': return Icons.star;
      default: return Icons.event;
    }
  }
}