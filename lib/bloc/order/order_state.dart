import 'package:mini_mart/model/order/order_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class CheckoutSuccess extends OrderState {
  final int orderId;
  final String? qrCode; // Base64 QR image (nullable)
  final String? expiresAt; // (nullable)
  final String message;

  CheckoutSuccess({
    required this.orderId,
    this.qrCode,
    this.expiresAt,
    required this.message,
  });
}

class CheckoutFailure extends OrderState {
  final String error;

  CheckoutFailure(this.error);
}

class MyOrdersLoaded extends OrderState {
  final List<OrderModel> orders;

  MyOrdersLoaded(this.orders);
}

class MyOrdersFailure extends OrderState {
  final String error;

  MyOrdersFailure(this.error);
}

class OrderDetailsLoaded extends OrderState {
  final OrderModel order;

  OrderDetailsLoaded(this.order);
}

class OrderDetailsFailure extends OrderState {
  final String error;

  OrderDetailsFailure(this.error);
}

class AllOrdersLoaded extends OrderState {
  final List<OrderModel> orders;

  AllOrdersLoaded(this.orders);
}

class AllOrdersFailure extends OrderState {
  final String error;

  AllOrdersFailure(this.error);
}

class OrderDeleteSuccess extends OrderState {
  final String message;

  OrderDeleteSuccess(this.message);
}

class OrderDeleteFailure extends OrderState {
  final String error;

  OrderDeleteFailure(this.error);
}

class NotificationMarkedAsRead extends OrderState {
  final int orderId;
  NotificationMarkedAsRead(this.orderId);
}

class UnreadCountLoaded extends OrderState {
  final int count;
  UnreadCountLoaded(this.count);
}

class RetryPaymentLoading extends OrderState {}

class RetryPaymentSuccess extends OrderState {
  final int orderId;
  final int paymentId;
  final String qrCode;
  final double amount;
  final String expiresAt;
  final String message;

  RetryPaymentSuccess({
    required this.orderId,
    required this.paymentId,
    required this.qrCode,
    required this.amount,
    required this.expiresAt,
    required this.message,
  });
}

class RetryPaymentFailure extends OrderState {
  final String error;

  RetryPaymentFailure(this.error);
}
