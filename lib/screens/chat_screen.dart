//works but no permssion
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
//   void _openMeetingLink(String url) async {
//     Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.inAppWebView);
//     } else {
//       await launchUrl(uri, mode: LaunchMode.inAppWebView);
//       debugPrint("Could not launch $url");
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

//                                   // ✅ Display Message or Meeting Button
//                                   if (msg.meetingLink != null &&
//                                       msg.meetingLink!.isNotEmpty)
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           msg.message,
//                                           style: TextStyle(
//                                             color: isMe
//                                                 ? Colors.white
//                                                 : Colors.black,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 10),
//                                         ElevatedButton.icon(
//                                           onPressed: () => _openMeetingLink(
//                                               msg.meetingLink!),
//                                           icon: const Icon(Icons.video_call),
//                                           label: const Text("Join Meeting"),
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.green,
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   else
//                                     Text(
//                                       msg.message,
//                                       style: TextStyle(
//                                         color:
//                                             isMe ? Colors.white : Colors.black,
//                                       ),
//                                     ),
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

//opens in browser
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
  String _communityName = "Loading...";

  // Define WhatsApp-like theme colors
  final Color _primaryColor = const Color(0xFF128C7E); // WhatsApp green
  final Color _darkGreen = const Color(0xFF075E54); // WhatsApp dark green
  final Color _lightGreen = const Color(0xFF25D366); // WhatsApp light green
  final Color _chatBackground = const Color(0xFF121B22); // Dark chat background
  final Color _appBarColor = const Color(0xFF1F2C34); // Dark app bar
  final Color _myMessageColor = const Color(0xFF005C4B); // My message bubble
  final Color _otherMessageColor = const Color(0xFF1F2C34); // Other message bubble
  final Color _inputBarColor = const Color(0xFF1F2C34); // Input bar background
  final Color _darkCardColor = const Color(0xFF2A3942); // Dark card color

  // Background pattern image
  final String _backgroundPattern = 'assets/whatsapp_background.png';
  
  @override
  void initState() {
    super.initState();
    _chatService = ChatService(communityId: widget.communityId);
    _checkIfJoined();
    _loadCommunityName();
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.communityId != widget.communityId) {
      setState(() {
        _chatService = ChatService(communityId: widget.communityId);
      });
      _checkIfJoined();
      _loadCommunityName();
    }
  }

  // Load community name
  Future<void> _loadCommunityName() async {
    try {
      DocumentSnapshot communitySnapshot = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .get();

      if (communitySnapshot.exists) {
        Map<String, dynamic> communityData =
            communitySnapshot.data() as Map<String, dynamic>;

        setState(() {
          _communityName = communityData['name'] ?? "Community Chat";
        });
      }
    } catch (e) {
      debugPrint("Error loading community name: $e");
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
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } else {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
      debugPrint("Could not launch $url");
    }
  }

  /// Get message status indicators (like WhatsApp)
  Widget _getMessageStatus(bool isMe) {
    if (!isMe) return const SizedBox.shrink();
    
    // In a real app, you would check message delivery status
    // For now, we'll just show "delivered" status
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.done_all,
          size: 16,
          color: Colors.blue[300], // Blue for read messages
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _chatBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: _appBarColor,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        colorScheme: ColorScheme.dark(
          primary: _primaryColor,
          secondary: _lightGreen,
          surface: _appBarColor,
          background: _chatBackground,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              // Community Avatar
              CircleAvatar(
                backgroundColor: _lightGreen,
                radius: 20,
                child: const Icon(
                  Icons.group,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              // Community Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _communityName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _hasJoined ? "Member" : "Not a member",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // Video call button for creator
            if (_isCreator)
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.video_call, color: _primaryColor),
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
            // More options menu
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show community options menu
                showModalBottomSheet(
                  context: context,
                  backgroundColor: _appBarColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: _primaryColor,
                          ),
                          title: const Text("Community Info"),
                          onTap: () {
                            Navigator.pop(context);
                            // Navigate to community info page
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.notifications,
                            color: _primaryColor,
                          ),
                          title: const Text("Mute Notifications"),
                          onTap: () {
                            Navigator.pop(context);
                            // Mute notifications logic
                          },
                        ),
                        if (_isCreator)
                          ListTile(
                            leading: const Icon(
                              Icons.settings,
                              color: Colors.orange,
                            ),
                            title: const Text("Community Settings"),
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to community settings
                            },
                          ),
                        if (!_hasJoined)
                          ListTile(
                            leading: Icon(
                              Icons.group_add,
                              color: _lightGreen,
                            ),
                            title: const Text("Join Community"),
                            onTap: () {
                              Navigator.pop(context);
                              // Join community logic
                            },
                          ),
                        if (_hasJoined && !_isCreator)
                          ListTile(
                            leading: const Icon(
                              Icons.exit_to_app,
                              color: Colors.red,
                            ),
                            title: const Text("Leave Community"),
                            onTap: () {
                              Navigator.pop(context);
                              // Leave community logic
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          // WhatsApp-like background pattern
          decoration: BoxDecoration(
            color: _chatBackground,
            image: DecorationImage(
              image: AssetImage(_backgroundPattern),
              opacity: 0.08, // Subtle background
              repeat: ImageRepeat.repeat,
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
                          color: _primaryColor,
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
                              color: _primaryColor.withOpacity(0.5),
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
                            if (_hasJoined)
                              Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Focus on text field
                                    FocusScope.of(context).requestFocus(
                                      FocusNode(),
                                    );
                                    _messageController.text = "Hello everyone! 👋";
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text("Start Chatting"),
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    final messages = snapshot.data!;
                    final currentUserId = currentUser?.uid;

                    // Group messages by date for WhatsApp-like date headers
                    Map<String, List<ChatMessage>> groupedMessages = {};
                    for (var msg in messages) {
                      final date = DateFormat('MMMM d, yyyy')
                          .format(msg.timestamp.toDate());
                      if (!groupedMessages.containsKey(date)) {
                        groupedMessages[date] = [];
                      }
                      groupedMessages[date]!.add(msg);
                    }

                    // Sort dates in descending order (newest first)
                    final sortedDates = groupedMessages.keys.toList()
                      ..sort((a, b) => DateFormat('MMMM d, yyyy')
                          .parse(b)
                          .compareTo(DateFormat('MMMM d, yyyy').parse(a)));

                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 16,
                        left: 8,
                        right: 8,
                      ),
                      reverse: true,
                      itemCount: sortedDates.length,
                      itemBuilder: (context, dateIndex) {
                        final date = sortedDates[dateIndex];
                        final dateMessages = groupedMessages[date]!;
                        
                        return Column(
                          children: [
                            // Date header
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _appBarColor.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Messages for this date
                            ...dateMessages.map((msg) {
                              final bool isMe = msg.senderId == currentUserId;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      // Message bubble
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? _myMessageColor
                                              : _otherMessageColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(16),
                                            topRight: const Radius.circular(16),
                                            bottomLeft: isMe
                                                ? const Radius.circular(16)
                                                : const Radius.circular(4),
                                            bottomRight: isMe
                                                ? const Radius.circular(4)
                                                : const Radius.circular(16),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(context).size.width * 0.75,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Sender name and timestamp in a row
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (!isMe)
                                                  Text(
                                                    msg.senderName,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: _lightGreen,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                if (!isMe) const Spacer(),
                                                Text(
                                                  formatTimestamp(msg.timestamp),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isMe
                                                        ? Colors.white.withOpacity(0.7)
                                                        : Colors.grey[400],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),

                                            // Message content
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
                                                  // Meeting link button
                                                  Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          _darkGreen,
                                                          _primaryColor,
                                                        ],
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: _primaryColor
                                                              .withOpacity(0.3),
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius.circular(12),
                                                        onTap: () => _openMeetingLink(
                                                            msg.meetingLink!),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 12,
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.center,
                                                            children: [
                                                              const Icon(
                                                                Icons.video_call,
                                                                color: Colors.white,
                                                              ),
                                                              const SizedBox(width: 8),
                                                              const Text(
                                                                "Join Meeting",
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
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

                                            // Message status (for sender's messages)
                                            if (isMe)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    _getMessageStatus(isMe),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // Delete option
                                      if (isMe)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                            right: 4,
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(12),
                                              onTap: () => _chatService.deleteMessage(msg.id),
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
                            }).toList(),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // Message Input Field (Only for members) - Simplified version without attachment/emoji buttons
              if (_hasJoined)
                Container(
                  decoration: BoxDecoration(
                    color: _inputBarColor,
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
                              color: _primaryColor.withOpacity(0.3),
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
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_darkGreen, _primaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.4),
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