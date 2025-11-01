import '../services/fcm_service.dart';

class NotificationHelper {
  static Future<void> sendPaymentSuccessNotification({
    required int orderId,
    required double amount,
  }) async {
    await FCMService().sendLocalNotification(
      title: '✅ Payment Successful!',
      body:
          'Order #$orderId - \$${amount.toStringAsFixed(2)} paid successfully',
      data: {
        'type': 'payment_success',
        'orderId': orderId.toString(),
        'amount': amount.toString(),
      },
    );
  }

  /// ✅ NEW: Send notification when payment times out
  static Future<void> sendPaymentTimeoutNotification({
    required int orderId,
    required double amount,
  }) async {
    await FCMService().sendLocalNotification(
      title: '⏱️ Payment Timeout',
      body:
          'Order #$orderId - Payment not completed (\$${amount.toStringAsFixed(2)})',
      data: {
        'type': 'payment_timeout',
        'orderId': orderId.toString(),
        'amount': amount.toString(),
      },
    );
  }

  /// Send notification after payment confirmed (keep existing)
  static Future<void> sendPaymentConfirmedNotification({
    required int orderId,
  }) async {
    await FCMService().sendLocalNotification(
      title: '✅ Payment Confirmed!',
      body: 'Order #$orderId payment confirmed! Your order is being prepared.',
      data: {'type': 'payment_confirmed', 'orderId': orderId.toString()},
    );
  }

  /// Send notification when payment failed (keep existing)
  static Future<void> sendPaymentFailedNotification({
    required int orderId,
    required String reason,
  }) async {
    await FCMService().sendLocalNotification(
      title: '❌ Payment Failed',
      body: 'Order #$orderId: $reason. Please try again.',
      data: {'type': 'payment_failed', 'orderId': orderId.toString()},
    );
  }
}
