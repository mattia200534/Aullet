class Profile {
  final String id;
  final String userId;
  String displayname;
  String? avatarUrl;

  Profile({
    required this.id,
    required this.userId,
    required this.displayname,
    this.avatarUrl,
  });

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    id: map['id'] as String,
    userId: map['user_id'] as String,
    displayname: map['display_name'] as String,
    avatarUrl: map['avatar_url'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'display_name': displayname,
    'avatar_url': avatarUrl,
  };
}
