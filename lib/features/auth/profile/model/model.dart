// One row of the profiles table.
class ProfileModel {
  final String id;
  final String? name;
  final String? phone;
  final String role; // 'customer' or 'admin'

  const ProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  bool get hasName => name != null && name!.trim().isNotEmpty;

  ProfileModel copyWith({String? name}) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      phone: phone,
      role: role,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String,
    );
  }
}