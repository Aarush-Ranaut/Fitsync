import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gemini/flutter_gemini.dart' as gemini;
import 'package:google_generative_ai/google_generative_ai.dart' as gpt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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
    _loadPreviousMessages().then((_) async {
      await _fetchUserData();
      _initializeChat();
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
      _messages.add({
        "sender": "User",
        "message": "$userMessage"
      });
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 14, 89, 17),
            Colors.black,
            Colors.black,
            Color.fromARGB(255, 14, 89, 17),
          ],
          stops: [0.0, 0.4, 0.75, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            child: AppBar(
              centerTitle: true,
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Fit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    TextSpan(
                      text: 'Sync ',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Colors.red,
                            Colors.orange,
                            Colors.yellow,
                            Colors.green,
                            Colors.blue,
                            Colors.deepPurpleAccent,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'AI',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
              child: Container(
                color: Colors.transparent,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isAI = message["sender"] == "AI";
                    return _buildMessage(message["message"]!, isAI);
                  },
                ),
              ),
            ),
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      focusNode: _textFieldFocus,
                      controller: _userMessageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ask any question',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _loading
                      ? const CircularProgressIndicator()
                      : IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(Icons.send, color: Color.fromARGB(255, 119, 207, 19)),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

