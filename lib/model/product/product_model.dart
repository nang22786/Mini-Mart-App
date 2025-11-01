class ProductResponse {
  final List<Product> data;
  final bool success;
  final int count;

  ProductResponse({
    required this.data,
    required this.success,
    required this.count,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
    );
  }
}

class Product {
  final int id;
  final String name;
  final String? detail; // ✅ Made nullable
  final double price;
  final Stock? stock; // ✅ Made nullable (in case stock deleted)
  final ProductCategory? category; // ✅ Made nullable (in case category deleted)
  final String? image;
  final DateTime? createdAt; // ✅ Made nullable
  final DateTime? updatedAt; // ✅ Made nullable

  Product({
    required this.id,
    required this.name,
    this.detail,
    required this.price,
    this.stock,
    this.category,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      detail: json['detail'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] != null
          ? Stock.fromJson(json['stock'] as Map<String, dynamic>)
          : null, // ✅ Handle null stock
      category: json['category'] != null
          ? ProductCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null, // ✅ Handle null category
      image: json['image'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'detail': detail,
      'price': price,
      'stock': stock?.toJson(),
      'category': category?.toJson(),
      'image': image,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Stock {
  final int id;
  final int qty;

  Stock({required this.id, required this.qty});

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(id: json['id'] as int? ?? 0, qty: json['qty'] as int? ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'qty': qty};
  }
}

class ProductCategory {
  final int id;
  final String name;
  final String? image; // ✅ Made nullable
  final DateTime? createdAt; // ✅ Made nullable
  final DateTime? updatedAt; // ✅ Made nullable

  ProductCategory({
    required this.id,
    required this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Uncategorized',
      image: json['image'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
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
}
