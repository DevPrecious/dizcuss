import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final DateTime? createdAt;
  final List<String> members;
  final bool isPrivate;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    this.createdAt,
    required this.members,
    required this.isPrivate,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      members: List<String>.from(data['members'] ?? []),
      isPrivate: data['isPrivate'] ?? false,
      lastMessage: data['lastMessage'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
    );
  }
}
