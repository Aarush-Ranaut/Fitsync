// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CommunityManagementScreen extends StatefulWidget {
//   final String communityId;
//   final String communityName;

//   const CommunityManagementScreen(
//       {super.key, required this.communityId, required this.communityName});

//   @override
//   _CommunityManagementScreenState createState() =>
//       _CommunityManagementScreenState();
// }

// class _CommunityManagementScreenState extends State<CommunityManagementScreen> {
//   late Stream<List<Map<String, String>>> _membersStream;
//   late String communityCreatorId;

//   @override
//   void initState() {
//     super.initState();
//     _membersStream = Stream.value([]); // Initial empty stream
//     _fetchCreatorId();
//   }

//   // Fetch the creator's ID from the community document
//   Future<void> _fetchCreatorId() async {
//     try {
//       DocumentSnapshot communitySnapshot = await FirebaseFirestore.instance
//           .collection('communities')
//           .doc(widget.communityId)
//           .get();
//       if (communitySnapshot.exists) {
//         communityCreatorId = communitySnapshot['creatorId'];
//         setState(() {
//           _membersStream =
//               _fetchMembersStream(); // Update the stream after creatorId is fetched
//         });
//       }
//     } catch (e) {
//       print("Error fetching creator ID: $e");
//     }
//   }

//   // Fetch members of the community and their names
//   Stream<List<Map<String, String>>> _fetchMembersStream() {
//     return FirebaseFirestore.instance
//         .collection('community_members')
//         .doc(widget.communityId)
//         .snapshots()
//         .asyncMap((snapshot) async {
//       Map<String, dynamic>? members = snapshot.data();
//       List<Map<String, String>> memberDetails = [];

//       if (members != null) {
//         // Iterate over members and exclude the creator
//         for (String memberId in members.keys) {
//           if (memberId == communityCreatorId) continue; // Skip the creator

//           DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
//               .collection('users')
//               .doc(memberId)
//               .get();

//           if (userSnapshot.exists) {
//             Map<String, dynamic> userData =
//                 userSnapshot.data() as Map<String, dynamic>;

//             String firstName = userData['firstName'] ?? '';
//             String lastName = userData['lastName'] ?? '';
//             String memberName = '$firstName $lastName'.trim();

//             memberDetails.add({'id': memberId, 'name': memberName});
//           }
//         }
//       }
//       return memberDetails;
//     });
//   }

//   // Kick a member from the community
//   Future<void> _kickMember(String memberId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('community_members')
//           .doc(widget.communityId)
//           .update({memberId: FieldValue.delete()});
//     } catch (e) {
//       print("Error while kicking member: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Manage ${widget.communityName}")),
//       body: StreamBuilder<List<Map<String, String>>>(
//         stream: _membersStream,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           final members = snapshot.data ?? [];

//           return ListView.builder(
//             itemCount: members.length,
//             itemBuilder: (context, index) {
//               final member = members[index];
//               final memberId = member['id']!;
//               final memberName = member['name']!;
//               return ListTile(
//                 title: Text(memberName),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.remove_circle, color: Colors.red),
//                   onPressed: () => _kickMember(memberId),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               _renameCommunity(context);
//             },
//             child: const Text("Rename Community"),
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }

//   void _renameCommunity(BuildContext context) {
//     TextEditingController controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Rename Community"),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(hintText: "New Community Name"),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () async {
//               await FirebaseFirestore.instance
//                   .collection('communities')
//                   .doc(widget.communityId)
//                   .update({'name': controller.text.trim()});
//               Navigator.pop(context);
//             },
//             child: const Text("Rename"),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityManagementScreen extends StatefulWidget {
  final String communityId;
  final String communityName;

  const CommunityManagementScreen(
      {super.key, required this.communityId, required this.communityName});

  @override
  _CommunityManagementScreenState createState() =>
      _CommunityManagementScreenState();
}

class _CommunityManagementScreenState extends State<CommunityManagementScreen> {
  late Stream<List<Map<String, String>>> _membersStream;
  late String communityCreatorId;

  // Define theme colors
  final Color _primaryGreen = const Color(0xFF2ECC71);
  final Color _darkGreen = const Color(0xFF27AE60);
  final Color _lightGreen = const Color(0xFF7DCEA0);
  final Color _darkBackground = const Color(0xFF121212);
  final Color _darkSurface = const Color(0xFF1E1E1E);
  final Color _darkCardColor = const Color(0xFF252525);

  @override
  void initState() {
    super.initState();
    _membersStream = Stream.value([]); // Initial empty stream
    _fetchCreatorId();
  }

  // Fetch the creator's ID from the community document
  Future<void> _fetchCreatorId() async {
    try {
      DocumentSnapshot communitySnapshot = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .get();
      if (communitySnapshot.exists) {
        communityCreatorId = communitySnapshot['creatorId'];
        setState(() {
          _membersStream =
              _fetchMembersStream(); // Update the stream after creatorId is fetched
        });
      }
    } catch (e) {
      print("Error fetching creator ID: $e");
    }
  }

  // Fetch members of the community and their names
  Stream<List<Map<String, String>>> _fetchMembersStream() {
    return FirebaseFirestore.instance
        .collection('community_members')
        .doc(widget.communityId)
        .snapshots()
        .asyncMap((snapshot) async {
      Map<String, dynamic>? members = snapshot.data();
      List<Map<String, String>> memberDetails = [];

      if (members != null) {
        // Iterate over members and exclude the creator
        for (String memberId in members.keys) {
          if (memberId == communityCreatorId) continue; // Skip the creator

          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(memberId)
              .get();

          if (userSnapshot.exists) {
            Map<String, dynamic> userData =
                userSnapshot.data() as Map<String, dynamic>;

            String firstName = userData['firstName'] ?? '';
            String lastName = userData['lastName'] ?? '';
            String memberName = '$firstName $lastName'.trim();

            memberDetails.add({'id': memberId, 'name': memberName});
          }
        }
      }
      return memberDetails;
    });
  }

  // Kick a member from the community
  Future<void> _kickMember(String memberId, String memberName) async {
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: _darkCardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Remove Member",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                "Are you sure you want to remove $memberName from this community?",
                style: TextStyle(color: Colors.grey[300]),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Remove"),
                ),
              ],
            ),
          ) ??
          false;

      if (confirm) {
        await FirebaseFirestore.instance
            .collection('community_members')
            .doc(widget.communityId)
            .update({memberId: FieldValue.delete()});

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$memberName has been removed from the community"),
            backgroundColor: _darkGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print("Error while kicking member: $e");
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to remove member: $e"),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _renameCommunity(BuildContext context) {
    TextEditingController controller = TextEditingController();
    controller.text = widget.communityName; // Pre-fill with current name

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _darkCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.edit, color: _primaryGreen),
            const SizedBox(width: 10),
            const Text(
              "Rename Community",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "New Community Name",
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: _darkBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: _primaryGreen.withOpacity(0.3), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryGreen, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_darkGreen, _primaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('communities')
                      .doc(widget.communityId)
                      .update({'name': controller.text.trim()});
                  Navigator.pop(context);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Community renamed to ${controller.text.trim()}"),
                      backgroundColor: _darkGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                "Rename",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _darkBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: _darkSurface,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        colorScheme: ColorScheme.dark(
          primary: _primaryGreen,
          secondary: _lightGreen,
          surface: _darkSurface,
          background: _darkBackground,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Manage ${widget.communityName}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Icon(Icons.info_outline, color: _primaryGreen),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: _darkCardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Row(
                        children: [
                          Icon(Icons.info, color: _primaryGreen),
                          const SizedBox(width: 10),
                          const Text(
                            "Community Management",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      content: const Text(
                        "As a community creator, you can manage members and rename your community. Swipe left on a member to remove them.",
                        style: TextStyle(color: Colors.white),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Got it"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_darkBackground, _darkBackground.withOpacity(0.9)],
            ),
          ),
          child: StreamBuilder<List<Map<String, String>>>(
            stream: _membersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: _primaryGreen,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[300],
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red[300]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final members = snapshot.data ?? [];

              if (members.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 60,
                        color: _primaryGreen.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No members in this community yet",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Invite people to join your community!",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  final memberId = member['id']!;
                  final memberName = member['name']!;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Dismissible(
                      key: Key(memberId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red[700]!.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Remove",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: _darkCardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text(
                              "Remove Member",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              "Are you sure you want to remove $memberName from this community?",
                              style: TextStyle(color: Colors.grey[300]),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Remove"),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        _kickMember(memberId, memberName);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _darkCardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: _primaryGreen.withOpacity(0.2),
                            child: Text(
                              memberName.isNotEmpty
                                  ? memberName[0].toUpperCase()
                                  : "?",
                              style: TextStyle(
                                color: _primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            memberName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: const Text(
                            "Community Member",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red[300],
                            ),
                            onPressed: () => _kickMember(memberId, memberName),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_darkGreen, _primaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _primaryGreen.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            label: const Text(
              "Rename Community",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => _renameCommunity(context),
          ),
        ),
      ),
    );
  }
}
