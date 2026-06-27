class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? profileImage;
  final String? skinType;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.profileImage,
    this.skinType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'] ?? json['image'],
      skinType: json['skinType'] ?? json['skin_type'],
    );
  }
}
