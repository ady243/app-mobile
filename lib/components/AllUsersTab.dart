import 'package:flutter/material.dart';

class AllUsersTab extends StatelessWidget {
  final List<dynamic> users;
  final List<dynamic> friends;
  final Map<String, String> friendRequestStatus;
  final Function(String) onSendRequest;
  final Function(String) onUserTap;

  const AllUsersTab({
    super.key,
    required this.users,
    required this.friends,
    required this.friendRequestStatus,
    required this.onSendRequest,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Rechercher des utilisateurs',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isFriend =
                  friends.any((friend) => friend['id'] == user['id']);
              final requestStatus = friendRequestStatus[user['id']];

              return ListTile(
                leading: CircleAvatar(
                  child: user['profile_picture'] != null &&
                          user['profile_picture'].isNotEmpty
                      ? Image.network(user['profile_picture'])
                      : const Icon(Icons.person),
                ),
                title: Text(user['username']),
                trailing: isFriend
                    ? const Icon(Icons.check, color: Colors.green)
                    : requestStatus == 'pending'
                        ? const Icon(Icons.hourglass_empty,
                            color: Colors.orange)
                        : IconButton(
                            icon: const Icon(Icons.person_add),
                            onPressed: () => onSendRequest(user['id']),
                          ),
                onTap: () => onUserTap(user['id']),
              );
            },
          ),
        ),
      ],
    );
  }
}
