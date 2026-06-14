class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.displayName = '',
    this.avatarUrl,
    this.role = 'user',
    this.bio = '',
  });

  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final String bio;

  String get initials {
    if (displayName.isNotEmpty) {
      final parts = displayName.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName[0].toUpperCase();
    }
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  UserModel copyWith({
    String? displayName,
    String? email,
    String? avatarUrl,
    String? bio,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'role': role,
        'bio': bio,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'user',
      bio: json['bio'] as String? ?? '',
    );
  }
}
