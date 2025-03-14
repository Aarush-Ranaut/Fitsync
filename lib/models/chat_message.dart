// class ChatMessage {
//   final String senderId;
//   final String senderName;
//   final String senderImage;
//   final String message;
//   final DateTime timestamp;

//   ChatMessage({
//     required this.senderId,
//     required this.senderName,
//     required this.senderImage,
//     required this.message,
//     required this.timestamp,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'senderId': senderId,
//       'senderName': senderName,
//       'senderImage': senderImage,
//       'message': message,
//       'timestamp': timestamp.toIso8601String(),
//     };
//   }

//   factory ChatMessage.fromJson(Map<String, dynamic> json) {
//     return ChatMessage(
//       senderId: json['senderId'],
//       senderName: json['senderName'],
//       senderImage: json['senderImage'],
//       message: json['message'],
//       timestamp: DateTime.parse(json['timestamp']),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String senderName;
  final String senderImage;
  final String message;
  final Timestamp timestamp; // 🔥 Use Firestore Timestamp instead of DateTime

  ChatMessage({
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'message': message,
      'timestamp': timestamp, // 🔥 Store Firestore Timestamp directly
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderImage: json['senderImage'],
      message: json['message'],
      timestamp: json['timestamp'] is Timestamp
          ? json['timestamp'] // 🔥 Use Firestore Timestamp directly
          : Timestamp.fromDate(DateTime.parse(
              json['timestamp'])), // 🔥 Fallback for string timestamp
    );
  }
}
