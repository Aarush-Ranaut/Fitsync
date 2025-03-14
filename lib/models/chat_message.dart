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

//works for multiple model latest
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChatMessage {
//   final String senderId;
//   final String senderName;
//   final String senderImage;
//   final String message;
//   final Timestamp timestamp; // 🔥 Use Firestore Timestamp instead of DateTime

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
//       'timestamp': timestamp, // 🔥 Store Firestore Timestamp directly
//     };
//   }

//   factory ChatMessage.fromJson(Map<String, dynamic> json) {
//     return ChatMessage(
//       senderId: json['senderId'],
//       senderName: json['senderName'],
//       senderImage: json['senderImage'],
//       message: json['message'],
//       timestamp: json['timestamp'] is Timestamp
//           ? json['timestamp'] // 🔥 Use Firestore Timestamp directly
//           : Timestamp.fromDate(DateTime.parse(
//               json['timestamp'])), // 🔥 Fallback for string timestamp
//     );
//   }
// }

// works for multiple model latest + deletion
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChatMessage {
//   final String id; // 🔥 Added message ID for deletion
//   final String senderId;
//   final String senderName;
//   final String senderImage;
//   final String message;
//   final Timestamp timestamp;

//   ChatMessage({
//     required this.id,
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
//       'timestamp': timestamp,
//     };
//   }

//   factory ChatMessage.fromJson(String id, Map<String, dynamic> json) {
//     return ChatMessage(
//       id: id,
//       senderId: json['senderId'],
//       senderName: json['senderName'],
//       senderImage: json['senderImage'],
//       message: json['message'],
//       timestamp: json['timestamp'] is Timestamp
//           ? json['timestamp']
//           : Timestamp.fromDate(DateTime.parse(json['timestamp'])),
//     );
//   }
// }

// works for multiple model latest + community deletion + chat deletion
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final Timestamp timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });

  // ✅ Fix: Add a `fromDocument` method to convert Firestore data into a ChatMessage object
  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
