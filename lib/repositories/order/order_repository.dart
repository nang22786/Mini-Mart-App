import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/model/order/order_model.dart';
import 'package:mini_mart/services/api_service.dart';

class OrderRepository {
  final ApiService _apiService;
  OrderRepository(this._apiService);

  Future<Map<String, dynamic>> checkout({
    required int addressId,
    required List<Map<String, dynamic>> items,
    required double amount,
  }) async {
    try {
      print('🛒 Checkout - addressId: $addressId, amount: \$$amount');
      print('📦 Items: $items');

      final response = await _apiService.post(
        ApiConfig.checkout,
        data: {'addressId': addressId, 'items': items, 'amount': amount},
      );

      print('📥 Checkout response: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return {
          'success': true,
          'orderId': data['orderId'],
          'qrCode': data['qrCode'],
          'expiresAt': data['expiresAt'],
          'message': response.data['message'] ?? 'Checkout successful',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Checkout failed',
        };
      }
    } catch (e) {
      print('❌ Checkout error: $e');
      return {'success': false, 'message': 'Error during checkout: $e'};
    }
  }

  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await _apiService.get(ApiConfig.myOrders);

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get orders');
      }
    } catch (e) {
      throw Exception('Error getting orders: $e');
    }
  }

  Future<OrderModel> getOrderDetails(int orderId) async {
    try {
      final response = await _apiService.get(ApiConfig.orderById(orderId));

      if (response.data['success'] == true) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to get order details',
        );
      }
    } catch (e) {
      throw Exception('Error getting order details: $e');
    }
  }

  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await _apiService.get(ApiConfig.allOrders);

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get all orders');
      }
    } catch (e) {
      throw Exception('Error getting all orders: $e');
    }
  }

  Future<void> deleteOrder(int orderId) async {
    print('');
    print('═══════════════════════════════════════');
    print('🗑️ REPOSITORY DELETE ORDER');
    print('═══════════════════════════════════════');
    print('📋 Order ID: $orderId');
    print('🔗 Endpoint: ${ApiConfig.deleteOrder(orderId)}');
    print('🔗 Full URL: ${ApiConfig.baseUrl}${ApiConfig.deleteOrder(orderId)}');
    print('═══════════════════════════════════════');

    try {
      print('📡 Making DELETE API call...');

      final response = await _apiService.delete(ApiConfig.deleteOrder(orderId));

      print('');
      print('📥 API Response received:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');
      print('');

      if (response.data is Map && response.data['success'] == true) {
        print('✅ Delete successful - response indicates success');
      } else if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Delete successful - HTTP status OK');
      } else {
        final message = response.data is Map
            ? (response.data['message'] ?? 'Failed to delete order')
            : 'Failed to delete order';

        print('❌ Delete failed: $message');
        throw Exception(message);
      }

      print('═══════════════════════════════════════');
      print('✅ REPOSITORY DELETE COMPLETED');
      print('═══════════════════════════════════════');
      print('');
    } catch (e, stackTrace) {
      print('');
      print('═══════════════════════════════════════');
      print('❌ REPOSITORY DELETE ERROR');
      print('═══════════════════════════════════════');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      print('Stack Trace: $stackTrace');
      print('═══════════════════════════════════════');
      print('');

      throw Exception('Error deleting order: $e');
    }
  }

  /// Mark a failed order notification as read
  Future<void> markNotificationAsRead(int orderId) async {
    try {
      print('📖 Marking Order #$orderId as read...');

      final response = await _apiService.post(
        ApiConfig.markNotificationRead(orderId),
      );

      if (response.data['success'] == true) {
        print('✅ Order #$orderId marked as read');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to mark as read');
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      throw Exception('Error marking notification as read: $e');
    }
  }

  /// Mark all failed order notifications as read
  Future<int> markAllFailedAsRead() async {
    try {
      print('📖 Marking all failed orders as read...');

      final response = await _apiService.post(ApiConfig.markAllFailedRead);

      if (response.data['success'] == true) {
        final markedCount = response.data['markedCount'] ?? 0;
        print('✅ Marked $markedCount orders as read');
        return markedCount;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to mark all as read',
        );
      }
    } catch (e) {
      print('❌ Error marking all as read: $e');
      throw Exception('Error marking all as read: $e');
    }
  }

  /// Get count of unread failed orders
  Future<int> getUnreadFailedCount() async {
    try {
      final response = await _apiService.get(ApiConfig.unreadFailedCount);

      if (response.data['success'] == true) {
        return response.data['count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  /// Retry payment for a failed order
  /// POST /api/orders/{orderId}/retry-payment
  Future<Map<String, dynamic>> retryPayment(int orderId) async {
    print('');
    print('═══════════════════════════════════════');
    print('🔄 REPOSITORY RETRY PAYMENT');
    print('═══════════════════════════════════════');
    print('📋 Order ID: $orderId');
    print('🔗 Endpoint: ${ApiConfig.reCheckOut(orderId)}');
    print('═══════════════════════════════════════');

    try {
      final response = await _apiService.post(
        ApiConfig.reCheckOut(orderId), // ✅ Using your ApiConfig
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final paymentData = data['payment'];

        return {
          'success': true,
          'message': response.data['message'],
          'orderId': data['order']['id'],
          'paymentId': paymentData['id'],
          'qrCode': paymentData['qrCode'],
          'amount': (paymentData['amount'] as num).toDouble(),
          'expiresAt': paymentData['expiresAt'],
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to retry payment',
        };
      }
    } catch (e) {
      throw Exception('Error retrying payment: $e');
    }
  }
}
