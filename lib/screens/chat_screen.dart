//opens in browser
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import '../services/chat_service.dart';
// import '../models/chat_message.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'meeting_scheduler_screen.dart'; // Import the meeting scheduler screen
// import 'package:url_launcher/url_launcher.dart';

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

//   /// ✅ Open Meeting Link
//   Future<void> _launchMeetingLink(String meetingLink) async {
//     final Uri meetingUri = Uri.parse(meetingLink);
//     print(meetingUri);
//     if (await canLaunch(meetingUri.toString())) {
//       await launch(meetingUri.toString());
//     } else {
//       throw 'Could not launch $meetingUri';
//     }
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
//                     final DateTime messageTime = msg.timestamp.toDate();
//                     final Duration difference =
//                         DateTime.now().difference(messageTime);
//                     final bool within15Minutes = difference.inMinutes <= 15;

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

//                                   // ✅ Display Message or Meeting Link Inside the Text
//                                   Text.rich(
//                                     TextSpan(
//                                       children: [
//                                         TextSpan(
//                                           text: msg.message,
//                                           style: TextStyle(
//                                             color: isMe
//                                                 ? Colors.white
//                                                 : Colors.black,
//                                           ),
//                                         ),
//                                         if (msg.meetingLink != null &&
//                                             msg.meetingLink!.isNotEmpty)
//                                           TextSpan(
//                                             text: ' Join Meeting',
//                                             style: TextStyle(
//                                               color: Colors.blue,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                             recognizer: TapGestureRecognizer()
//                                               ..onTap = () =>
//                                                   _launchMeetingLink(
//                                                       msg.meetingLink!),
//                                           ),
//                                       ],
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

//                             // ✅ Delete Button for Sent Messages
//                             if ((isMe && within15Minutes) || _isCreator)
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
import 'meeting_scheduler_screen.dart';
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
  bool _isCreator = false;

  // Define theme colors
  final Color _primaryGreen = const Color(0xFF2ECC71);
  final Color _darkGreen = const Color(0xFF27AE60);
  final Color _lightGreen = const Color(0xFF7DCEA0);
  final Color _darkBackground = const Color(0xFF121212);
  final Color _darkSurface = const Color(0xFF1E1E1E);
  final Color _darkCardColor = const Color(0xFF252525);

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

  Future<void> _checkIfJoined() async {
    String? userId = currentUser?.uid;

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
          _isCreator = true;
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

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    if (!_hasJoined) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "You must be a member of this community to send messages.",
          ),
          backgroundColor: _darkGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    _chatService.sendMessage(_messageController.text.trim());
    _messageController.clear();
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('h:mm a').format(dateTime);
  }

  void _openMeetingLink(String url) async {
    final Uri meetingUri = Uri.parse(url);
    print(meetingUri);
    if (await canLaunch(meetingUri.toString())) {
      await launch(meetingUri.toString());
    } else {
      throw 'Could not launch $meetingUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _darkBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: _darkSurface,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        colorScheme: ColorScheme.dark(
          primary: _primaryGreen,
          secondary: _lightGreen,
          surface: _darkSurface,
          background: _darkBackground,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Community Chat"),
          actions: [
            if (_isCreator)
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.video_call, color: _primaryGreen),
                  tooltip: "Schedule Meeting",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeetingSchedulerScreen(
                          communityId: widget.communityId,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_darkBackground, _darkBackground.withOpacity(0.9)],
            ),
          ),
          child: Column(
            children: [
              // Chat Messages List
              Expanded(
                child: StreamBuilder<List<ChatMessage>>(
                  stream: _chatService.getMessages(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: _primaryGreen,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 60,
                              color: _primaryGreen.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No messages yet",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Be the first to start the conversation!",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final messages = snapshot.data!;
                    final currentUserId = currentUser?.uid;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final bool isMe = msg.senderId == currentUserId;

                        // Calculate time constraints
                        DateTime messageTime = msg.timestamp.toDate();
                        Duration difference =
                            DateTime.now().difference(messageTime);
                        bool within15Minutes = difference.inMinutes <= 15;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isMe ? _primaryGreen : _darkCardColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(18),
                                      topRight: const Radius.circular(18),
                                      bottomLeft: isMe
                                          ? const Radius.circular(18)
                                          : const Radius.circular(4),
                                      bottomRight: isMe
                                          ? const Radius.circular(4)
                                          : const Radius.circular(18),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.75,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            msg.senderName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isMe
                                                  ? Colors.white
                                                  : _lightGreen,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            formatTimestamp(msg.timestamp),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isMe
                                                  ? Colors.white
                                                      .withOpacity(0.7)
                                                  : Colors.grey[400],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Display Message or Meeting Button
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
                                                    : Colors.grey[200],
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _darkGreen,
                                                    _primaryGreen,
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _primaryGreen
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _openMeetingLink(
                                                        msg.meetingLink!),
                                                icon: const Icon(
                                                  Icons.video_call,
                                                  color: Colors.white,
                                                ),
                                                label: const Text(
                                                  "Join Meeting",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        Text(
                                          msg.message,
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white
                                                : Colors.grey[200],
                                            fontSize: 15,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Delete Button for Sent Messages
                                if ((isMe && within15Minutes) || _isCreator)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4,
                                      right: 4,
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () =>
                                            _chatService.deleteMessage(msg.id),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.delete_outline,
                                                color: Colors.red[300],
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "Delete",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red[300],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
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

              // Message Input Field (Only for members)
              if (_hasJoined)
                Container(
                  decoration: BoxDecoration(
                    color: _darkSurface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _darkCardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _primaryGreen.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: _primaryGreen,
                                ),
                                onPressed: () {
                                  // Emoji picker functionality could be added here
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_darkGreen, _primaryGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryGreen.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: _sendMessage,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              child: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
