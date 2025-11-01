import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/bloc/order/order_event.dart';
import 'package:mini_mart/bloc/order/order_state.dart';
import 'package:mini_mart/repositories/order/order_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;
  OrderBloc(this.orderRepository) : super(OrderInitial()) {
    on<CheckoutEvent>(_onCheckout);
    on<GetMyOrdersEvent>(_onGetMyOrders);
    on<GetOrderDetailsEvent>(_onGetOrderDetails);
    on<GetAllOrdersEvent>(_onGetAllOrders);
    on<DeleteOrderEvent>(_onDeleteOrder);
    on<MarkNotificationReadEvent>(_onMarkNotificationRead);
    on<MarkAllFailedReadEvent>(_onMarkAllFailedRead);
    on<GetUnreadCountEvent>(_onGetUnreadCount);
    on<RetryPaymentEvent>(_onRetryPayment); // ✅ ADD THIS
  }

  Future<void> _onMarkNotificationRead(
    MarkNotificationReadEvent event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await orderRepository.markNotificationAsRead(event.orderId);
      emit(NotificationMarkedAsRead(event.orderId));

      // Reload orders to update UI
      add(GetMyOrdersEvent());
    } catch (e) {
      print('❌ Error in _onMarkNotificationRead: $e');
      // Don't emit error, just reload orders
      add(GetMyOrdersEvent());
    }
  }

  Future<void> _onMarkAllFailedRead(
    MarkAllFailedReadEvent event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await orderRepository.markAllFailedAsRead();

      // Reload orders to update UI
      add(GetMyOrdersEvent());
    } catch (e) {
      print('❌ Error in _onMarkAllFailedRead: $e');
      // Don't emit error, just reload orders
      add(GetMyOrdersEvent());
    }
  }

  Future<void> _onGetUnreadCount(
    GetUnreadCountEvent event,
    Emitter<OrderState> emit,
  ) async {
    try {
      final count = await orderRepository.getUnreadFailedCount();
      emit(UnreadCountLoaded(count));
    } catch (e) {
      print('❌ Error in _onGetUnreadCount: $e');
      emit(UnreadCountLoaded(0));
    }
  }

  Future<void> _onCheckout(
    CheckoutEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final result = await orderRepository.checkout(
        addressId: event.addressId,
        items: event.items,
        amount: event.amount,
      );

      if (result['success'] == true) {
        emit(
          CheckoutSuccess(
            orderId: result['orderId'],
            qrCode: result['qrCode'],
            expiresAt: result['expiresAt'],
            message: result['message'],
          ),
        );
      } else {
        emit(CheckoutFailure(result['message']));
      }
    } catch (e) {
      emit(CheckoutFailure(e.toString()));
    }
  }

  Future<void> _onGetMyOrders(
    GetMyOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await orderRepository.getMyOrders();
      emit(MyOrdersLoaded(orders));
    } catch (e) {
      emit(MyOrdersFailure(e.toString()));
    }
  }

  Future<void> _onGetOrderDetails(
    GetOrderDetailsEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final order = await orderRepository.getOrderDetails(event.orderId);
      emit(OrderDetailsLoaded(order));
    } catch (e) {
      emit(OrderDetailsFailure(e.toString()));
    }
  }

  Future<void> _onGetAllOrders(
    GetAllOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await orderRepository.getAllOrders();
      emit(AllOrdersLoaded(orders));
    } catch (e) {
      emit(AllOrdersFailure(e.toString()));
    }
  }

  Future<void> _onDeleteOrder(
    DeleteOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    print('');
    print('═══════════════════════════════════════');
    print('🚀 DELETE ORDER BLOC EVENT TRIGGERED');
    print('═══════════════════════════════════════');
    print('📋 Order ID: ${event.orderId}');
    print('⏰ Timestamp: ${DateTime.now()}');
    print('═══════════════════════════════════════');

    try {
      print('📞 Calling orderRepository.deleteOrder(${event.orderId})...');

      await orderRepository.deleteOrder(event.orderId);

      print('');
      print('✅ Repository deleteOrder completed successfully');
      print('📤 Emitting OrderDeleteSuccess state...');

      emit(OrderDeleteSuccess('Order #${event.orderId} deleted successfully'));

      print('✅ OrderDeleteSuccess state emitted');
      print('⏳ Waiting 300ms before reload...');

      await Future.delayed(const Duration(milliseconds: 300));

      print('🔄 Dispatching GetAllOrdersEvent to refresh list...');
      add(GetAllOrdersEvent());

      print('═══════════════════════════════════════');
      print('✅ DELETE ORDER PROCESS COMPLETED');
      print('═══════════════════════════════════════');
      print('');
    } catch (e, stackTrace) {
      print('');
      print('═══════════════════════════════════════');
      print('❌ DELETE ORDER FAILED IN BLOC');
      print('═══════════════════════════════════════');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      print('═══════════════════════════════════════');
      print('');

      emit(OrderDeleteFailure('Failed to delete order: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ NEW: RETRY PAYMENT HANDLER
  // ═══════════════════════════════════════════════════════════════

  Future<void> _onRetryPayment(
    RetryPaymentEvent event,
    Emitter<OrderState> emit,
  ) async {
    print('');
    print('═══════════════════════════════════════');
    print('🔄 RETRY PAYMENT BLOC EVENT TRIGGERED');
    print('═══════════════════════════════════════');
    print('📋 Order ID: ${event.orderId}');
    print('⏰ Timestamp: ${DateTime.now()}');
    print('═══════════════════════════════════════');

    emit(RetryPaymentLoading());

    try {
      print('📞 Calling orderRepository.retryPayment(${event.orderId})...');

      final result = await orderRepository.retryPayment(event.orderId);

      print('');
      print('📥 Repository response received:');
      print('   Success: ${result['success']}');
      print('   Message: ${result['message']}');
      print('');

      if (result['success'] == true) {
        print('✅ Retry payment successful');
        print('📤 Emitting RetryPaymentSuccess state...');

        emit(
          RetryPaymentSuccess(
            orderId: result['orderId'],
            paymentId: result['paymentId'],
            qrCode: result['qrCode'],
            amount: result['amount'],
            expiresAt: result['expiresAt'],
            message: result['message'],
          ),
        );

        print('✅ RetryPaymentSuccess state emitted');
        print('🎫 QR Code ready for display');
        print('⏰ Payment expires at: ${result['expiresAt']}');
        print('═══════════════════════════════════════');
        print('✅ RETRY PAYMENT PROCESS COMPLETED');
        print('═══════════════════════════════════════');
        print('');
      } else {
        print('❌ Retry payment failed: ${result['message']}');
        print('📤 Emitting RetryPaymentFailure state...');

        emit(RetryPaymentFailure(result['message']));

        print('═══════════════════════════════════════');
        print('❌ RETRY PAYMENT FAILED');
        print('═══════════════════════════════════════');
        print('');
      }
    } catch (e, stackTrace) {
      print('');
      print('═══════════════════════════════════════');
      print('❌ RETRY PAYMENT ERROR IN BLOC');
      print('═══════════════════════════════════════');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      print('Stack Trace: $stackTrace');
      print('═══════════════════════════════════════');
      print('');

      // Clean error message (remove "Exception: " prefix)
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      errorMessage = errorMessage.replaceAll('Error retrying payment: ', '');

      emit(RetryPaymentFailure(errorMessage));
    }
  }
}
