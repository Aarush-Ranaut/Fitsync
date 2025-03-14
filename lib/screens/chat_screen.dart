//same as above just no join button inside the chat
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

//   /// ✅ Updated `_sendMessage` function
//   void _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;

//     if (!_hasJoined) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content:
//               Text("You must be a member of this community to send messages."),
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

//           // ✅ Message Input Field (Only for members)
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

//same as above just no join button inside the chat + video Conferencing FINALLL
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import '../services/chat_service.dart';
// import '../models/chat_message.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'meeting_scheduler_screen.dart'; // Import the meeting scheduler screen

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

//   bool _hasJoined = false;
//   bool _isCreator = false; // ✅ Tracks if the user is the creator

//   @override
//   void initState() {
//     super.initState();
//     _chatService = ChatService(communityId: widget.communityId);
//     _checkIfJoined();
//   }

//   @override
//   void didUpdateWidget(covariant ChatScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.communityId != widget.communityId) {
//       setState(() {
//         _chatService = ChatService(communityId: widget.communityId);
//       });
//       _checkIfJoined();
//     }
//   }

//   /// ✅ Check if the user is in the community or the creator
//   Future<void> _checkIfJoined() async {
//     String? userId = currentUser?.uid;
//     if (userId == null) return;

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
//           _isCreator = true; // ✅ User is the creator
//         });
//         return;
//       }
//     }

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

//   /// ✅ Send a Message
//   void _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;

//     if (!_hasJoined) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content:
//               Text("You must be a member of this community to send messages."),
//         ),
//       );
//       return;
//     }

//     _chatService.sendMessage(_messageController.text.trim());
//     _messageController.clear();
//   }

//   /// ✅ Format Timestamp
//   String formatTimestamp(Timestamp timestamp) {
//     DateTime dateTime = timestamp.toDate();
//     return DateFormat('h:mm a').format(dateTime);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Community Chat"),
//         actions: [
//           // ✅ Show video call button only for the creator
//           if (_isCreator)
//             IconButton(
//               icon: const Icon(Icons.video_call),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         MeetingSchedulerScreen(communityId: widget.communityId),
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
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

//           // ✅ Message Input Field (Only for members)
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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/chat_service.dart';
import '../models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'meeting_scheduler_screen.dart'; // Import the meeting scheduler screen
import 'package:url_launcher/url_launcher.dart';

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

  bool _hasJoined = false;
  bool _isCreator = false; // ✅ Tracks if the user is the creator

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(communityId: widget.communityId);
    _checkIfJoined();
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.communityId != widget.communityId) {
      setState(() {
        _chatService = ChatService(communityId: widget.communityId);
      });
      _checkIfJoined();
    }
  }

  /// ✅ Check if the user is in the community or the creator
  Future<void> _checkIfJoined() async {
    String? userId = currentUser?.uid;
    if (userId == null) return;

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
          _isCreator = true; // ✅ User is the creator
        });
        return;
      }
    }

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

  /// ✅ Send a Message
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

  /// ✅ Format Timestamp
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('h:mm a').format(dateTime);
  }

  /// ✅ Open Meeting Link
  void _openMeetingLink(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } else {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Chat"),
        actions: [
          // ✅ Show video call button only for the creator
          if (_isCreator)
            IconButton(
              icon: const Icon(Icons.video_call),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MeetingSchedulerScreen(communityId: widget.communityId),
                  ),
                );
              },
            ),
        ],
      ),
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

                                  // ✅ Display Message or Meeting Button
                                  if (msg.meetingLink != null &&
                                      msg.meetingLink!.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg.message,
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton.icon(
                                          onPressed: () => _openMeetingLink(
                                              msg.meetingLink!),
                                          icon: const Icon(Icons.video_call),
                                          label: const Text("Join Meeting"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      msg.message,
                                      style: TextStyle(
                                        color:
                                            isMe ? Colors.white : Colors.black,
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

                            // ✅ Delete Button for Sent Messages
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
