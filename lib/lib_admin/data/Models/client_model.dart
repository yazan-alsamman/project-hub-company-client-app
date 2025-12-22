class ClientModel {
  final String id;
  final String username;
  final String email;
  final Map<String, dynamic>? role;
  final bool isActive;
  final Map<String, dynamic>? companyId;
  final String? lastLogin;
  final String? createdAt;
  final String? updatedAt;
  ClientModel({
    required this.id,
    required this.username,
    required this.email,
    this.role,
    required this.isActive,
    this.companyId,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role'] is Map<String, dynamic>
          ? json['role'] as Map<String, dynamic>
          : null,
      isActive: json['isActive'] as bool? ?? true,
      companyId: json['companyId'] is Map<String, dynamic>
          ? json['companyId'] as Map<String, dynamic>
          : null,
      lastLogin: json['lastLogin']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'isActive': isActive,
      'companyId': companyId,
      'lastLogin': lastLogin,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
  String get displayName => username.isNotEmpty ? username : email;
}
