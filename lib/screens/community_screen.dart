// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'chat_screen.dart';
// import 'community_management_screen.dart';

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

//   /// ✅ Updated community tile to prevent non-members from accessing chat
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
//                     _fetchJoinedCommunities();
//                     setState(() {});
//                   },
//                   child: const Text("Leave"),
//                 )
//               : ElevatedButton(
//                   onPressed: () async {
//                     await _joinCommunity(communityId);
//                     _fetchJoinedCommunities();
//                     setState(() {});
//                   },
//                   child: const Text("Join"),
//                 ),
//       onTap: () {
//         if (isJoined || isOwner) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ChatScreen(communityId: communityId),
//             ),
//           );
//         } else {
//           _showJoinToChatDialog();
//         }
//       },
//     );
//   }

//   /// ✅ Show a dialog if the user hasn't joined yet
//   void _showJoinToChatDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Join Community"),
//         content:
//             const Text("You need to join this community to access the chat."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
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
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';
import 'chat_screen.dart';
import 'community_management_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _communityNameController =
      TextEditingController();
  List<String> _joinedCommunityIds = [];
  List<String> _ownedCommunityIds = [];
  late TabController _tabController;
  bool _isLoading = true;

  // Dark theme with green accents
  final ThemeData _darkGreenTheme = ThemeData(
    primaryColor: const Color(0xFF1DB954), // Spotify green
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1DB954),
      secondary: Color(0xFF1ED760),
      surface: Color(0xFF282828),
      background: Color(0xFF121212),
      error: Color(0xFFCF6679),
    ),
    cardTheme: const CardTheme(
      color: Color(0xFF282828),
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    dividerColor: Colors.white24,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF121212),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchUserCommunities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _communityNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserCommunities() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchJoinedCommunities(),
      _fetchOwnedCommunities(),
    ]);
    setState(() => _isLoading = false);
  }

  /// Fetch joined communities
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

  /// Fetch communities created by the user
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

  Future<void> _createCommunity() async {
    if (_communityNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter a community name');
      return;
    }

    User? user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      DocumentReference communityRef =
          await _firestore.collection('communities').add({
        'name': _communityNameController.text.trim(),
        'creatorId': user.uid,
        'createdAt': Timestamp.now(),
        'description': '',
        'icon': 'default', // For future icon implementation
        'tags': [], // For categorization
      });

      // Auto-add creator as a member
      await _firestore
          .collection('community_members')
          .doc(communityRef.id)
          .set({user.uid: true}, SetOptions(merge: true));

      _communityNameController.clear();
      await _fetchUserCommunities();
      Navigator.pop(context);
      _showSnackBar('Community created successfully!');
    } catch (e) {
      _showSnackBar('Error creating community: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _darkGreenTheme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showCreateCommunityDialog() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF282828),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Create Community",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: _communityNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black45,
                  hintText: "Enter community name",
                  hintStyle: const TextStyle(color: Colors.white60),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _darkGreenTheme.colorScheme.primary, width: 2),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                cursorColor: _darkGreenTheme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _createCommunity,
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkGreenTheme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }

  // Add these new methods
  void _handleCommunityTap(String communityId, bool isOwner, bool isJoined) {
    if (isOwner || isJoined) {
      _openCommunityChat(communityId);
    } else {
      _showJoinPrompt(communityId);
    }
  }

  void _openCommunityChat(String communityId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(communityId: communityId),
      ),
    );
  }

  void _showJoinPrompt(String communityId) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF282828),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Join Community",
              style: TextStyle(color: Colors.white)),
          content: const Text(
            "You need to join this community to access its chat",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _joinCommunity(communityId).then((_) {
                  if (_joinedCommunityIds.contains(communityId)) {
                    _openCommunityChat(communityId);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkGreenTheme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Join & Enter"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _darkGreenTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Communities"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchUserCommunities,
              tooltip: "Refresh Communities",
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: _darkGreenTheme.colorScheme.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: "YOURS"),
              Tab(text: "JOINED"),
              Tab(text: "DISCOVER"),
            ],
          ),
        ),
        body: _isLoading
            ? _buildLoadingShimmer()
            : StreamBuilder(
                stream: _firestore
                    .collection('communities')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _buildLoadingShimmer();
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

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // Your Communities Tab
                      yourCommunities.isEmpty
                          ? _buildEmptyState(
                              "You haven't created any communities yet",
                              "Create your first community to start connecting with people")
                          : _buildCommunityList(yourCommunities, isOwner: true),

                      // Joined Communities Tab
                      joinedCommunities.isEmpty
                          ? _buildEmptyState(
                              "You haven't joined any communities yet",
                              "Join communities to engage with others")
                          : _buildCommunityList(joinedCommunities,
                              isJoined: true),

                      // Discover Communities Tab
                      otherCommunities.isEmpty
                          ? _buildEmptyState("No communities to discover",
                              "Check back later for new communities")
                          : _buildCommunityList(otherCommunities),
                    ],
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateCommunityDialog,
          backgroundColor: _darkGreenTheme.colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
          tooltip: "Create New Community",
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF282828),
      highlightColor: const Color(0xFF383838),
      child: ListView.builder(
        itemCount: 6,
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 80,
              color: _darkGreenTheme.colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityList(List<DocumentSnapshot> communities,
      {bool isOwner = false, bool isJoined = false}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: communities.length,
      itemBuilder: (context, index) {
        return _buildCommunityCard(communities[index],
            isOwner: isOwner, isJoined: isJoined);
      },
    );
  }

  Widget _buildCommunityCard(DocumentSnapshot community,
      {bool isOwner = false, bool isJoined = false}) {
    final communityId = community.id;
    final communityName = community['name'];

    // Generate a consistent color based on community name
    final int colorValue = communityName.hashCode & 0xFFFFFF;
    final Color avatarColor = Color(0xFF000000 | colorValue).withOpacity(0.8);

    // Get first letter for avatar
    final String avatarLetter =
        communityName.isNotEmpty ? communityName[0].toUpperCase() : "C";

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isOwner
            ? BorderSide(color: _darkGreenTheme.colorScheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _handleCommunityTap(communityId, isOwner, isJoined),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Community avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: avatarColor,
                child: Text(
                  avatarLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Community info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      communityName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (isOwner) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _darkGreenTheme.colorScheme.primary
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _darkGreenTheme.colorScheme.primary,
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          "Owner",
                          style: TextStyle(
                            color: Color(0xFF1DB954),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              if (isOwner)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.white70),
                      onPressed: () =>
                          _renameCommunity(communityId, communityName),
                      tooltip: "Rename",
                    ),
                    IconButton(
                      icon: const Icon(Icons.manage_accounts,
                          color: Color(0xFF1DB954)),
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
                      tooltip: "Manage Community",
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      onPressed: () =>
                          _showDeleteConfirmDialog(communityId, communityName),
                      tooltip: "Delete Community",
                    ),
                  ],
                )
              else
                _buildJoinButton(communityId, isJoined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinButton(String communityId, bool isJoined) {
    return isJoined
        ? OutlinedButton.icon(
            onPressed: () => _showLeaveConfirmDialog(communityId),
            icon: const Icon(Icons.exit_to_app, size: 18),
            label: const Text("Leave"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        : ElevatedButton.icon(
            onPressed: () => _joinCommunity(communityId),
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Join"),
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkGreenTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
  }

  void _showDeleteConfirmDialog(String communityId, String communityName) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF282828),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Delete Community?",
              style: TextStyle(color: Colors.white)),
          content: Text(
            "Are you sure you want to delete '$communityName'? This action cannot be undone and all messages will be permanently deleted.",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteCommunity(communityId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveConfirmDialog(String communityId) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: AlertDialog(
          backgroundColor: const Color(0xFF282828),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Leave Community?",
              style: TextStyle(color: Colors.white)),
          content: const Text(
            "Are you sure you want to leave this community? You can always join again later.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _leaveCommunity(communityId);
                Navigator.pop(context);
                _fetchJoinedCommunities();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
              ),
              child: const Text("Leave"),
            ),
          ],
        ),
      ),
    );
  }

  /// Rename a community (Only creator can rename)
  Future<void> _renameCommunity(String communityId, String currentName) async {
    TextEditingController renameController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: AlertDialog(
          backgroundColor: const Color(0xFF282828),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Rename Community",
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: renameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black45,
              hintText: "Enter new name",
              hintStyle: const TextStyle(color: Colors.white60),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: _darkGreenTheme.colorScheme.primary, width: 2),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            cursorColor: _darkGreenTheme.colorScheme.primary,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (renameController.text.trim().isEmpty) {
                  _showSnackBar("Community name cannot be empty");
                  return;
                }
                await _firestore
                    .collection('communities')
                    .doc(communityId)
                    .update({'name': renameController.text.trim()});
                Navigator.pop(context);
                _showSnackBar("Community renamed successfully");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkGreenTheme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Rename"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCommunity(String communityId) async {
    try {
      setState(() => _isLoading = true);

      // Delete community document
      await _firestore.collection('communities').doc(communityId).delete();

      // Delete community members document
      await _firestore
          .collection('community_members')
          .doc(communityId)
          .delete();

      // Delete messages (in a production app, you might want to do this in a Cloud Function)
      QuerySnapshot messagesSnapshot = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('messages')
          .get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      _showSnackBar("Community deleted successfully");
      _fetchOwnedCommunities();
    } catch (e) {
      _showSnackBar("Error deleting community: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _leaveCommunity(String communityId) async {
    try {
      setState(() => _isLoading = true);

      User? user = _auth.currentUser;
      if (user == null) return;

      // Remove user from community members
      await _firestore.collection('community_members').doc(communityId).update({
        user.uid: FieldValue.delete(),
      });

      _showSnackBar("Left community successfully");
      setState(() {
        _joinedCommunityIds.remove(communityId);
      });
    } catch (e) {
      _showSnackBar("Error leaving community: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Update the _joinCommunity method to return Future<bool>
  Future<bool> _joinCommunity(String communityId) async {
    try {
      setState(() => _isLoading = true);
      User? user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('community_members').doc(communityId).set(
        {user.uid: true},
        SetOptions(merge: true),
      );

      _showSnackBar("Joined community successfully");
      await _fetchJoinedCommunities();
      return true;
    } catch (e) {
      _showSnackBar("Error joining community: $e");
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
