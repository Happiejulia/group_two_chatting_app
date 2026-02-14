import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MessageModel {
  final String senderId;
  final String text;
  final DateTime timestamp;

  MessageModel({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      // Convert Firestore Timestamp to Dart DateTime
      timestamp: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  String get formattedTime => DateFormat('hh:mm a').format(timestamp);
  String get formattedDate => DateFormat('MMM dd, yyyy').format(timestamp);
}
