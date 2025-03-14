import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'chat_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _communityNameController =
      TextEditingController();

  Future<void> _createCommunity() async {
    if (_communityNameController.text.isEmpty) return;

    DocumentReference communityRef =
        await FirebaseFirestore.instance.collection('communities').add({
      'name': _communityNameController.text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    String communityId = communityRef.id;
    String shareableLink = "https://yourapp.com/join?communityId=$communityId";

    // Show the shareable link
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Community Created"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Share this link to invite others:"),
            SelectableText(shareableLink),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: shareableLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Link copied to clipboard")),
                );
              },
              child: const Text("Copy Link"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );

    _communityNameController.clear();
  }

  void _joinCommunity(String communityId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(communityId: communityId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Communities")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _communityNameController,
                    decoration: const InputDecoration(
                      labelText: "Enter Community Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _createCommunity,
                  child: const Text("Create"),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('communities')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var communities = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: communities.length,
                  itemBuilder: (context, index) {
                    var community = communities[index];
                    return ListTile(
                      title: Text(community['name']),
                      trailing: ElevatedButton(
                        onPressed: () => _joinCommunity(community.id),
                        child: const Text("Join"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
