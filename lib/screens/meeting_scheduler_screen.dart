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

  void _pickDateTime() async {
    DateTime now = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

  /// ✅ **Generate a Unique Jitsi Meet Link**
  String _generateMeetingLink() {
    const String chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    final Random random = Random();
    String roomName =
        List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
    return "https://meet.jit.si/$roomName";
  }

  /// ✅ **Schedule the Meeting and Send the Link to Chat**
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

    await _firestore
        .collection('communities')
        .doc(widget.communityId)
        .collection('messages')
        .add({
      'message':
          "📅 Scheduled Meeting, , CLICK ON Wait for MODERATOR\n🕒 $formattedDateTime",
      'meetingLink': meetingLink, // ✅ Store the raw URL separately
      'senderName': "System",
      'senderId': "system",
      'timestamp': FieldValue.serverTimestamp(),
      'messageType': 'meeting', // ✅ Add a type identifier
    });

    setState(() {
      _meetingLink = meetingLink;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Meeting scheduled! Link sent to chat.")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule Meeting")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedDateTime == null
                ? const Text("No Date & Time Selected",
                    style: TextStyle(fontSize: 16))
                : Text(
                    "📅 Selected: ${DateFormat("yyyy-MM-dd HH:mm").format(_selectedDateTime!)}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: const Text("Select Date & Time"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleMeeting,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Schedule Meeting"),
            ),
            if (_meetingLink != null) ...[
              const SizedBox(height: 20),
              const Text("🔗 Meeting Link:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SelectableText(
                _meetingLink!,
                style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    decoration: TextDecoration.underline),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
