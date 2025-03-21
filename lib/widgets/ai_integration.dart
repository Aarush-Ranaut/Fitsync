import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gemini/flutter_gemini.dart' as gemini;
import 'package:google_generative_ai/google_generative_ai.dart' as gpt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/intl.dart';

void main() {
  const apiKey = 'AIzaSyB1FflSFQMelsT-Ra27xsPLAlBjfsW7uLU';

  gemini.Gemini.init(apiKey: apiKey);

  runApp(MaterialApp(
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    ), // Added missing closing parenthesis here
    home: AIIntegration(apiKey: apiKey),
  ));
}

class AIIntegration extends StatefulWidget {
  final String apiKey;
  const AIIntegration({required this.apiKey, super.key});
  @override
  _AIIntegrationState createState() => _AIIntegrationState();
}

class _AIIntegrationState extends State<AIIntegration> {
  gpt.GenerativeModel? _model;
  gpt.ChatSession? _chat;
  bool _stopGenerating = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _userMessageController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode(debugLabel: 'TextField');
  bool _loading = false;
  final List<Map<String, dynamic>> _messages = [];
  String height = 'unknown';
  String weight = 'unknown';
  int responseCounter = 0;
  DateTime? _previousDateTime;

  @override
  void initState() {
    super.initState();
    _initializeModel();
    _loadPreviousMessages().then((_) => _fetchUserData());
  }

  void _initializeModel() {
    _model = gpt.GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: widget.apiKey,
    );
    _updateChatSession();
  }

  void _updateChatSession() {
    _chat = _model?.startChat();
    _chat?.sendMessage(gpt.Content.text(
        "You are a smart fitness assistant. Provide concise, actionable advice based on user's stats: "
        "Height: $height cm, Weight: $weight kg. Keep responses brief (1-3 sentences) unless detailed explanations are needed. "
        "Always calculate BMI and other metrics when asked using the provided stats. Format numbers clearly. "
        "Politely decline non-fitness questions. Use simple language and bullet points when helpful."));
  }

  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('initial_message_sent') ?? false) return;

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            height = userDoc['height']?.toString() ?? 'unknown';
            weight = userDoc['weight']?.toString() ?? 'unknown';
          });

          _updateChatSession(); // Update chat with new stats

          final greeting =
              "Hi ${userDoc['firstName'] ?? ''}, I'm your fitness assistant. "
              "Your stats: $height cm, $weight kg. How can I help today?";

          setState(() {
            _messages.add({
              "sender": "AI",
              "message": greeting,
              "timestamp": DateTime.now()
            });
          });
          await _saveMessages();
          prefs.setBool('initial_message_sent', true);
        }
      }
    } catch (e) {
      _showError("Error fetching data: $e");
    }
  }

  Future<void> _loadPreviousMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMessages = prefs.getStringList('chat_messages') ?? [];

    setState(() {
      _messages.clear();
      _messages.addAll(savedMessages.map((msg) {
        final parts = msg.split('|');
        return {
          "sender": parts[0],
          "message": parts[1],
          "timestamp": DateTime.parse(parts[2])
        };
      }));
    });
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMessages = _messages
        .map((msg) =>
            "${msg['sender']}|${msg['message']}|${msg['timestamp'].toIso8601String()}")
        .toList();
    await prefs.setStringList('chat_messages', savedMessages);
  }

  Future<void> _sendMessage() async {
    final message = _userMessageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
          {"sender": "User", "message": message, "timestamp": DateTime.now()});
      _loading = true;
      _stopGenerating = false;
    });
    _userMessageController.clear();
    unawaited(_saveMessages());

    try {
      final response = await _chat?.sendMessage(gpt.Content.text(message));
      if (response != null && response.text != null && !_stopGenerating) {
        await _simulateTyping(response.text!);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _simulateTyping(String text) async {
    const speed = Duration(milliseconds: 30);
    String displayed = '';

    for (int i = 0; i < text.length; i++) {
      if (_stopGenerating) break;
      await Future.delayed(speed);
      setState(() {
        displayed += text[i];
        if (_messages.last["sender"] == "AI") {
          _messages.last["message"] = displayed;
        } else {
          _messages.add({
            "sender": "AI",
            "message": displayed,
            "timestamp": DateTime.now()
          });
        }
      });
      if (i % 5 == 0) _scrollDown();
    }
    await _saveMessages();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      );
    });
  }

  Widget _buildChatBubble(
      BuildContext context, String message, bool isAI, DateTime dateTime) {
    return Column(
      children: [
        if (_isNewDay(dateTime)) _buildDateHeader(dateTime),
        Align(
          alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            constraints: BoxConstraints(
              maxWidth: 0.75 * MediaQuery.of(context).size.width,
            ),
            decoration: BoxDecoration(
              gradient: isAI
                  ? const LinearGradient(
                      colors: [Color(0xFFB4EC51), Color(0xFF9BEC00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isAI ? null : Colors.grey[850],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isAI ? 0 : 0),
                topRight: Radius.circular(isAI ? 20 : 0),
                bottomLeft: const Radius.circular(20),
                bottomRight: const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isAI ? Colors.black87 : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isNewDay(DateTime dateTime) {
    if (_previousDateTime == null) {
      _previousDateTime = dateTime;
      return true;
    }
    if (dateTime.year != _previousDateTime!.year ||
        dateTime.month != _previousDateTime!.month ||
        dateTime.day != _previousDateTime!.day) {
      _previousDateTime = dateTime;
      return true;
    }
    return false;
  }

  Widget _buildDateHeader(DateTime dateTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          DateFormat('MMMM d, yyyy').format(dateTime),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.3),
            spreadRadius: 6,
            blurRadius: 40,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            spreadRadius: 4,
            blurRadius: 25,
            offset: const Offset(0, 0),
          ),
        ],
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            const Color(0xFF152238),
            const Color(0xFF0B3D2E),
            const Color(0xFF021C1E),
            Colors.black,
          ],
          stops: const [0.1, 0.4, 0.7, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            child: AppBar(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.5),
              centerTitle: true,
              title: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Fit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const TextSpan(
                      text: 'Sync ',
                      style: TextStyle(
                        color: Color(0xFF77CF13),
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        letterSpacing: 1.2,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Transform.translate(
                        offset: const Offset(
                            0.0, -3.5), // Adjust this value as needed
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Colors.red,
                              Colors.orange,
                              Colors.yellow,
                              Colors.green,
                              Colors.blue,
                              Colors.indigo,
                              Colors.purple,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: const Text(
                            'AI',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: _clearMessages,
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isAI = message["sender"] == "AI";
                    final timestamp = message["timestamp"] as DateTime;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: isAI
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          _buildChatBubble(
                              context, message["message"], isAI, timestamp),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                autofocus: true,
                focusNode: _textFieldFocus,
                controller: _userMessageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            if (_loading)
              IconButton(
                icon: const Icon(Icons.stop, color: Colors.red),
                onPressed: () => setState(() => _stopGenerating = true),
              )
            else
              GestureDetector(
                onTap: _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(0, _loading ? -3 : 0, 0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF77CF13),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.send, color: Colors.black),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_messages');
    await prefs.setBool('initial_message_sent', false);
    setState(() => _messages.clear());
    await _fetchUserData();
  }

  void _showError(String message) {
    FirebaseCrashlytics.instance.recordError(message, null);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
