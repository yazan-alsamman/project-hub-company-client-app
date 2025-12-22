class RoleModel {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  RoleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
