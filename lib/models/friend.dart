class Friend {
  final int userId;
  final int friendId;

  Friend({required this.userId, required this.friendId});

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'friend_id': friendId,
    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['user_id'],
      friendId: map['friend_id'],
    );
  }
}
