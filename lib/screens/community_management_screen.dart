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
//   // Stream to listen to the community members' updates in real time
//   late Stream<List<Map<String, String>>> _membersStream;

//   @override
//   void initState() {
//     super.initState();
//     _membersStream = _fetchMembersStream();
//   }

//   // Fetch members of the community and their names using a similar approach to ChatScreen
//   Stream<List<Map<String, String>>> _fetchMembersStream() {
//     return FirebaseFirestore.instance
//         .collection('community_members')
//         .doc(widget.communityId)
//         .snapshots()
//         .asyncMap((snapshot) async {
//       Map<String, dynamic>? members = snapshot.data(); // No need to cast here
//       List<Map<String, String>> memberDetails = [];

//       if (members != null) {
//         for (String memberId in members.keys) {
//           DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
//               .collection(
//                   'users') // Assuming user info is under 'users' collection
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
  Future<void> _kickMember(String memberId) async {
    try {
      await FirebaseFirestore.instance
          .collection('community_members')
          .doc(widget.communityId)
          .update({memberId: FieldValue.delete()});
    } catch (e) {
      print("Error while kicking member: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage ${widget.communityName}")),
      body: StreamBuilder<List<Map<String, String>>>(
        stream: _membersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final members = snapshot.data ?? [];

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final memberId = member['id']!;
              final memberName = member['name']!;
              return ListTile(
                title: Text(memberName),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _kickMember(memberId),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              _renameCommunity(context);
            },
            child: const Text("Rename Community"),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _renameCommunity(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename Community"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "New Community Name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('communities')
                  .doc(widget.communityId)
                  .update({'name': controller.text.trim()});
              Navigator.pop(context);
            },
            child: const Text("Rename"),
          ),
        ],
      ),
    );
  }
}
