// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
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

//   void _pickDateTime() async {
//     DateTime now = DateTime.now();

//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: now,
//       firstDate: now,
//       lastDate: now.add(const Duration(days: 365)),
//     );

//     if (pickedDate != null) {
//       TimeOfDay? pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );

//       if (pickedTime != null) {
//         setState(() {
//           _selectedDateTime = DateTime(
//             pickedDate.year,
//             pickedDate.month,
//             pickedDate.day,
//             pickedTime.hour,
//             pickedTime.minute,
//           );
//         });
//       }
//     }
//   }

//   /// ✅ **Generate a Unique Jitsi Meet Link**
//   String _generateMeetingLink() {
//     const String chars = "abcdefghijklmnopqrstuvwxyz0123456789";
//     final Random random = Random();
//     String roomName =
//         List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
//     return "https://meet.jit.si/$roomName";
//   }

//   /// ✅ **Schedule the Meeting and Send the Link to Chat**
//   void _scheduleMeeting() async {
//     if (_selectedDateTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select date and time")),
//       );
//       return;
//     }

//     String meetingLink = _generateMeetingLink();
//     String formattedDateTime =
//         DateFormat("yyyy-MM-dd HH:mm").format(_selectedDateTime!);

//     await _firestore
//         .collection('communities')
//         .doc(widget.communityId)
//         .collection('messages')
//         .add({
//       'message':
//           "📅 Scheduled Meeting, , CLICK ON Wait for MODERATOR\n🕒 $formattedDateTime",
//       'meetingLink': meetingLink, // ✅ Store the raw URL separately
//       'senderName': "System",
//       'senderId': "system",
//       'timestamp': FieldValue.serverTimestamp(),
//       'messageType': 'meeting', // ✅ Add a type identifier
//     });

//     setState(() {
//       _meetingLink = meetingLink;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Meeting scheduled! Link sent to chat.")),
//     );

//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Schedule Meeting")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _selectedDateTime == null
//                 ? const Text("No Date & Time Selected",
//                     style: TextStyle(fontSize: 16))
//                 : Text(
//                     "📅 Selected: ${DateFormat("yyyy-MM-dd HH:mm").format(_selectedDateTime!)}",
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _pickDateTime,
//               child: const Text("Select Date & Time"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _scheduleMeeting,
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               child: const Text("Schedule Meeting"),
//             ),
//             if (_meetingLink != null) ...[
//               const SizedBox(height: 20),
//               const Text("🔗 Meeting Link:",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               SelectableText(
//                 _meetingLink!,
//                 style: const TextStyle(
//                     color: Colors.blue,
//                     fontSize: 16,
//                     decoration: TextDecoration.underline),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class MeetingSchedulerScreen extends StatefulWidget {
  final String communityId;
  const MeetingSchedulerScreen({required this.communityId});

  @override
  _MeetingSchedulerScreenState createState() => _MeetingSchedulerScreenState();
}

class _MeetingSchedulerScreenState extends State<MeetingSchedulerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? _selectedDateTime;
  String? _meetingLink;
  TextEditingController _customMessageController = TextEditingController();
  late Stream<QuerySnapshot> _meetingStream;

  @override
  void initState() {
    super.initState();
    _meetingStream = _firestore
        .collection('communities')
        .doc(widget.communityId)
        .collection('messages')
        .where('messageType', isEqualTo: 'meeting')
        .snapshots(); // Stream of meeting data
  }

  void _pickDateTime() async {
    DateTime now = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now, // Prevent selecting past dates
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (pickedTime != null) {
        DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (selectedDateTime.isBefore(now)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a future time.")),
          );
        } else {
          setState(() {
            _selectedDateTime = selectedDateTime;
          });
        }
      }
    }
  }

  /// Generate a Unique Jitsi Meet Link
  String _generateMeetingLink() {
    const String chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    final Random random = Random();
    String roomName =
        List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
    return "https://meet.jit.si/$roomName";
  }

  /// Schedule the Meeting and Send the Link to Chat
  void _scheduleMeeting() async {
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date and time")),
      );
      return;
    }

    String meetingLink = _generateMeetingLink();
    String formattedDateTime =
        DateFormat("yyyy-MM-dd HH:mm").format(_selectedDateTime!);

    String customMessage = _customMessageController.text.trim();
    if (customMessage.isEmpty) {
      customMessage = "No additional message from the creator.";
    }

    // Store the meeting message in Firestore and get the document ID
    var meetingDocRef = await _firestore
        .collection('communities')
        .doc(widget.communityId)
        .collection('messages')
        .add({
      'message':
          "📅 Scheduled Meeting, , CLICK ON Wait for MODERATOR\n🕒 $formattedDateTime\n\n$customMessage",
      'meetingLink': meetingLink,
      'senderName': "System",
      'senderId': "system",
      'timestamp': FieldValue.serverTimestamp(),
      'messageType': 'meeting', // Add a type identifier
    });

    setState(() {
      _meetingLink = meetingLink;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Meeting scheduled! Link sent to chat.")),
    );
  }

  /// Cancel the scheduled meeting by deleting the meeting message
  void _cancelMeeting(String meetingDocId) async {
    try {
      await _firestore
          .collection('communities')
          .doc(widget.communityId)
          .collection('messages')
          .doc(meetingDocId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Meeting canceled!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error canceling the meeting: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Meeting"),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Scheduled Meetings",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Display selected date and time
            if (_selectedDateTime != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Meeting scheduled for: ${DateFormat("yyyy-MM-dd HH:mm").format(_selectedDateTime!)}",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            // StreamBuilder to display meetings
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _meetingStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No meetings scheduled"));
                  }

                  var meetings = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: meetings.length,
                    itemBuilder: (context, index) {
                      var meeting = meetings[index];
                      var formattedDateTime = DateFormat("yyyy-MM-dd HH:mm")
                          .format(meeting['timestamp'].toDate());

                      return ListTile(
                        title: Text(meeting['message']),
                        subtitle: Text("Scheduled at: $formattedDateTime"),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            _cancelMeeting(meeting.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickDateTime,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                "Select Date & Time",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _customMessageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Add a custom message (Optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleMeeting,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                "Schedule Meeting",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
