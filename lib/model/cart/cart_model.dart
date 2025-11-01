import 'package:mini_mart/model/product/product_model.dart';

class CartItem {
  final int id;
  final int userId;
  final int productId;
  final int qty;
  final String createdAt;
  final String updatedAt;
  final Product? product;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.qty,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  // Factory constructor for JSON deserialization
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      productId: json['product_id'] as int,
      qty: json['qty'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  // Method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'qty': qty,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'product': product?.toJson(),
    };
  }

  // Method to calculate subtotal
  double getSubtotal() {
    if (product != null) {
      return product!.price * qty;
    }
    return 0.0;
  }

  // Method to check if item is valid
  bool isValid() {
    return id > 0 && userId > 0 && productId > 0 && qty > 0;
  }

  // Method to create a copy with updated fields
  CartItem copyWith({
    int? id,
    int? userId,
    int? productId,
    int? qty,
    String? createdAt,
    String? updatedAt,
    Product? product,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      product: product ?? this.product,
    );
  }

  @override
  String toString() {
    return 'CartItem(id: $id, userId: $userId, productId: $productId, qty: $qty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Cart Summary Model
class CartSummary {
  final int totalItems;
  final double totalPrice;
  final int itemCount;
  final List<CartItem> items;

  CartSummary({
    required this.totalItems,
    required this.totalPrice,
    required this.itemCount,
    required this.items,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      totalItems: json['totalItems'] as int? ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      itemCount: json['itemCount'] as int? ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'totalPrice': totalPrice,
      'itemCount': itemCount,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  @override
  String toString() {
    return 'CartSummary(totalItems: $totalItems, totalPrice: $totalPrice, itemCount: $itemCount)';
  }
}
