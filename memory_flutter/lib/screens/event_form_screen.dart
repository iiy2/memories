import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memory_flutter/providers/auth_provider.dart';
import 'package:memory_flutter/providers/event_provider.dart';
import 'package:memory_flutter/providers/event_type_provider.dart';
import 'package:memory_flutter/utils/validators.dart';
import 'package:intl/intl.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({Key? key}) : super(key: key);

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize selected category to the first available category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventTypeProvider = Provider.of<EventTypeProvider>(context, listen: false);
      if (eventTypeProvider.enabledEventTypes.isNotEmpty) {
        setState(() {
          _selectedCategory = eventTypeProvider.enabledEventTypes.first.name;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Allow future dates up to 1 year
    );
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategory == null) {
        setState(() {
          _errorMessage = 'Please select a category';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      
      try {
        final success = await eventProvider.addEvent(
          title: _titleController.text.trim(),
          date: _selectedDate,
          description: _descriptionController.text.trim(),
          category: _selectedCategory!,
          userId: authProvider.user!.uid,
        );
        
        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event added successfully')),
          );
        } else if (mounted) {
          setState(() {
            _errorMessage = eventProvider.error ?? 'Failed to add event';
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

  @override
  Widget build(BuildContext context) {
    final eventTypeProvider = Provider.of<EventTypeProvider>(context);
    final enabledEventTypes = eventTypeProvider.enabledEventTypes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Event'),
      ),
      body: eventTypeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : enabledEventTypes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No event categories available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please create categories in Settings first',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Event Title',
                            hintText: 'Enter the title of your event',
                            prefixIcon: Icon(Icons.title),
                          ),
                          validator: Validators.validateEventTitle,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),
                        
                        // Date
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              prefixIcon: Icon(Icons.calendar_today),
                              suffixIcon: Icon(Icons.arrow_drop_down),
                            ),
                            child: Text(
                              DateFormat.yMMMMd().format(_selectedDate),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Category
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: enabledEventTypes.map((eventType) {
                            return DropdownMenuItem<String>(
                              value: eventType.name,
                              child: Row(
                                children: [
                                  Icon(
                                    _getIconData(eventType.icon),
                                    color: eventType.getColor(),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(eventType.name),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                        ),
                        const SizedBox(height: 16),
                        
                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Describe your event',
                            prefixIcon: Icon(Icons.description),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                          textInputAction: TextInputAction.newline,
                          enabled: !_isLoading,
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
                        
                        // Submit button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                              : const Text('Add Event'),
                        ),
                      ],
                    ),
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