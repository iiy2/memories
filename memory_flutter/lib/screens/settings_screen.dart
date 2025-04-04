import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memory_flutter/models/event_type.dart';
import 'package:memory_flutter/providers/auth_provider.dart';
import 'package:memory_flutter/providers/event_type_provider.dart';
import 'package:memory_flutter/utils/validators.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedColor = 'blue';
  String _selectedIcon = 'star';
  bool _isLoading = false;
  bool _isEditMode = false;
  String? _editingTypeId;
  String? _errorMessage;
  
  // Available color options
  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Red', 'value': 'red'},
    {'name': 'Pink', 'value': 'pink'},
    {'name': 'Purple', 'value': 'purple'},
    {'name': 'Deep Purple', 'value': 'deep-purple'},
    {'name': 'Indigo', 'value': 'indigo'},
    {'name': 'Blue', 'value': 'blue'},
    {'name': 'Light Blue', 'value': 'light-blue'},
    {'name': 'Cyan', 'value': 'cyan'},
    {'name': 'Teal', 'value': 'teal'},
    {'name': 'Green', 'value': 'green'},
    {'name': 'Light Green', 'value': 'light-green'},
    {'name': 'Lime', 'value': 'lime'},
    {'name': 'Yellow', 'value': 'yellow'},
    {'name': 'Amber', 'value': 'amber'},
    {'name': 'Orange', 'value': 'orange'},
    {'name': 'Deep Orange', 'value': 'deep-orange'},
    {'name': 'Brown', 'value': 'brown'},
    {'name': 'Grey', 'value': 'grey'},
    {'name': 'Blue Grey', 'value': 'blue-grey'},
  ];
  
  // Available icon options
  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'Account', 'value': 'account'},
    {'name': 'Briefcase', 'value': 'briefcase'},
    {'name': 'Home', 'value': 'home'},
    {'name': 'Heart', 'value': 'heart'},
    {'name': 'Health', 'value': 'heart-pulse'},
    {'name': 'Family', 'value': 'home-heart'},
    {'name': 'Travel', 'value': 'airplane'},
    {'name': 'School', 'value': 'school'},
    {'name': 'Book', 'value': 'book'},
    {'name': 'Food', 'value': 'food'},
    {'name': 'Sports', 'value': 'basketball'},
    {'name': 'Party', 'value': 'party-popper'},
    {'name': 'Music', 'value': 'music'},
    {'name': 'Movie', 'value': 'movie'},
    {'name': 'Game', 'value': 'gamepad-variant'},
    {'name': 'Shopping', 'value': 'cart'},
    {'name': 'Car', 'value': 'car'},
    {'name': 'Beach', 'value': 'beach'},
    {'name': 'Hiking', 'value': 'hiking'},
    {'name': 'Star', 'value': 'star'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _editEventType(EventType eventType) {
    setState(() {
      _isEditMode = true;
      _editingTypeId = eventType.id;
      _nameController.text = eventType.name;
      _selectedColor = eventType.color;
      _selectedIcon = eventType.icon;
      _errorMessage = null;
    });
  }

  void _resetForm() {
    setState(() {
      _isEditMode = false;
      _editingTypeId = null;
      _nameController.text = '';
      _selectedColor = 'blue';
      _selectedIcon = 'star';
      _errorMessage = null;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final eventTypeProvider = Provider.of<EventTypeProvider>(context, listen: false);
      
      try {
        bool success = false;
        if (_isEditMode && _editingTypeId != null) {
          // Update existing event type
          success = await eventTypeProvider.updateEventType(
            _editingTypeId!,
            {
              'name': _nameController.text.trim(),
              'color': _selectedColor,
              'icon': _selectedIcon,
            },
          );
        } else {
          // Add new event type
          success = await eventTypeProvider.addEventType(
            name: _nameController.text.trim(),
            color: _selectedColor,
            icon: _selectedIcon,
            userId: authProvider.user!.uid,
          );
        }
        
        if (success && mounted) {
          _resetForm();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode ? 'Event type updated' : 'Event type added',
              ),
            ),
          );
        } else if (mounted) {
          setState(() {
            _errorMessage = eventTypeProvider.error ?? 'Failed to save event type';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _confirmDeleteEventType(EventType eventType) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete "${eventType.name}"? This will remove this category from all events.',
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
        _errorMessage = null;
      });

      try {
        final eventTypeProvider = Provider.of<EventTypeProvider>(context, listen: false);
        final success = await eventTypeProvider.deleteEventType(eventType.id);
        
        if (success && mounted) {
          // If we're editing this event type, reset the form
          if (_isEditMode && _editingTypeId == eventType.id) {
            _resetForm();
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event type deleted')),
          );
        } else if (mounted) {
          setState(() {
            _errorMessage = eventTypeProvider.error ?? 'Failed to delete event type';
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
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _toggleEventType(EventType eventType) async {
    try {
      final eventTypeProvider = Provider.of<EventTypeProvider>(context, listen: false);
      await eventTypeProvider.toggleEventType(eventType.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventTypeProvider = Provider.of<EventTypeProvider>(context);
    final sortedEventTypes = eventTypeProvider.sortedEventTypes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: eventTypeProvider.isLoading || _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            _isEditMode ? 'Edit Event Type' : 'Add New Event Type',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Form
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Name field
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Event Type Name',
                                    hintText: 'Enter a name for this category',
                                    prefixIcon: Icon(Icons.label),
                                  ),
                                  validator: Validators.validateEventTypeName,
                                  textInputAction: TextInputAction.next,
                                  enabled: !_isLoading,
                                ),
                                const SizedBox(height: 16),
                                
                                // Color dropdown
                                DropdownButtonFormField<String>(
                                  value: _selectedColor,
                                  decoration: const InputDecoration(
                                    labelText: 'Color',
                                    prefixIcon: Icon(Icons.color_lens),
                                  ),
                                  items: _colorOptions.map((color) {
                                    return DropdownMenuItem<String>(
                                      value: color['value'],
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: _getColorFromString(color['value']),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(color['name']),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _isLoading
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedColor = value;
                                            });
                                          }
                                        },
                                ),
                                const SizedBox(height: 16),
                                
                                // Icon dropdown
                                DropdownButtonFormField<String>(
                                  value: _selectedIcon,
                                  decoration: const InputDecoration(
                                    labelText: 'Icon',
                                    prefixIcon: Icon(Icons.emoji_emotions),
                                  ),
                                  items: _iconOptions.map((icon) {
                                    return DropdownMenuItem<String>(
                                      value: icon['value'],
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getIconData(icon['value']),
                                            color: _getColorFromString(_selectedColor),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(icon['name']),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _isLoading
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedIcon = value;
                                            });
                                          }
                                        },
                                ),
                                const SizedBox(height: 24),
                                
                                // Error message
                                if (_errorMessage != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red.shade800,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                
                                // Form buttons
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: _isLoading ? null : _resetForm,
                                      child: Text(_isEditMode ? 'Cancel' : 'Reset'),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: _isLoading ? null : _submitForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(_isEditMode ? 'Update' : 'Add'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Event Types List
                  Text(
                    'Manage Event Types',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  sortedEventTypes.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No event types defined. Add your first event type!',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sortedEventTypes.length,
                          itemBuilder: (context, index) {
                            final eventType = sortedEventTypes[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: eventType.getColor(),
                                  child: Icon(
                                    _getIconData(eventType.icon),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  eventType.name,
                                  style: TextStyle(
                                    color: eventType.enabled ? null : Colors.grey,
                                  ),
                                ),
                                subtitle: eventType.enabled
                                    ? null
                                    : const Text(
                                        'Disabled',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Toggle switch
                                    Switch(
                                      value: eventType.enabled,
                                      onChanged: (value) => _toggleEventType(eventType),
                                    ),
                                    
                                    // Edit button
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editEventType(eventType),
                                      color: Colors.blue,
                                    ),
                                    
                                    // Delete button
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _confirmDeleteEventType(eventType),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
  
  // Get color from string
  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'red': return Colors.red;
      case 'pink': return Colors.pink;
      case 'purple': return Colors.purple;
      case 'deep-purple': return Colors.deepPurple;
      case 'indigo': return Colors.indigo;
      case 'blue': return Colors.blue;
      case 'light-blue': return Colors.lightBlue;
      case 'cyan': return Colors.cyan;
      case 'teal': return Colors.teal;
      case 'green': return Colors.green;
      case 'light-green': return Colors.lightGreen;
      case 'lime': return Colors.lime;
      case 'yellow': return Colors.yellow;
      case 'amber': return Colors.amber;
      case 'orange': return Colors.orange;
      case 'deep-orange': return Colors.deepOrange;
      case 'brown': return Colors.brown;
      case 'grey': return Colors.grey;
      case 'blue-grey': return Colors.blueGrey;
      default: return Colors.blue;
    }
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