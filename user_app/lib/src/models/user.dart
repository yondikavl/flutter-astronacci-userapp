class UserModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] is int
            ? json['id']
            : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        name: (json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        avatar: json['avatar']?.toString(),
      );
}
