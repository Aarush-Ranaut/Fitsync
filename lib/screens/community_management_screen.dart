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

  // Fetch members of the community
  Future<List<Map<String, String>>> _fetchMembers() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('community_members')
        .doc(widget.communityId)
        .get();

    Map<String, dynamic>? members = snapshot.data();
    if (members != null) {
      List<Map<String, String>> memberDetails = [];
      for (String memberId in members.keys) {
        // Fetch the name of the member using the memberId
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection(
                'users') // Assuming you store user info under 'users' collection
            .doc(memberId)
            .get();

        // Cast the snapshot data to Map<String, dynamic> to access the fields
        String firstName =
            (userSnapshot.data() as Map<String, dynamic>)['firstName'] ?? '';
        String lastName =
            (userSnapshot.data() as Map<String, dynamic>)['lastName'] ?? '';
        String memberName = '$firstName $lastName'.trim();

        memberDetails.add({'id': memberId, 'name': memberName});
      }
      return memberDetails;
    }
    return [];
  }

  // Kick a member from the community
  Future<void> _kickMember(String memberId) async {
    await FirebaseFirestore.instance
        .collection('community_members')
        .doc(widget.communityId)
        .update({memberId: FieldValue.delete()});
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final members = snapshot.data ?? [];

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final memberId = member['id'];
              final memberName = member['name'];

              return ListTile(
                title: Text(memberName!),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _kickMember(memberId!),
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
