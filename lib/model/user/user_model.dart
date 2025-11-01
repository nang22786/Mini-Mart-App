class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role;
  final String status;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.status,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phoneNumber: json['phone_number'] as String?,
        role: json['role'] as String? ?? 'customer',
        status: json['status'] as String? ?? 'active',
        image: json['image'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
        isActive: json['isActive'] as bool? ?? true,
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing UserModel: $e');
      print('📋 Stack trace: $stackTrace');
      print('📦 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'status': status,
      'image': image,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }
}
