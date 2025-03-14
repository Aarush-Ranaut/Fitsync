// works with multiple models creation and joining + deletion
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'chat_screen.dart';

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

//   void _createCommunity() async {
//     if (_communityNameController.text.trim().isEmpty) return;

//     User? user = _auth.currentUser;
//     if (user == null) return;

//     await _firestore.collection('communities').add({
//       'name': _communityNameController.text.trim(),
//       'creatorId': user.uid,
//       'createdAt': Timestamp.now(),
//     });

//     _communityNameController.clear();
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

//   void _renameCommunity(String communityId, String currentName) {
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
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel")),
//           TextButton(
//             onPressed: () {
//               _firestore
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

//   void _deleteCommunity(String communityId) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Delete Community"),
//         content: const Text("Are you sure you want to delete this community?"),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel")),
//           TextButton(
//             onPressed: () {
//               _firestore.collection('communities').doc(communityId).delete();
//               Navigator.pop(context);
//             },
//             child: const Text("Delete"),
//           ),
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

//           return ListView.builder(
//             itemCount: communities.length,
//             itemBuilder: (context, index) {
//               final community = communities[index];
//               final communityId = community.id;
//               final communityName = community['name'];
//               final creatorId = community['creatorId'];

//               return ListTile(
//                 title: Text(communityName),
//                 trailing: creatorId == currentUserId
//                     ? PopupMenuButton<String>(
//                         onSelected: (value) {
//                           if (value == "rename") {
//                             _renameCommunity(communityId, communityName);
//                           } else if (value == "delete") {
//                             _deleteCommunity(communityId);
//                           }
//                         },
//                         itemBuilder: (context) => [
//                           const PopupMenuItem(
//                             value: "rename",
//                             child: Text("Rename"),
//                           ),
//                           const PopupMenuItem(
//                             value: "delete",
//                             child: Text("Delete"),
//                           ),
//                         ],
//                       )
//                     : null,
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           ChatScreen(communityId: communityId),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateCommunityDialog,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// // works with multiple models creation and joining + deletion
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'chat_screen.dart';

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

//   void _createCommunity() async {
//     if (_communityNameController.text.trim().isEmpty) return;

//     User? user = _auth.currentUser;
//     if (user == null) return;

//     await _firestore.collection('communities').add({
//       'name': _communityNameController.text.trim(),
//       'creatorId': user.uid,
//       'createdAt': Timestamp.now(),
//     });

//     _communityNameController.clear();
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

//   void _renameCommunity(String communityId, String currentName) {
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
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel")),
//           TextButton(
//             onPressed: () {
//               _firestore
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

//   void _deleteCommunity(String communityId) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Delete Community"),
//         content: const Text("Are you sure you want to delete this community?"),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel")),
//           TextButton(
//             onPressed: () {
//               _firestore.collection('communities').doc(communityId).delete();
//               Navigator.pop(context);
//             },
//             child: const Text("Delete"),
//           ),
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

//           return ListView.builder(
//             itemCount: communities.length,
//             itemBuilder: (context, index) {
//               final community = communities[index];
//               final communityId = community.id;
//               final communityName = community['name'];
//               final creatorId = community['creatorId'];

//               return ListTile(
//                 title: Text(communityName),
//                 trailing: creatorId == currentUserId
//                     ? PopupMenuButton<String>(
//                         onSelected: (value) {
//                           if (value == "rename") {
//                             _renameCommunity(communityId, communityName);
//                           } else if (value == "delete") {
//                             _deleteCommunity(communityId);
//                           }
//                         },
//                         itemBuilder: (context) => [
//                           const PopupMenuItem(
//                             value: "rename",
//                             child: Text("Rename"),
//                           ),
//                           const PopupMenuItem(
//                             value: "delete",
//                             child: Text("Delete"),
//                           ),
//                         ],
//                       )
//                     : null,
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           ChatScreen(communityId: communityId),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showCreateCommunityDialog,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// works with multiple models creation and joining + deletion + joined and not joined seperate
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'chat_screen.dart';

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

//   @override
//   void initState() {
//     super.initState();
//     _fetchJoinedCommunities();
//   }

//   Future<void> _fetchJoinedCommunities() async {
//     User? user = _auth.currentUser;
//     if (user == null) return;

//     DocumentSnapshot snapshot =
//         await _firestore.collection('community_members').doc(user.uid).get();

//     if (snapshot.exists) {
//       setState(() {
//         _joinedCommunityIds =
//             (snapshot.data() as Map<String, dynamic>).keys.toList();
//       });
//     }
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
//         .doc(user.uid)
//         .set({communityRef.id: true}, SetOptions(merge: true));

//     _communityNameController.clear();
//     _fetchJoinedCommunities(); // Refresh joined communities
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

//           List<DocumentSnapshot> joinedCommunities = [];
//           List<DocumentSnapshot> otherCommunities = [];

//           for (var community in communities) {
//             final communityId = community.id;
//             final creatorId = community['creatorId'];

//             if (_joinedCommunityIds.contains(communityId) ||
//                 creatorId == currentUserId) {
//               joinedCommunities.add(community);
//             } else {
//               otherCommunities.add(community);
//             }
//           }

//           return ListView(
//             children: [
//               // 🔹 Section for Joined Communities
//               if (joinedCommunities.isNotEmpty) ...[
//                 const Padding(
//                   padding: EdgeInsets.all(10),
//                   child: Text("Joined Communities",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ),
//                 ...joinedCommunities.map((community) {
//                   return _buildCommunityTile(community, true);
//                 }),
//               ],

//               // 🔹 Section for Other Communities
//               if (otherCommunities.isNotEmpty) ...[
//                 const Padding(
//                   padding: EdgeInsets.all(10),
//                   child: Text("Other Communities",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ),
//                 ...otherCommunities.map((community) {
//                   return _buildCommunityTile(community, false);
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

//   /// ✅ Builds a single community tile, handling joined vs. non-joined states
//   Widget _buildCommunityTile(DocumentSnapshot community, bool isJoined) {
//     final communityId = community.id;
//     final communityName = community['name'];

//     return ListTile(
//       title: Text(communityName),
//       trailing: isJoined
//           ? const Icon(Icons.check_circle,
//               color: Colors.green) // Already joined
//           : ElevatedButton(
//               onPressed: () => _joinCommunity(communityId),
//               child: const Text("Join"),
//             ),
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

//   /// ✅ Join a community
//   Future<void> _joinCommunity(String communityId) async {
//     User? user = _auth.currentUser;
//     if (user == null) return;

//     await _firestore
//         .collection('community_members')
//         .doc(communityId) // ✅ Store under communityId, NOT userId
//         .set({user.uid: true}, SetOptions(merge: true));

//     setState(() {
//       _joinedCommunityIds.add(communityId);
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Joined the community!")),
//     );
//   }
// }

//above + 3 section and deletion and leaving too FINALLLLL
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'chat_screen.dart';

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

//   /// ✅ Fetch communities the user has joined
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

//   /// ✅ Widget for section title
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
//           ? IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: () => _deleteCommunity(communityId),
//             )
//           : isJoined
//               ? TextButton(
//                   onPressed: () => _leaveCommunity(communityId),
//                   child: const Text("Leave"),
//                 )
//               : ElevatedButton(
//                   onPressed: () => _joinCommunity(communityId),
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

//   /// ✅ Delete a community (Only creator can delete)
//   Future<void> _deleteCommunity(String communityId) async {
//     User? user = _auth.currentUser;
//     if (user == null) return;

//     DocumentSnapshot communityDoc =
//         await _firestore.collection('communities').doc(communityId).get();
//     if (!communityDoc.exists || communityDoc['creatorId'] != user.uid) return;

//     await _firestore.collection('communities').doc(communityId).delete();
//     await _firestore.collection('community_members').doc(communityId).delete();

//     setState(() {
//       _ownedCommunityIds.remove(communityId);
//       _joinedCommunityIds.remove(communityId);
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Community deleted")),
//     );
//   }

//   /// ✅ Leave a community
//   Future<void> _leaveCommunity(String communityId) async {
//     User? user = _auth.currentUser;
//     if (user == null) return;

//     await _firestore.collection('community_members').doc(communityId).update({
//       user.uid: FieldValue.delete(),
//     });

//     setState(() {
//       _joinedCommunityIds.remove(communityId);
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Left the community")),
//     );
//   }

//   /// ✅ Join a community
//   Future<void> _joinCommunity(String communityId) async {
//     User? user = _auth.currentUser;
//     if (user == null) return;

//     await _firestore.collection('community_members').doc(communityId).set(
//       {user.uid: true},
//       SetOptions(merge: true),
//     );

//     setState(() {
//       _joinedCommunityIds.add(communityId);
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Joined the community!")),
//     );
//   }
// }

//latest Works
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'chat_screen.dart';

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
//                   icon: const Icon(Icons.edit, color: Colors.blue),
//                   onPressed: () => _renameCommunity(communityId, communityName),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () => _deleteCommunity(communityId),
//                 ),
//               ],
//             )
//           : isJoined
//               ? TextButton(
//                   onPressed: () => _leaveCommunity(communityId),
//                   child: const Text("Leave"),
//                 )
//               : ElevatedButton(
//                   onPressed: () => _joinCommunity(communityId),
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
import 'community_management_screen.dart'; // New screen for managing community

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

  /// ✅ Fetch joined communities
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

  /// ✅ Fetch communities created by the user
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

    // Auto-add creator as a member
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

  /// ✅ Builds a community tile
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
                  onPressed: () => _leaveCommunity(communityId),
                  child: const Text("Leave"),
                )
              : ElevatedButton(
                  onPressed: () => _joinCommunity(communityId),
                  child: const Text("Join"),
                ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(communityId: communityId),
          ),
        );
      },
    );
  }

  /// ✅ Rename a community (Only creator can rename)
  Future<void> _renameCommunity(String communityId, String currentName) async {
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
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _firestore
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
