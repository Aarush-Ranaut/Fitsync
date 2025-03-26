//with jetsi
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MeetingSchedulerScreen extends StatefulWidget {
  final String communityId;
  const MeetingSchedulerScreen({super.key, required this.communityId});

  @override
  _MeetingSchedulerScreenState createState() => _MeetingSchedulerScreenState();
}

class _MeetingSchedulerScreenState extends State<MeetingSchedulerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? _selectedDateTime;
  String? _meetingLink;
  bool _isScheduling = false;

  // Define theme colors
  final Color _primaryGreen = const Color(0xFF2ECC71);
  final Color _darkGreen = const Color(0xFF27AE60);
  final Color _lightGreen = const Color(0xFF7DCEA0);
  final Color _darkBackground = const Color(0xFF121212);
  final Color _darkSurface = const Color(0xFF1E1E1E);
  final Color _darkCardColor = const Color(0xFF252525);

  // Add in _MeetingSchedulerScreenState class
  final String _apiKey =
      'b9edf393855b265697c87b4074d8832faf1ed8982c239bfe8faec528bb7367f4';
  late Stream<QuerySnapshot> _meetingStream;

  @override
  void initState() {
    super.initState();
    _meetingStream = _firestore
        .collection('communities')
        .doc(widget.communityId)
        .collection('messages')
        .where('messageType', isEqualTo: 'meeting')
        .orderBy('scheduledTime')
        .snapshots();
  }

  Future<String> _createMeetingRoom() async {
    try {
      final response = await http.post(
        Uri.parse('https://api.daily.co/v1/rooms'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'properties': {
            'enable_chat': true,
            'enable_screenshare': true,
            'max_participants': 10,
            'exp': _selectedDateTime!
                    .add(const Duration(hours: 1))
                    .millisecondsSinceEpoch ~/
                1000,
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final room = json.decode(response.body);
        return room['url'];
      } else {
        throw Exception('Failed to create room: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create room: $e');
    }
  }

  void _pickDateTime() async {
    DateTime now = DateTime.now();

    // Custom date picker theme
    final ThemeData theme = ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: _primaryGreen,
        onPrimary: Colors.white,
        surface: _darkCardColor,
        onSurface: Colors.white,
      ),
      dialogBackgroundColor: _darkSurface,
    );

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: theme,
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: theme,
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  /// Generate a Unique Jitsi Meet Link
  // String _generateMeetingLink() {
  //   const String chars = "abcdefghijklmnopqrstuvwxyz0123456789";
  //   final Random random = Random();
  //   String roomName =
  //       List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  //   return "https://meet.jit.si/$roomName";
  // }

  void _cancelMeeting(String meetingDocId) async {
    try {
      await _firestore
          .collection('communities')
          .doc(widget.communityId)
          .collection('messages')
          .doc(meetingDocId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Meeting canceled!"),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error canceling meeting: $e"),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  /// Schedule the Meeting and Send the Link to Chat
  Future<void> _scheduleMeeting() async {
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select date and time"),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isScheduling = true;
    });

    try {
      String meetingLink = await _createMeetingRoom();
      String formattedDateTime =
          DateFormat("yyyy-MM-dd HH:mm").format(_selectedDateTime!);

      await _firestore
          .collection('communities')
          .doc(widget.communityId)
          .collection('messages')
          .add({
        'message':
            "📅 Scheduled Meeting\n🕒 $formattedDateTime\n👥 Click the button below to join when it's time",
        'meetingLink': meetingLink,
        'scheduledTime': Timestamp.fromDate(_selectedDateTime!),
        'senderName': "System",
        'senderId': "system",
        'timestamp': FieldValue.serverTimestamp(),
        'messageType': 'meeting',
      });

      setState(() {
        _meetingLink = meetingLink;
        _isScheduling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Meeting scheduled! Link sent to chat."),
          backgroundColor: _darkGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: _darkCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: _primaryGreen),
              const SizedBox(width: 10),
              const Text(
                "Meeting Scheduled",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your meeting has been scheduled for:",
                style: TextStyle(color: Colors.grey[300]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _darkBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _primaryGreen.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: _primaryGreen),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat("EEEE, MMMM d, yyyy")
                          .format(_selectedDateTime!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _darkBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _primaryGreen.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: _primaryGreen),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat("h:mm a").format(_selectedDateTime!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Meeting link has been sent to the community chat.",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                "Done",
                style: TextStyle(color: _primaryGreen),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isScheduling = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error scheduling meeting: ${e.toString()}"),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
          title: const Text("Schedule Meeting"),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline, color: _primaryGreen),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: _darkCardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: [
                        Icon(Icons.info, color: _primaryGreen),
                        const SizedBox(width: 10),
                        const Text(
                          "About Meetings",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    content: const Text(
                      "Scheduled meetings will be announced in the community chat. Members can join by clicking the meeting link at the scheduled time.",
                      style: TextStyle(color: Colors.white),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Got it"),
                      ),
                    ],
                  ),
                );
              },
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header section with illustration
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_call,
                          size: 80,
                          color: _primaryGreen.withOpacity(0.8),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Schedule a Community Meeting",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Select a date and time for your meeting.\nA link will be shared in the community chat.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Date & Time selection section
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _darkCardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "MEETING DETAILS",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _primaryGreen,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Date & Time display
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _darkBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedDateTime != null
                                  ? _primaryGreen.withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: _primaryGreen,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _selectedDateTime == null
                                    ? Text(
                                        "No date & time selected",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[500],
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat("EEEE, MMMM d, yyyy")
                                                .format(_selectedDateTime!),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat("h:mm a")
                                                .format(_selectedDateTime!),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[300],
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Date & Time picker button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _primaryGreen.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _pickDateTime,
                            icon: Icon(
                              Icons.access_time,
                              color: _primaryGreen,
                            ),
                            label: Text(
                              _selectedDateTime == null
                                  ? "Select Date & Time"
                                  : "Change Date & Time",
                              style: TextStyle(
                                color: _primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _darkBackground,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Schedule button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_darkGreen, _primaryGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryGreen.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isScheduling ? null : _scheduleMeeting,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isScheduling
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        "Scheduling...",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    "Schedule Meeting",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Add this widget after the bottom note in the build method
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: _darkCardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _meetingStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                                  color: _primaryGreen));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              "No upcoming meetings",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var meeting = snapshot.data!.docs[index];
                            var data = meeting.data() as Map<String, dynamic>;
                            DateTime scheduledTime =
                                (data['scheduledTime'] as Timestamp).toDate();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: _darkSurface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: Icon(Icons.video_camera_back_rounded,
                                    color: _primaryGreen),
                                title: Text(
                                  DateFormat("MMM dd, yyyy - h:mm a")
                                      .format(scheduledTime),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  "Daily.co Meeting",
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete_forever,
                                      color: Colors.red[400]),
                                  onPressed: () => _cancelMeeting(meeting.id),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Bottom note
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 8),
                  child: Text(
                    "Meeting links will be automatically shared in the community chat",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//launching the url in chrome with Daily.co
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'dart:math';

// class MeetingSchedulerScreen extends StatefulWidget {
//   final String communityId;
//   const MeetingSchedulerScreen({required this.communityId});

//   @override
//   _MeetingSchedulerScreenState createState() => _MeetingSchedulerScreenState();
// }

// class _MeetingSchedulerScreenState extends State<MeetingSchedulerScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   DateTime? _selectedDateTime;
//   String? _meetingLink;
//   TextEditingController _customMessageController = TextEditingController();
//   late Stream<QuerySnapshot> _meetingStream;

//   // Daily.co API key
//   final String _apiKey =
//       'b9edf393855b265697c87b4074d8832faf1ed8982c239bfe8faec528bb7367f4';

//   @override
//   void initState() {
//     super.initState();
//     _meetingStream = _firestore
//         .collection('communities')
//         .doc(widget.communityId)
//         .collection('messages')
//         .where('messageType', isEqualTo: 'meeting')
//         .snapshots(); // Stream of meeting data
//   }

//   void _pickDateTime() async {
//     DateTime now = DateTime.now();

//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: now,
//       firstDate: now, // Prevent selecting past dates
//       lastDate: now.add(const Duration(days: 365)),
//     );

//     if (pickedDate != null) {
//       TimeOfDay? pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.fromDateTime(now),
//       );

//       if (pickedTime != null) {
//         DateTime selectedDateTime = DateTime(
//           pickedDate.year,
//           pickedDate.month,
//           pickedDate.day,
//           pickedTime.hour,
//           pickedTime.minute,
//         );

//         if (selectedDateTime.isBefore(now)) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Please select a future time.")),
//           );
//         } else {
//           setState(() {
//             _selectedDateTime = selectedDateTime;
//           });
//         }
//       }
//     }
//   }

//   // Function to create a room (video conference) on Daily.co
//   Future<String> _createMeetingRoom() async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://api.daily.co/v1/rooms'),
//         headers: {
//           'Authorization': 'Bearer $_apiKey',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'properties': {
//             'enable_chat': true,
//             'enable_screenshare': true,
//             'max_participants': 10,
//           }
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final room = json.decode(response.body);
//         String meetingUrl = room['url']; // Getting the URL from the response
//         return meetingUrl; // Return the meeting URL
//       } else {
//         print(
//             "Failed to create a meeting room. Status code: ${response.statusCode}");
//         print("Response body: ${response.body}");
//         throw Exception('Failed to create a meeting room');
//       }
//     } catch (e) {
//       print("Error: $e");
//       throw Exception('Failed to create a meeting room');
//     }
//   }

//   // Schedule the Meeting and Send the Link to Chat
//   void _scheduleMeeting() async {
//     if (_selectedDateTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select date and time")),
//       );
//       return;
//     }

//     try {
//       String meetingLink = await _createMeetingRoom();
//       String formattedDateTime =
//           DateFormat("yyyy-MM-dd HH:mm").format(_selectedDateTime!);

//       String customMessage = _customMessageController.text.trim();
//       if (customMessage.isEmpty) {
//         customMessage = "No additional message from the creator.";
//       }

//       // Store the meeting message in Firestore and get the document ID
//       var meetingDocRef = await _firestore
//           .collection('communities')
//           .doc(widget.communityId)
//           .collection('messages')
//           .add({
//         'message':
//             "📅 Scheduled Meeting, , CLICK ON Wait for MODERATOR\n🕒 $formattedDateTime\n\n$customMessage",
//         'meetingLink': meetingLink,
//         'senderName': "System",
//         'senderId': "system",
//         'timestamp': FieldValue.serverTimestamp(),
//         'messageType': 'meeting', // Add a type identifier
//       });

//       setState(() {
//         _meetingLink = meetingLink;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Meeting scheduled! Link sent to chat.")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to schedule meeting")),
//       );
//     }
//   }

//   // Cancel the scheduled meeting by deleting the meeting message
//   void _cancelMeeting(String meetingDocId) async {
//     try {
//       await _firestore
//           .collection('communities')
//           .doc(widget.communityId)
//           .collection('messages')
//           .doc(meetingDocId)
//           .delete();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Meeting canceled!")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error canceling the meeting: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Schedule Meeting"),
//         backgroundColor: Colors.teal,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Scheduled Meetings",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             // Display selected date and time
//             if (_selectedDateTime != null)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Text(
//                   "Meeting scheduled for: ${DateFormat("yyyy-MM-dd HH:mm").format(_selectedDateTime!)}",
//                   style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                 ),
//               ),
//             // StreamBuilder to display meetings
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: _meetingStream,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   if (snapshot.hasError) {
//                     return Center(child: Text("Error: ${snapshot.error}"));
//                   }

//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text("No meetings scheduled"));
//                   }

//                   var meetings = snapshot.data!.docs;
//                   return ListView.builder(
//                     itemCount: meetings.length,
//                     itemBuilder: (context, index) {
//                       var meeting = meetings[index];
//                       var formattedDateTime = DateFormat("yyyy-MM-dd HH:mm")
//                           .format(meeting['timestamp'].toDate());

//                       return ListTile(
//                         title: Text(meeting['message']),
//                         subtitle: Text("Scheduled at: $formattedDateTime"),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.cancel, color: Colors.red),
//                           onPressed: () {
//                             _cancelMeeting(meeting.id);
//                           },
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _pickDateTime,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.teal,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//               ),
//               child: const Text(
//                 "Select Date & Time",
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _customMessageController,
//               maxLines: 3,
//               decoration: InputDecoration(
//                 labelText: "Add a custom message (Optional)",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[100],
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _scheduleMeeting,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//               ),
//               child: const Text(
//                 "Schedule Meeting",
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
