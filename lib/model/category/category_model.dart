class CategoryModel {
  final List<Category> data;
  final bool success;
  final int count;

  CategoryModel({
    required this.data,
    required this.success,
    required this.count,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => Category.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'success': success,
      'count': count,
    };
  }
}

class Category {
  final int id;
  final String name;
  final String? image; // ✅ Made nullable
  final DateTime? createdAt; // ✅ Made nullable
  final DateTime? updatedAt; // ✅ Made nullable

  Category({
    required this.id,
    required this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unnamed',
      image: json['image'] as String?, // ✅ Can be null
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null, // ✅ Safe parsing
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null, // ✅ Safe parsing
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, image: $image, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
