import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventType {
  final String id;
  final String name;
  final String color;
  final String icon;
  final bool enabled;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventType({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.enabled,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Copy with
  EventType copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
    bool? enabled,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventType(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      enabled: enabled ?? this.enabled,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Toggle enabled status
  EventType toggleEnabled() {
    return copyWith(enabled: !enabled);
  }

  // From Firestore
  factory EventType.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventType(
      id: doc.id,
      name: data['name'] ?? '',
      color: data['color'] ?? 'blue',
      icon: data['icon'] ?? 'star',
      enabled: data['enabled'] ?? true,
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'color': color,
      'icon': icon,
      'enabled': enabled,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Get the color as a Flutter Color object
  Color getColor() {
    switch (color) {
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

  // Default event types for new users
  static List<Map<String, dynamic>> getDefaultEventTypes(String userId) {
    final now = DateTime.now();
    return [
      {
        'name': 'Personal',
        'color': 'blue',
        'icon': 'account',
        'enabled': true,
        'userId': userId,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      },
      {
        'name': 'Work',
        'color': 'amber',
        'icon': 'briefcase',
        'enabled': true,
        'userId': userId,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      },
      {
        'name': 'Family',
        'color': 'pink',
        'icon': 'home-heart',
        'enabled': true,
        'userId': userId,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      },
      {
        'name': 'Health',
        'color': 'green',
        'icon': 'heart-pulse',
        'enabled': true,
        'userId': userId,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      },
      {
        'name': 'Travel',
        'color': 'purple',
        'icon': 'airplane',
        'enabled': true,
        'userId': userId,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      },
      {
        'name': 'Other',
        'color': 'grey',
        'icon': 'star',
        'enabled': true,
        'userId': userId,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      },
    ];
  }
}