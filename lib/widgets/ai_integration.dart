import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gemini/flutter_gemini.dart' as gemini;
import 'package:google_generative_ai/google_generative_ai.dart' as gpt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:math'; // Add this import at the top of your file
import 'package:intl/intl.dart';
import 'dart:convert';

void main() {
  const apiKey =
      'AIzaSyB1FflSFQMelsT-Ra27xsPLAlBjfsW7uLU'; // Replace with your actual Gemini API key

  /// Initialize Gemini
  gemini.Gemini.init(apiKey: apiKey);

  runApp(MaterialApp(
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    ),
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
  late final gpt.GenerativeModel _model;
  late final gpt.ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _userMessageController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode(debugLabel: 'TextField');
  bool _loading = false;
  final List<Map<String, String>> _messages = [];
  String _initialMessage = '';
  String height = 'unknown';
  String weight = 'unknown';
  int responseCounter = 0;

  @override
  void initState() {
    super.initState();
    _initializeChat(); // Initialize chat first
    _loadPreviousMessages().then((_) => _fetchUserData());
  }

  List<Map<String, String>> chatMessages = []; // Stores messages locally
  String currentUser = ""; // Set this dynamically after login

  void saveMessage(String message) {
    setState(() {
      chatMessages.add({"user": currentUser, "message": message});
    });
  }

  void _initializeChat() {
    _model = gpt.GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: widget.apiKey,
    );
    _chat = _model.startChat();
    _chat.sendMessage(
      gpt.Content.text(
        "You are a smart workout assistant. Respond only to questions related to fitness, gym, workouts, diets, or health. Politely decline unrelated queries and answer in medium-length paragraphs. Remember the User height: $height cm, weight: $weight kg for tailored advice.",
      ),
    );
  }

  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isInitialMessageSent =
          prefs.getBool('initial_message_sent') ?? false;

      if (isInitialMessageSent) return;

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

          final firstName = userDoc['firstName'] ?? 'unknown';
          final initialMessage =
              "Hi $firstName, I am your personal smart workout assistant. I see that you are 18 years old, stand $height cm tall, and weigh $weight kg. How can I assist with your workout today?";

          await _chat.sendMessage(gpt.Content.text(initialMessage));

          setState(() {
            _initialMessage = initialMessage;
            _messages.add({"sender": "AI", "message": _initialMessage});
          });

          _saveMessages();
          prefs.setBool('initial_message_sent', true);
        }
      }
    } catch (e) {
      _showError("Error fetching user data: $e");
    }
  }

  Future<void> _loadPreviousMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMessages = prefs.getStringList('chat_messages') ?? [];

    setState(() {
      _messages.clear();
      _messages.addAll(savedMessages.map((msg) {
        final parts = msg.split('|');
        return {"sender": parts[0], "message": parts[1]};
      }));
    });
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMessages =
        _messages.map((msg) => "${msg['sender']}|${msg['message']}").toList();
    await prefs.setStringList('chat_messages', savedMessages);
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

  Future<void> _sendMessage() async {
    final userMessage = _userMessageController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({"sender": "User", "message": userMessage});
      _loading = true;
    });

    _userMessageController.clear();
    _saveMessages();

    try {
      responseCounter++;
      if (responseCounter >= 5) {
        await _chat.sendMessage(
          gpt.Content.text(
            "You are a smart workout assistant. Respond only to questions related to fitness, gym, workouts, diets, or health. Politely decline unrelated queries and answer in medium-length paragraphs. Remember the User height: $height cm, weight: $weight kg for tailored advice.",
          ),
        );
        responseCounter = 0;
      }

      final response = await _chat.sendMessage(
        gpt.Content.text(userMessage),
      );

      if (response.text != null) {
        await _simulateTyping(response.text!);
        _saveMessages();
      }
    } catch (error) {
      _showError(error.toString());
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_messages');
    await prefs.setBool('initial_message_sent', false);
    setState(() {
      _messages.clear();
    });

    await _fetchUserData();
  }

  void _showError(String message) {
    FirebaseCrashlytics.instance.recordError(message, null); // Log error
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _simulateTyping(String fullMessage) async {
    const typingSpeed =
        Duration(milliseconds: 28); // Adjusted for smoother typing
    String displayedText = '';

    for (int i = 0; i < fullMessage.length; i++) {
      await Future.delayed(typingSpeed);

      setState(() {
        displayedText += fullMessage[i];
        if (_messages.isNotEmpty && _messages.last["sender"] == "AI") {
          _messages.last["message"] = displayedText;
        } else {
          _messages.add({"sender": "AI", "message": displayedText});
        }
      });

      // Smooth scroll behavior
      if (i % 5 == 0 || i == fullMessage.length - 1) {
        _scrollDown();
      }
    }
  }

  Widget _buildMessage(String message, bool isAI) {
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isAI ? Colors.green : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isAI ? Radius.zero : const Radius.circular(12),
            bottomRight: isAI ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
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
            offset: Offset(0, 0), // Centered glow effect
          ),
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2), // Extra depth with blue
            spreadRadius: 4,
            blurRadius: 25,
            offset: Offset(0, 0),
          ),
        ],
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            Color(0xFF152238), // Deep Navy Blue (Elegant & modern)
            Color(0xFF0B3D2E), // Teal-Green for richness
            Color(0xFF021C1E), // Dark Cyan-Black (Luxurious feel)
            Color(0xFF000000), // Pure Black (For contrast & depth)
          ],
          stops: [0.1, 0.4, 0.7, 1.0],
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
                        color: Color(0xFF77CF13), // Green accent
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        letterSpacing: 1.2,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Colors.cyan,
                            Colors.blue,
                            Colors.purple,
                            Colors.pink,
                            Colors.orange,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'AI',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
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
                    final bool isAI = message["sender"] == "AI";
                    final DateTime timestamp;
                    if (message["timestamp"] is String) {
                      timestamp = DateTime.tryParse(message["timestamp"]!) ??
                          DateTime.now();
                    } else if (message["timestamp"] is DateTime) {
                      timestamp = message["timestamp"] as DateTime;
                    } else {
                      timestamp = DateTime.now();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: isAI
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${timestamp.hour}:${timestamp.minute}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          _buildChatBubble(
                              context, message["message"]!, isAI, timestamp),
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

  Widget _buildChatBubble(
      BuildContext context, String message, bool isAI, DateTime dateTime) {
    return Column(
      children: [
        if (_isNewDay(dateTime)) ...[
          _buildDateHeader(dateTime),
        ],
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
            child: IntrinsicWidth(
              child: IntrinsicHeight(
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
          ),
        ),
      ],
    );
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

  DateTime? _previousDateTime;

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

// Chat input with glassmorphism effect
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
            _loading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      color: Color(0xFF77CF13),
                      strokeWidth: 3,
                    ),
                  )
                : GestureDetector(
                    onTap: _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      transform:
                          Matrix4.translationValues(0, _loading ? -3 : 0, 0),
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
}
