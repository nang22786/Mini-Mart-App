import 'package:mini_mart/model/address/address_model.dart';

class OrderModel {
  final int id;
  final int userId;
  final int? addressId;
  final String? userName;
  final String? userEmail;
  final String status;
  final double amount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? payDate;
  final int itemCount;
  final bool notificationRead; // ✅ ADD THIS
  final List<OrderItem>? items;
  final AddressModel? address;
  final PaymentModel? payment;

  OrderModel({
    required this.id,
    required this.userId,
    this.addressId,
    this.userName,
    this.userEmail,
    required this.status,
    required this.amount,
    required this.createdAt,
    this.updatedAt,
    this.payDate,
    required this.itemCount,
    this.notificationRead = false, // ✅ ADD THIS
    this.items,
    this.address,
    this.payment,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] != null
        ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList()
        : null;

    final itemCount = json['itemCount'] ?? items?.length ?? 0;

    return OrderModel(
      id: json['id'],
      userId: json['userId'],
      addressId: json['addressId'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      status: json['status'],
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      payDate: json['payDate'] != null ? DateTime.parse(json['payDate']) : null,
      itemCount: itemCount,
      notificationRead: json['notificationRead'] ?? false, // ✅ ADD THIS
      items: items,
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'])
          : null,
      payment: json['payment'] != null
          ? PaymentModel.fromJson(json['payment'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'addressId': addressId,
      'userName': userName,
      'userEmail': userEmail,
      'status': status,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'payDate': payDate?.toIso8601String(),
      'itemCount': itemCount,
      'notificationRead': notificationRead, // ✅ ADD THIS
      'items': items?.map((item) => item.toJson()).toList(),
      'address': address?.toJson(),
      'payment': payment?.toJson(),
    };
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final int qty;
  final double price;
  final double subtotal;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.qty,
    required this.price,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'],
      qty: json['qty'],
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'qty': qty,
      'price': price,
      'subtotal': subtotal,
    };
  }
}

// ✅ NEW: Payment Model
class PaymentModel {
  final int id;
  final int orderId;
  final int userId;
  final double amount;
  final String paymentMethod;
  final String currency;
  final String? screenshotPath;
  final String? transactionId;
  final DateTime? transactionDate;
  final String status;
  final DateTime? payDate;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.currency,
    this.screenshotPath,
    this.transactionId,
    this.transactionDate,
    required this.status,
    this.payDate,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      orderId: json['orderId'],
      userId: json['userId'],
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'],
      currency: json['currency'],
      screenshotPath: json['screenshotPath'],
      transactionId: json['transactionId'],
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'])
          : null,
      status: json['status'],
      payDate: json['payDate'] != null ? DateTime.parse(json['payDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'currency': currency,
      'screenshotPath': screenshotPath,
      'transactionId': transactionId,
      'transactionDate': transactionDate?.toIso8601String(),
      'status': status,
      'payDate': payDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
