import 'package:flutter/material.dart';

class FriendRequestsTab extends StatelessWidget {
  final List<dynamic> friendRequests;
  final Function(String) onAccept;
  final Function(String) onDecline;

  const FriendRequestsTab({
    super.key,
    required this.friendRequests,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: friendRequests.length,
      itemBuilder: (context, index) {
        final request = friendRequests[index];
        return ListTile(
          leading: CircleAvatar(
            child: request['sender']['profile_picture'] != null &&
                    request['sender']['profile_picture'].isNotEmpty
                ? Image.network(request['sender']['profile_picture'])
                : const Icon(Icons.person),
          ),
          title: Text(request['sender']['username']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => onAccept(request['sender_id']),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => onDecline(request['sender_id']),
              ),
            ],
          ),
        );
      },
    );
  }
}
