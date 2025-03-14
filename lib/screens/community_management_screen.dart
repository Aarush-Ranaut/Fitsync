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
  late Future<List<Map<String, String>>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchMembers();
  }

  // Fetch members of the community and their names using a similar approach to ChatScreen
  Future<List<Map<String, String>>> _fetchMembers() async {
    try {
      // Debugging: Print the communityId being used
      print("Fetching members for community ID: ${widget.communityId}");

      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('community_members')
          .doc(widget.communityId)
          .get();

      // Debugging: Check if snapshot is successfully fetched
      print("Snapshot fetched: ${snapshot.exists}");

      Map<String, dynamic>? members = snapshot.data(); // No need to cast here

      if (members != null) {
        List<Map<String, String>> memberDetails = [];

        // Debugging: Check how many members were found
        print("Found ${members.length} members in the community.");

        for (String memberId in members.keys) {
          // Debugging: Print memberId being processed
          print("Fetching name for memberId: $memberId");

          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection(
                  'users') // Assuming user info is under 'users' collection
              .doc(memberId)
              .get();

          // Debugging: Check if the userSnapshot is successfully fetched
          if (userSnapshot.exists) {
            print("User found for memberId: $memberId");
            Map<String, dynamic> userData =
                userSnapshot.data() as Map<String, dynamic>;

            String firstName = userData['firstName'] ?? '';
            String lastName = userData['lastName'] ?? '';
            String memberName = '$firstName $lastName'.trim();

            // Debugging: Print the fetched member's name
            print("Fetched member name: $memberName");

            memberDetails.add({'id': memberId, 'name': memberName});
          } else {
            print("User not found for memberId: $memberId");
          }
        }

        return memberDetails;
      } else {
        print("No members found in the community.");
      }
    } catch (e) {
      // Debugging: Catch and print any errors that occur during fetching
      print("Error while fetching members: $e");
    }
    return [];
  }

  // Kick a member from the community
  Future<void> _kickMember(String memberId) async {
    try {
      // Debugging: Print the memberId being kicked
      print("Kicking member: $memberId");

      await FirebaseFirestore.instance
          .collection('community_members')
          .doc(widget.communityId)
          .update({memberId: FieldValue.delete()});

      // Debugging: Confirm the member has been kicked
      print("Member kicked: $memberId");
    } catch (e) {
      // Debugging: Catch and print any errors that occur during kicking
      print("Error while kicking member: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage ${widget.communityName}")),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Debugging: Print any errors that occur while building the widget
            print("Error in FutureBuilder: ${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final members = snapshot.data ?? [];

          // Debugging: Print how many members are found in FutureBuilder
          print("Total members loaded: ${members.length}");

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final memberId = member['id']!;
              final memberName = member['name']!;

              // Debugging: Print each member's name as it's displayed
              print("Displaying member: $memberName");

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
