import 'package:flutter/material.dart';
import 'package:memory_flutter/models/event_type.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final List<EventType> eventTypes;
  final Function(String) onCategorySelected;

  const CategoryFilter({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.eventTypes,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          // Get event type for the category (if not 'All')
          EventType? eventType;
          if (category != 'All') {
            eventType = eventTypes.firstWhere(
              (type) => type.name == category,
              orElse: () => eventTypes.first,
            );
          }
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              checkmarkColor: Colors.white,
              selectedColor: category == 'All' 
                  ? Theme.of(context).primaryColor 
                  : eventType?.getColor() ?? Theme.of(context).primaryColor,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(category);
                }
              },
              avatar: category != 'All' && eventType != null
                  ? Icon(
                      getIconData(eventType.icon),
                      size: 18,
                      color: isSelected ? Colors.white : eventType.getColor(),
                    )
                  : isSelected 
                      ? null 
                      : const Icon(Icons.all_inclusive, size: 18),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          );
        },
      ),
    );
  }
  
  // Convert string icon name to IconData
  IconData getIconData(String iconName) {
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