import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final DateTime date;
  final String description;
  final String category;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.category,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Copy with
  Event copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? description,
    String? category,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      description: description ?? this.description,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // From Firestore
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'description': description,
      'category': category,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}