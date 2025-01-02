class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['SenderID'] ?? '',
      receiverId: json['ReceiverID'] ?? '',
      content: json['Content'] ?? '',
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
