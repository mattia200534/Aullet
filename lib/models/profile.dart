class Profile{
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

  factory Profile.fromMap(Map<String, dynamic> map)=>Profile(
      id: map['id'] as String,
      userId: map['userId'] as String,
      displayname: map['displayname'] as String,
      avatarUrl: map['avatarUrl'] as String?,
    );

  Map<String, dynamic> toMap()=> {
    'display_name': displayname,
    'avatar_url': avatarUrl,
  };
}
