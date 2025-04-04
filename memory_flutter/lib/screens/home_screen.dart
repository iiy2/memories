import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memory_flutter/providers/auth_provider.dart';
import 'package:memory_flutter/providers/event_provider.dart';
import 'package:memory_flutter/providers/event_type_provider.dart';
import 'package:memory_flutter/screens/event_detail_screen.dart';
import 'package:memory_flutter/screens/event_form_screen.dart';
import 'package:memory_flutter/screens/settings_screen.dart';
import 'package:memory_flutter/widgets/event_card.dart';
import 'package:memory_flutter/widgets/search_bar.dart';
import 'package:memory_flutter/widgets/category_filter.dart';
import 'package:memory_flutter/models/event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize data
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final eventTypeProvider = Provider.of<EventTypeProvider>(context, listen: false);

    if (authProvider.user != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Initialize event and event type streams
        eventProvider.initializeEvents(authProvider.user!.uid);
        eventTypeProvider.initializeEventTypes(authProvider.user!.uid);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addNewEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventFormScreen()),
    );
  }

  void _viewEventDetails(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(eventId: event.id),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
  }

  Future<void> _confirmDeleteEvent(Event event) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
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
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.deleteEvent(event.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final eventTypeProvider = Provider.of<EventTypeProvider>(context);
    
    // Filter events based on search query and category
    final filteredEvents = eventProvider.getFilteredEvents(
      searchTerm: _searchQuery,
      category: _selectedCategory == 'All' ? null : _selectedCategory,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading || eventProvider.isLoading || eventTypeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SearchBar(
                    initialValue: _searchQuery,
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                    hintText: 'Search events...',
                  ),
                ),
                
                // Category filter
                CategoryFilter(
                  categories: ['All', ...eventTypeProvider.enabledEventTypes.map((e) => e.name)],
                  selectedCategory: _selectedCategory,
                  eventTypes: eventTypeProvider.eventTypes,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
                
                // Filter info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        '${filteredEvents.length} ${filteredEvents.length == 1 ? 'event' : 'events'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (_searchQuery.isNotEmpty || _selectedCategory != 'All') ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedCategory = 'All';
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_list_off,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Clear filters',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Event grid
                Expanded(
                  child: filteredEvents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty || _selectedCategory != 'All'
                                    ? 'No events match your filters'
                                    : 'No events yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_searchQuery.isEmpty && _selectedCategory == 'All')
                                ElevatedButton.icon(
                                  onPressed: _addNewEvent,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add your first event'),
                                ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            return EventCard(
                              event: event,
                              eventTypes: eventTypeProvider.eventTypes,
                              onTap: () => _viewEventDetails(event),
                              onDelete: () => _confirmDeleteEvent(event),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}