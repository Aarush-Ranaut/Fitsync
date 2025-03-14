// works with multiple comms and dlete chats possible too
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../services/chat_service.dart';
// import '../models/chat_message.dart';

// class ChatScreen extends StatefulWidget {
//   final String communityId;

//   const ChatScreen({super.key, required this.communityId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   late ChatService _chatService;

//   @override
//   void initState() {
//     super.initState();
//     _chatService = ChatService(communityId: widget.communityId);
//   }

//   @override
//   void didUpdateWidget(covariant ChatScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.communityId != widget.communityId) {
//       setState(() {
//         _chatService = ChatService(communityId: widget.communityId);
//       });
//     }
//   }

//   void _sendMessage() {
//     if (_messageController.text.trim().isNotEmpty) {
//       _chatService.sendMessage(_messageController.text.trim());
//       _messageController.clear();
//     }
//   }

//   void _confirmDeleteMessage(String messageId) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Delete Message"),
//         content: const Text("Are you sure you want to delete this message?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               _chatService.deleteMessage(messageId);
//               setState(() {}); // Ensure UI updates after deletion
//               Navigator.pop(context);
//             },
//             child: const Text("Delete", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Community Chat")),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<List<ChatMessage>>(
//               stream: _chatService.getMessages(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text("No messages yet"));
//                 }

//                 final messages = snapshot.data!;
//                 final currentUserId = FirebaseAuth.instance.currentUser?.uid;

//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final msg = messages[index];
//                     final bool isMe = msg.senderId == currentUserId;

//                     return Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 5, horizontal: 10),
//                       child: Row(
//                         mainAxisAlignment: isMe
//                             ? MainAxisAlignment.end
//                             : MainAxisAlignment.start,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: isMe ? Colors.blue[100] : Colors.grey[300],
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   msg.senderName,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 5),
//                                 Text(msg.message),
//                               ],
//                             ),
//                           ),
//                           if (isMe)
//                             IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.red),
//                               onPressed: () => _confirmDeleteMessage(msg.id),
//                             ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: "Type a message...",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: Colors.blue),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// works with multiple comms and dlete chats possible too + better GUI and auth
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import '../services/chat_service.dart';
// import '../models/chat_message.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChatScreen extends StatefulWidget {
//   final String communityId;

//   const ChatScreen({super.key, required this.communityId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   late ChatService _chatService;
//   User? get currentUser => FirebaseAuth.instance.currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _chatService = ChatService(communityId: widget.communityId);
//   }

//   @override
//   void didUpdateWidget(covariant ChatScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.communityId != widget.communityId) {
//       setState(() {
//         _chatService = ChatService(communityId: widget.communityId);
//       });
//     }
//   }

//   /// ✅ Check if the user is a member of the community
//   Future<bool> _isUserJoined() async {
//     // Get current user ID
//     String? userId = currentUser?.uid;
//     if (userId == null) return false;

//     // Fetch community details
//     DocumentSnapshot communitySnapshot = await FirebaseFirestore.instance
//         .collection('communities')
//         .doc(widget.communityId)
//         .get();

//     if (communitySnapshot.exists) {
//       Map<String, dynamic> communityData =
//           communitySnapshot.data() as Map<String, dynamic>;

//       // ✅ If the user is the community creator, return true
//       if (communityData['creatorId'] == userId) {
//         return true;
//       }
//     }

//     // Fetch community members
//     DocumentSnapshot memberSnapshot = await FirebaseFirestore.instance
//         .collection('community_members')
//         .doc(widget.communityId)
//         .get();

//     if (memberSnapshot.exists) {
//       return (memberSnapshot.data() as Map<String, dynamic>)
//           .containsKey(userId);
//     }

//     return false;
//   }

//   /// ✅ Send Message if user is a member
//   void _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;

//     bool isJoined = await _isUserJoined();
//     if (!isJoined) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text("You must join the community to send messages.")),
//       );
//       return;
//     }

//     try {
//       _chatService.sendMessage(_messageController.text.trim());
//       _messageController.clear();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error sending message: $e")),
//       );
//     }
//   }

//   /// ✅ Confirm message deletion (only allowed within 15 minutes)
//   void _confirmDeleteMessage(String messageId, Timestamp timestamp) {
//     DateTime messageTime = timestamp.toDate();
//     DateTime currentTime = DateTime.now();

//     if (currentTime.difference(messageTime).inMinutes > 15) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text("You can only delete messages within 15 minutes.")),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Delete Message"),
//         content: const Text("Are you sure you want to delete this message?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               _chatService.deleteMessage(messageId);
//               Navigator.pop(context);
//             },
//             child: const Text("Delete", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   /// ✅ Format timestamp into readable time
//   String formatTimestamp(Timestamp timestamp) {
//     DateTime dateTime = timestamp.toDate();
//     return DateFormat('h:mm a').format(dateTime); // Format as '3:45 PM'
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Community Chat")),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<List<ChatMessage>>(
//               stream: _chatService.getMessages(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text("No messages yet"));
//                 }

//                 final messages = snapshot.data!;
//                 final currentUserId = currentUser?.uid;

//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final msg = messages[index];
//                     final bool isMe = msg.senderId == currentUserId;

//                     return Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 5, horizontal: 10),
//                       child: Align(
//                         alignment:
//                             isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Column(
//                           crossAxisAlignment: isMe
//                               ? CrossAxisAlignment.end
//                               : CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color:
//                                     isMe ? Colors.blue[300] : Colors.grey[300],
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               constraints: BoxConstraints(
//                                 maxWidth:
//                                     MediaQuery.of(context).size.width * 0.75,
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     msg.senderName,
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: isMe ? Colors.white : Colors.black,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Text(
//                                     msg.message,
//                                     style: TextStyle(
//                                       color: isMe ? Colors.white : Colors.black,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Align(
//                                     alignment: Alignment.bottomRight,
//                                     child: Text(
//                                       formatTimestamp(msg.timestamp),
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: isMe
//                                             ? Colors.white70
//                                             : Colors.black54,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             if (isMe)
//                               IconButton(
//                                 icon:
//                                     const Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () => _confirmDeleteMessage(
//                                     msg.id, msg.timestamp),
//                               ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: "Type a message...",
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 15, vertical: 10),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 CircleAvatar(
//                   backgroundColor: Colors.blue,
//                   child: IconButton(
//                     icon: const Icon(Icons.send, color: Colors.white),
//                     onPressed: _sendMessage,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// works with multiple comms and delete chats possible too + better GUI and auth for user now and admin
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import '../services/chat_service.dart';
// import '../models/chat_message.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChatScreen extends StatefulWidget {
//   final String communityId;

//   const ChatScreen({super.key, required this.communityId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   late ChatService _chatService;
//   User? get currentUser => FirebaseAuth.instance.currentUser;

//   bool _hasJoined = false; // ✅ Tracks if user has joined

//   @override
//   void initState() {
//     super.initState();
//     _chatService = ChatService(communityId: widget.communityId);
//     _checkIfJoined(); // ✅ Check if user is already in the community
//   }

//   @override
//   void didUpdateWidget(covariant ChatScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.communityId != widget.communityId) {
//       setState(() {
//         _chatService = ChatService(communityId: widget.communityId);
//       });
//       _checkIfJoined(); // ✅ Recheck when community changes
//     }
//   }

//   /// ✅ Check if the user is in the community or the creator
//   Future<void> _checkIfJoined() async {
//     String? userId = currentUser?.uid;
//     if (userId == null) return;

//     // Check if user is the community creator
//     DocumentSnapshot communitySnapshot = await FirebaseFirestore.instance
//         .collection('communities')
//         .doc(widget.communityId)
//         .get();

//     if (communitySnapshot.exists) {
//       Map<String, dynamic> communityData =
//           communitySnapshot.data() as Map<String, dynamic>;

//       if (communityData['creatorId'] == userId) {
//         setState(() {
//           _hasJoined = true;
//         });
//         return;
//       }
//     }

//     // Check if user is a member
//     DocumentSnapshot memberSnapshot = await FirebaseFirestore.instance
//         .collection('community_members')
//         .doc(widget.communityId)
//         .get();

//     if (memberSnapshot.exists) {
//       Map<String, dynamic> members =
//           memberSnapshot.data() as Map<String, dynamic>;

//       if (members.containsKey(userId)) {
//         setState(() {
//           _hasJoined = true;
//         });
//       }
//     }
//   }

//   /// ✅ Allow users to join the community
//   Future<void> _joinCommunity() async {
//     String? userId = currentUser?.uid;
//     if (userId == null) return;

//     await FirebaseFirestore.instance
//         .collection('community_members')
//         .doc(widget.communityId)
//         .set({userId: true}, SetOptions(merge: true));

//     setState(() {
//       _hasJoined = true;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("You have joined the community!")),
//     );
//   }

//   /// ✅ Updated `_sendMessage` function
//   void _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;

//     if (!_hasJoined) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("You must join the community to send messages."),
//         ),
//       );
//       return;
//     }

//     _chatService.sendMessage(_messageController.text.trim());
//     _messageController.clear();
//   }

//   /// ✅ Format timestamp
//   String formatTimestamp(Timestamp timestamp) {
//     DateTime dateTime = timestamp.toDate();
//     return DateFormat('h:mm a').format(dateTime);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Community Chat")),
//       body: Column(
//         children: [
//           // ✅ Show "Join Community" button if user hasn't joined
//           if (!_hasJoined)
//             Padding(
//               padding: const EdgeInsets.all(10),
//               child: ElevatedButton(
//                 onPressed: _joinCommunity,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                 ),
//                 child: const Text("Join Community",
//                     style: TextStyle(color: Colors.white)),
//               ),
//             ),

//           // ✅ Chat Messages List
//           Expanded(
//             child: StreamBuilder<List<ChatMessage>>(
//               stream: _chatService.getMessages(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text("No messages yet"));
//                 }

//                 final messages = snapshot.data!;
//                 final currentUserId = currentUser?.uid;

//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final msg = messages[index];
//                     final bool isMe = msg.senderId == currentUserId;

//                     return Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 5, horizontal: 10),
//                       child: Align(
//                         alignment:
//                             isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Column(
//                           crossAxisAlignment: isMe
//                               ? CrossAxisAlignment.end
//                               : CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color:
//                                     isMe ? Colors.blue[300] : Colors.grey[300],
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               constraints: BoxConstraints(
//                                 maxWidth:
//                                     MediaQuery.of(context).size.width * 0.75,
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     msg.senderName,
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: isMe ? Colors.white : Colors.black,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Text(
//                                     msg.message,
//                                     style: TextStyle(
//                                       color: isMe ? Colors.white : Colors.black,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Align(
//                                     alignment: Alignment.bottomRight,
//                                     child: Text(
//                                       formatTimestamp(msg.timestamp),
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: isMe
//                                             ? Colors.white70
//                                             : Colors.black54,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             if (isMe)
//                               IconButton(
//                                 icon:
//                                     const Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () =>
//                                     _chatService.deleteMessage(msg.id),
//                               ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // ✅ Message Input Field
//           if (_hasJoined)
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _messageController,
//                       decoration: InputDecoration(
//                         hintText: "Type a message...",
//                         filled: true,
//                         fillColor: Colors.grey[200],
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 15, vertical: 10),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   CircleAvatar(
//                     backgroundColor: Colors.blue,
//                     child: IconButton(
//                       icon: const Icon(Icons.send, color: Colors.white),
//                       onPressed: _sendMessage,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

//same as above just no join button inside the chat
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/chat_service.dart';
import '../models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String communityId;

  const ChatScreen({super.key, required this.communityId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late ChatService _chatService;
  User? get currentUser => FirebaseAuth.instance.currentUser;

  bool _hasJoined = false; // ✅ Tracks if user has joined

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(communityId: widget.communityId);
    _checkIfJoined(); // ✅ Check if user is already in the community
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.communityId != widget.communityId) {
      setState(() {
        _chatService = ChatService(communityId: widget.communityId);
      });
      _checkIfJoined(); // ✅ Recheck when community changes
    }
  }

  /// ✅ Check if the user is in the community or the creator
  Future<void> _checkIfJoined() async {
    String? userId = currentUser?.uid;
    if (userId == null) return;

    // Check if user is the community creator
    DocumentSnapshot communitySnapshot = await FirebaseFirestore.instance
        .collection('communities')
        .doc(widget.communityId)
        .get();

    if (communitySnapshot.exists) {
      Map<String, dynamic> communityData =
          communitySnapshot.data() as Map<String, dynamic>;

      if (communityData['creatorId'] == userId) {
        setState(() {
          _hasJoined = true;
        });
        return;
      }
    }

    // Check if user is a member
    DocumentSnapshot memberSnapshot = await FirebaseFirestore.instance
        .collection('community_members')
        .doc(widget.communityId)
        .get();

    if (memberSnapshot.exists) {
      Map<String, dynamic> members =
          memberSnapshot.data() as Map<String, dynamic>;

      if (members.containsKey(userId)) {
        setState(() {
          _hasJoined = true;
        });
      }
    }
  }

  /// ✅ Updated `_sendMessage` function
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    if (!_hasJoined) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("You must be a member of this community to send messages."),
        ),
      );
      return;
    }

    _chatService.sendMessage(_messageController.text.trim());
    _messageController.clear();
  }

  /// ✅ Format timestamp
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Community Chat")),
      body: Column(
        children: [
          // ✅ Chat Messages List
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                final messages = snapshot.data!;
                final currentUserId = currentUser?.uid;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final bool isMe = msg.senderId == currentUserId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    isMe ? Colors.blue[300] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.senderName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    msg.message,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      formatTimestamp(msg.timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isMe
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isMe)
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _chatService.deleteMessage(msg.id),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ✅ Message Input Field (Only for members)
          if (_hasJoined)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
