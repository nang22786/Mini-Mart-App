abstract class OrderEvent {}

class CheckoutEvent extends OrderEvent {
  final int addressId;
  final List<Map<String, dynamic>> items;
  final double amount;

  CheckoutEvent({
    required this.addressId,
    required this.items,
    required this.amount,
  });
}

class GetMyOrdersEvent extends OrderEvent {}

class GetOrderDetailsEvent extends OrderEvent {
  final int orderId;

  GetOrderDetailsEvent(this.orderId);
}

class GetAllOrdersEvent extends OrderEvent {}

class DeleteOrderEvent extends OrderEvent {
  final int orderId;

  DeleteOrderEvent(this.orderId);
}

class MarkNotificationReadEvent extends OrderEvent {
  final int orderId;
  MarkNotificationReadEvent(this.orderId);
}

class MarkAllFailedReadEvent extends OrderEvent {}

class GetUnreadCountEvent extends OrderEvent {}

class RetryPaymentEvent extends OrderEvent {
  final int orderId;

  RetryPaymentEvent(this.orderId);
}
