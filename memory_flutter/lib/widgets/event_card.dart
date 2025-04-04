import 'package:flutter/material.dart';
import 'package:memory_flutter/models/event.dart';
import 'package:memory_flutter/models/event_type.dart';
import 'package:memory_flutter/utils/date_utils.dart';
import 'package:memory_flutter/widgets/compact_life_timer.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final List<EventType> eventTypes;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EventCard({
    Key? key,
    required this.event,
    required this.eventTypes,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find the event type for this event
    final eventType = eventTypes.firstWhere(
      (type) => type.name == event.category,
      orElse: () => eventTypes.first,
    );
    
    final color = eventType.getColor();
    final icon = _getIconData(eventType.icon);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category color
            Container(
              color: color.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormatUtils.formatDate(event.date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      CompactLifeTimer(
                        eventDate: event.date,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Description
                    Expanded(
                      child: Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    onPressed: onDelete,
                    tooltip: 'Delete',
                    iconSize: 20,
                  ),
                  
                  // View details button
                  TextButton.icon(
                    icon: const Icon(
                      Icons.visibility,
                      size: 18,
                    ),
                    label: const Text('View'),
                    onPressed: onTap,
                  ),
                ],
              ),
            ),
          ],
        ),
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