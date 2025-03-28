//single community but works
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/chat_message.dart';

// class ChatService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> sendMessage(String message) async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     // Fetch user data
//     DocumentSnapshot userDoc =
//         await _firestore.collection('users').doc(user.uid).get();
//     // ignore: prefer_interpolation_to_compose_strings
//     String senderName = userDoc['firstName'] + " " + userDoc['lastName'];
//     String senderImage = userDoc['profileImage'];

//     ChatMessage chatMessage = ChatMessage(
//       senderId: user.uid,
//       senderName: senderName,
//       senderImage: senderImage,
//       message: message,
//       timestamp: DateTime.now(),
//     );

//     await _firestore.collection('chats').add(chatMessage.toJson());
//   }

//   Stream<List<ChatMessage>> getMessages() {
//     return _firestore
//         .collection('chats')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => ChatMessage.fromJson(doc.data()))
//           .toList();
//     });
//   }
// }

//Deletion + above
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fitsync_app/models/chat_message.dart';
// import 'package:flutter/material.dart';

// class ChatService {
//   final String communityId;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   ChatService({required this.communityId});

//   Stream<List<ChatMessage>> getMessages() {
//     return _firestore
//         .collection('communities')
//         .doc(communityId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return ChatMessage.fromDocument(doc);
//       }).toList();
//     });
//   }

//   Future<void> sendMessage(String message) async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     await _firestore
//         .collection('communities')
//         .doc(communityId)
//         .collection('messages')
//         .add({
//       'senderId': user.uid,
//       'senderName': user.displayName ?? "User",
//       'message': message,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> deleteMessage(String messageId) async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     DocumentSnapshot messageDoc = await _firestore
//         .collection('communities')
//         .doc(communityId)
//         .collection('messages')
//         .doc(messageId)
//         .get();

//     if (messageDoc.exists) {
//       Map<String, dynamic> data = messageDoc.data() as Map<String, dynamic>;
//       Timestamp timestamp = data['timestamp'];

//       if (user.uid == data['senderId'] &&
//           DateTime.now().difference(timestamp.toDate()).inMinutes < 15) {
//         await messageDoc.reference.delete();
//       } else {
//         debugPrint("❌ Cannot delete after 15 minutes.");
//       }
//     }
//   }
// }

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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';

class ChatService {
  final String communityId;
  ChatService({required this.communityId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Send a normal or meeting message
  Future<void> sendMessage(String message,
      {String? meetingLink, String? imageUrl}) async {
    await _firestore
        .collection('communities')
        .doc(communityId)
        .collection('messages')
        .add({
      'senderId': FirebaseAuth.instance.currentUser?.uid,
      'senderName': FirebaseAuth.instance.currentUser?.displayName ?? 'Unknown',
      'message': message,
      'timestamp': Timestamp.now(), // ✅ Correct field name
      'meetingLink': meetingLink, // ✅ Store meeting link if available
    });
  }

  /// ✅ Get messages stream
  Stream<List<ChatMessage>> getMessages() {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // Was 'createdAt'
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  /// ✅ Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print("Error deleting message: $e"); // ✅ Handle errors properly
    }
  }
}