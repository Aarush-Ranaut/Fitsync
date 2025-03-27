// // works for multiple model latest + community deletion + chat deletion
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChatMessage {
//   final String id;
//   final String senderId;
//   final String senderName;
//   final String message;
//   final Timestamp timestamp;

//   ChatMessage({
//     required this.id,
//     required this.senderId,
//     required this.senderName,
//     required this.message,
//     required this.timestamp,
//   });

//   // ✅ Fix: Add a `fromDocument` method to convert Firestore data into a ChatMessage object
//   factory ChatMessage.fromDocument(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;

//     return ChatMessage(
//       id: doc.id,
//       senderId: data['senderId'] ?? '',
//       senderName: data['senderName'] ?? 'Unknown',
//       message: data['message'] ?? '',
//       timestamp: data['timestamp'] ?? Timestamp.now(),
//     );
//   }
// }

//Above + Meeting link
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final Timestamp timestamp;
  final String? meetingLink; // ✅ Add this field for meeting links
  final bool isSystemMessage; // Add this field

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.meetingLink, // ✅ Make it optional
    this.isSystemMessage = false, // Default to false
  });

  /// ✅ Convert Firestore document to ChatMessage object
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      meetingLink: data['meetingLink'], // ✅ Fetch the meeting link if available
    );
  }

  /// ✅ Convert ChatMessage to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp,
      'meetingLink': meetingLink, // ✅ Store meeting link if available
    };
  }
}
