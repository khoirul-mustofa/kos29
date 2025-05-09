class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      name: json['displayName'] ?? 'Pengguna',
      email: json['email'] ?? '',
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'nama': name, 'email': email, 'photo_url': photoUrl};
  }
}
