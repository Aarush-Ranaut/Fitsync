//above + meeting link
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/chat_message.dart';

// class ChatService {
//   final String communityId;
//   ChatService({required this.communityId});

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   /// ✅ Send a normal or meeting message
//   Future<void> sendMessage(String message, {String? meetingLink}) async {
//     await _firestore
//         .collection('communities')
//         .doc(communityId)
//         .collection('messages')
//         .add({
//       'senderId': FirebaseAuth.instance.currentUser?.uid,
//       'senderName': FirebaseAuth.instance.currentUser?.displayName ?? 'Unknown',
//       'message': message,
//       'timestamp': Timestamp.now(),
//       'meetingLink': meetingLink, // ✅ Store meeting link if available
//     });
//   }

//   /// ✅ Get messages stream
//   Stream<List<ChatMessage>> getMessages() {
//     return _firestore
//         .collection('communities')
//         .doc(communityId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => ChatMessage.fromFirestore(doc))
//             .toList());
//   }

//   /// ✅ Delete a message
//   Future<void> deleteMessage(String messageId) async {
//     await _firestore
//         .collection('communities')
//         .doc(communityId)
//         .collection('messages')
//         .doc(messageId)
//         .delete();
//   }
// }

// above + deletion in 15 mins
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/chat_message.dart';

// class ChatService {
//   final String communityId;
//   ChatService({required this.communityId});

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   /// ✅ Send a normal or meeting message
//   Future<void> sendMessage(String message,
//       {String? meetingLink, String? imageUrl}) async {
//     await _firestore
//         .collection('communities')
//         .doc(communityId)
//         .collection('messages')
//         .add({
//       'senderId': FirebaseAuth.instance.currentUser?.uid,
//       'senderName': FirebaseAuth.instance.currentUser?.displayName ?? 'Unknown',
//       'message': message,
//       'timestamp': Timestamp.now(), // ✅ Correct field name
//       'meetingLink': meetingLink, // ✅ Store meeting link if available
//     });
//   }

//   /// ✅ Get messages stream
//   Stream<List<ChatMessage>> getMessages() {
//     return _firestore
//         .collection('communities')
//         .doc(communityId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true) // Was 'createdAt'
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => ChatMessage.fromFirestore(doc))
//             .toList());
//   }

//   /// ✅ Delete a message
//   Future<void> deleteMessage(String messageId) async {
//     try {
//       await _firestore
//           .collection('communities')
//           .doc(communityId)
//           .collection('messages')
//           .doc(messageId)
//           .delete();
//     } catch (e) {
//       print("Error deleting message: $e"); // ✅ Handle errors properly
//     }
//   }
// }

//above + proper name getting
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';

class ChatService {
  final String communityId;
  ChatService({required this.communityId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> _getSenderName() async {
    final user = _auth.currentUser;
    if (user == null) return 'Unknown';

    // First try displayName from auth
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }

    // Fallback to Firestore user document
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc.data()?['firstName'] ?? 'Unknown';
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }

    return 'Unknown';
  }

  Future<void> sendMessage(String message,
      {String? meetingLink, String? imageUrl}) async {
    final senderName = await _getSenderName();
    final userId = _auth.currentUser?.uid;

    if (userId == null) return;

    await _firestore
        .collection('communities')
        .doc(communityId)
        .collection('messages')
        .add({
      'senderId': userId,
      'senderName': senderName,
      'message': message,
      'timestamp': Timestamp.now(),
      'meetingLink': meetingLink,
    });
  }

  Stream<List<ChatMessage>> getMessages() {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print("Error deleting message: $e");
      rethrow;
    }
  }
}
