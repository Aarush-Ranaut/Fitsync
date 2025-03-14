// works with multiple models creation and joining
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';
// import 'chat_screen.dart';

// class CommunityScreen extends StatefulWidget {
//   const CommunityScreen({super.key});

//   @override
//   _CommunityScreenState createState() => _CommunityScreenState();
// }

// class _CommunityScreenState extends State<CommunityScreen> {
//   final TextEditingController _communityNameController =
//       TextEditingController();

//   Future<void> _createCommunity() async {
//     if (_communityNameController.text.isEmpty) return;

//     DocumentReference communityRef =
//         await FirebaseFirestore.instance.collection('communities').add({
//       'name': _communityNameController.text,
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     String communityId = communityRef.id;
//     String shareableLink = "https://yourapp.com/join?communityId=$communityId";

//     // Show the shareable link
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Community Created"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("Share this link to invite others:"),
//             SelectableText(shareableLink),
//             ElevatedButton(
//               onPressed: () {
//                 Clipboard.setData(ClipboardData(text: shareableLink));
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Link copied to clipboard")),
//                 );
//               },
//               child: const Text("Copy Link"),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context), child: const Text("OK")),
//         ],
//       ),
//     );

//     _communityNameController.clear();
//   }

//   void _joinCommunity(String communityId) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChatScreen(communityId: communityId),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Communities")),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _communityNameController,
//                     decoration: const InputDecoration(
//                       labelText: "Enter Community Name",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: _createCommunity,
//                   child: const Text("Create"),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('communities')
//                   .orderBy('createdAt', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 var communities = snapshot.data!.docs;

//                 return ListView.builder(
//                   itemCount: communities.length,
//                   itemBuilder: (context, index) {
//                     var community = communities[index];
//                     return ListTile(
//                       title: Text(community['name']),
//                       trailing: ElevatedButton(
//                         onPressed: () => _joinCommunity(community.id),
//                         child: const Text("Join"),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// works with multiple models creation and joining + deletion
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _communityNameController =
      TextEditingController();

  void _createCommunity() async {
    if (_communityNameController.text.trim().isEmpty) return;

    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('communities').add({
      'name': _communityNameController.text.trim(),
      'creatorId': user.uid,
      'createdAt': Timestamp.now(),
    });

    _communityNameController.clear();
    Navigator.pop(context);
  }

  void _showCreateCommunityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Community"),
        content: TextField(
          controller: _communityNameController,
          decoration: const InputDecoration(hintText: "Enter community name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(onPressed: _createCommunity, child: const Text("Create")),
        ],
      ),
    );
  }

  void _renameCommunity(String communityId, String currentName) {
    TextEditingController renameController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename Community"),
        content: TextField(
          controller: renameController,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _firestore
                  .collection('communities')
                  .doc(communityId)
                  .update({'name': renameController.text.trim()});
              Navigator.pop(context);
            },
            child: const Text("Rename"),
          ),
        ],
      ),
    );
  }

  void _deleteCommunity(String communityId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Community"),
        content: const Text("Are you sure you want to delete this community?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _firestore.collection('communities').doc(communityId).delete();
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Communities")),
      body: StreamBuilder(
        stream: _firestore
            .collection('communities')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final communities = snapshot.data!.docs;
          final currentUserId = _auth.currentUser?.uid;

          return ListView.builder(
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final community = communities[index];
              final communityId = community.id;
              final communityName = community['name'];
              final creatorId = community['creatorId'];

              return ListTile(
                title: Text(communityName),
                trailing: creatorId == currentUserId
                    ? PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == "rename") {
                            _renameCommunity(communityId, communityName);
                          } else if (value == "delete") {
                            _deleteCommunity(communityId);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: "rename",
                            child: Text("Rename"),
                          ),
                          const PopupMenuItem(
                            value: "delete",
                            child: Text("Delete"),
                          ),
                        ],
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(communityId: communityId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCommunityDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
