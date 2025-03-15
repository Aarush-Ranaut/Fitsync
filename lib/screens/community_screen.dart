//latest
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'chat_screen.dart';
// import 'community_management_screen.dart'; // New screen for managing community

// class CommunityScreen extends StatefulWidget {
//   const CommunityScreen({super.key});

//   @override
//   _CommunityScreenState createState() => _CommunityScreenState();
// }

// class _CommunityScreenState extends State<CommunityScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController _communityNameController =
//       TextEditingController();
//   List<String> _joinedCommunityIds = [];
//   List<String> _ownedCommunityIds = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchJoinedCommunities();
//     _fetchOwnedCommunities();
//   }

//   /// ✅ Fetch joined communities
//   Future<void> _fetchJoinedCommunities() async {
//     User? user = _auth.currentUser;
//     if (user == null) return;

//     QuerySnapshot snapshot = await _firestore
//         .collection('community_members')
//         .where(user.uid, isEqualTo: true)
//         .get();

//     setState(() {
//       _joinedCommunityIds = snapshot.docs.map((doc) => doc.id).toList();
//     });
//   }

//   /// ✅ Fetch communities created by the user
//   Future<void> _fetchOwnedCommunities() async {
//     User? user = _auth.currentUser;
//     if (user == null) return;

//     QuerySnapshot snapshot = await _firestore
//         .collection('communities')
//         .where('creatorId', isEqualTo: user.uid)
//         .get();

//     setState(() {
//       _ownedCommunityIds = snapshot.docs.map((doc) => doc.id).toList();
//     });
//   }

//   void _createCommunity() async {
//     if (_communityNameController.text.trim().isEmpty) return;

//     User? user = _auth.currentUser;
//     if (user == null) return;

//     DocumentReference communityRef =
//         await _firestore.collection('communities').add({
//       'name': _communityNameController.text.trim(),
//       'creatorId': user.uid,
//       'createdAt': Timestamp.now(),
//     });

//     // Auto-add creator as a member
//     await _firestore
//         .collection('community_members')
//         .doc(communityRef.id)
//         .set({user.uid: true}, SetOptions(merge: true));

//     _communityNameController.clear();
//     _fetchJoinedCommunities();
//     _fetchOwnedCommunities();
//     Navigator.pop(context);
//   }

//   void _showCreateCommunityDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Create Community"),
//         content: TextField(
//           controller: _communityNameController,
//           decoration: const InputDecoration(hintText: "Enter community name"),
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel")),
//           TextButton(onPressed: _createCommunity, child: const Text("Create")),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Communities")),
//       body: StreamBuilder(
//         stream: _firestore
//             .collection('communities')
//             .orderBy('createdAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final communities = snapshot.data!.docs;
//           final currentUserId = _auth.currentUser?.uid;

//           List<DocumentSnapshot> yourCommunities = [];
//           List<DocumentSnapshot> joinedCommunities = [];
//           List<DocumentSnapshot> otherCommunities = [];

//           for (var community in communities) {
//             final communityId = community.id;
//             final creatorId = community['creatorId'];

//             if (creatorId == currentUserId) {
//               yourCommunities.add(community);
//             } else if (_joinedCommunityIds.contains(communityId)) {
//               joinedCommunities.add(community);
//             } else {
//               otherCommunities.add(community);
//             }
//           }

//           return ListView(
//             children: [
//               if (yourCommunities.isNotEmpty) ...[
//                 _sectionTitle("Your Communities"),
//                 ...yourCommunities.map((community) {
//                   return _buildCommunityTile(community, isOwner: true);
//                 }),
//               ],
//               if (joinedCommunities.isNotEmpty) ...[
//                 _sectionTitle("Joined Communities"),
//                 ...joinedCommunities.map((community) {
//                   return _buildCommunityTile(community, isJoined: true);
//                 }),
//               ],
//               if (otherCommunities.isNotEmpty) ...[
//                 _sectionTitle("Other Communities"),
//                 ...otherCommunities.map((community) {
//                   return _buildCommunityTile(community, isJoined: false);
//                 }),
//               ],
//             ],
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateCommunityDialog,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.all(10),
//       child: Text(title,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//     );
//   }

//   /// ✅ Builds a community tile
//   Widget _buildCommunityTile(DocumentSnapshot community,
//       {bool isOwner = false, bool isJoined = false}) {
//     final communityId = community.id;
//     final communityName = community['name'];

//     return ListTile(
//       title: Text(communityName),
//       trailing: isOwner
//           ? Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.manage_accounts, color: Colors.blue),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => CommunityManagementScreen(
//                           communityId: communityId,
//                           communityName: communityName,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () => _deleteCommunity(communityId),
//                 ),
//               ],
//             )
//           : isJoined
//               ? TextButton(
//                   onPressed: () async {
//                     await _leaveCommunity(communityId);
//                     // Dynamically update the community list
//                     _fetchJoinedCommunities();
//                     setState(() {});
//                   },
//                   child: const Text("Leave"),
//                 )
//               : ElevatedButton(
//                   onPressed: () async {
//                     await _joinCommunity(communityId);
//                     // Dynamically update the community list
//                     _fetchJoinedCommunities();
//                     setState(() {});
//                   },
//                   child: const Text("Join"),
//                 ),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatScreen(communityId: communityId),
//           ),
//         );
//       },
//     );
//   }

//   /// ✅ Rename a community (Only creator can rename)
//   Future<void> _renameCommunity(String communityId, String currentName) async {
//     TextEditingController renameController =
//         TextEditingController(text: currentName);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Rename Community"),
//         content: TextField(
//           controller: renameController,
//           decoration: const InputDecoration(hintText: "Enter new name"),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () async {
//               await _firestore
//                   .collection('communities')
//                   .doc(communityId)
//                   .update({'name': renameController.text.trim()});
//               Navigator.pop(context);
//             },
//             child: const Text("Rename"),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _deleteCommunity(String communityId) async {
//     await _firestore.collection('communities').doc(communityId).delete();
//     await _firestore.collection('community_members').doc(communityId).delete();
//   }

//   Future<void> _leaveCommunity(String communityId) async {
//     await _firestore.collection('community_members').doc(communityId).update({
//       _auth.currentUser!.uid: FieldValue.delete(),
//     });
//   }

//   Future<void> _joinCommunity(String communityId) async {
//     await _firestore.collection('community_members').doc(communityId).set(
//       {_auth.currentUser!.uid: true},
//       SetOptions(merge: true),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import 'community_management_screen.dart';

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
  List<String> _joinedCommunityIds = [];
  List<String> _ownedCommunityIds = [];

  @override
  void initState() {
    super.initState();
    _fetchJoinedCommunities();
    _fetchOwnedCommunities();
  }

  Future<void> _fetchJoinedCommunities() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    QuerySnapshot snapshot = await _firestore
        .collection('community_members')
        .where(user.uid, isEqualTo: true)
        .get();

    setState(() {
      _joinedCommunityIds = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> _fetchOwnedCommunities() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    QuerySnapshot snapshot = await _firestore
        .collection('communities')
        .where('creatorId', isEqualTo: user.uid)
        .get();

    setState(() {
      _ownedCommunityIds = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  void _createCommunity() async {
    if (_communityNameController.text.trim().isEmpty) return;

    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentReference communityRef =
        await _firestore.collection('communities').add({
      'name': _communityNameController.text.trim(),
      'creatorId': user.uid,
      'createdAt': Timestamp.now(),
    });

    await _firestore
        .collection('community_members')
        .doc(communityRef.id)
        .set({user.uid: true}, SetOptions(merge: true));

    _communityNameController.clear();
    _fetchJoinedCommunities();
    _fetchOwnedCommunities();
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

          List<DocumentSnapshot> yourCommunities = [];
          List<DocumentSnapshot> joinedCommunities = [];
          List<DocumentSnapshot> otherCommunities = [];

          for (var community in communities) {
            final communityId = community.id;
            final creatorId = community['creatorId'];

            if (creatorId == currentUserId) {
              yourCommunities.add(community);
            } else if (_joinedCommunityIds.contains(communityId)) {
              joinedCommunities.add(community);
            } else {
              otherCommunities.add(community);
            }
          }

          return ListView(
            children: [
              if (yourCommunities.isNotEmpty) ...[
                _sectionTitle("Your Communities"),
                ...yourCommunities.map((community) {
                  return _buildCommunityTile(community, isOwner: true);
                }),
              ],
              if (joinedCommunities.isNotEmpty) ...[
                _sectionTitle("Joined Communities"),
                ...joinedCommunities.map((community) {
                  return _buildCommunityTile(community, isJoined: true);
                }),
              ],
              if (otherCommunities.isNotEmpty) ...[
                _sectionTitle("Other Communities"),
                ...otherCommunities.map((community) {
                  return _buildCommunityTile(community, isJoined: false);
                }),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCommunityDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  /// ✅ Updated community tile to prevent non-members from accessing chat
  Widget _buildCommunityTile(DocumentSnapshot community,
      {bool isOwner = false, bool isJoined = false}) {
    final communityId = community.id;
    final communityName = community['name'];

    return ListTile(
      title: Text(communityName),
      trailing: isOwner
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.manage_accounts, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommunityManagementScreen(
                          communityId: communityId,
                          communityName: communityName,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCommunity(communityId),
                ),
              ],
            )
          : isJoined
              ? TextButton(
                  onPressed: () async {
                    await _leaveCommunity(communityId);
                    _fetchJoinedCommunities();
                    setState(() {});
                  },
                  child: const Text("Leave"),
                )
              : ElevatedButton(
                  onPressed: () async {
                    await _joinCommunity(communityId);
                    _fetchJoinedCommunities();
                    setState(() {});
                  },
                  child: const Text("Join"),
                ),
      onTap: () {
        if (isJoined || isOwner) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(communityId: communityId),
            ),
          );
        } else {
          _showJoinToChatDialog();
        }
      },
    );
  }

  /// ✅ Show a dialog if the user hasn't joined yet
  void _showJoinToChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Join Community"),
        content:
            const Text("You need to join this community to access the chat."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCommunity(String communityId) async {
    await _firestore.collection('communities').doc(communityId).delete();
    await _firestore.collection('community_members').doc(communityId).delete();
  }

  Future<void> _leaveCommunity(String communityId) async {
    await _firestore.collection('community_members').doc(communityId).update({
      _auth.currentUser!.uid: FieldValue.delete(),
    });
  }

  Future<void> _joinCommunity(String communityId) async {
    await _firestore.collection('community_members').doc(communityId).set(
      {_auth.currentUser!.uid: true},
      SetOptions(merge: true),
    );
  }
}
