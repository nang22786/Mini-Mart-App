import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart/bloc/order/order_bloc.dart';
import 'package:mini_mart/bloc/order/order_event.dart';
import 'package:mini_mart/bloc/order/order_state.dart';
import 'package:mini_mart/model/order/order_model.dart';
import 'package:mini_mart/screens/order_screen/order_details_screen.dart';
import 'package:mini_mart/screens/payment_screen/qr_payment_dialog.dart';
import 'package:mini_mart/styles/fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(GetMyOrdersEvent());
  }

  int _getUnreadCount(List<OrderModel> failedOrders) {
    return failedOrders.where((order) => !order.notificationRead).length;
  }

  // ✅ NEW: Show retry payment confirmation dialog
  void _showRetryPaymentDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Retry Payment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: kantumruyPro,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do you want to retry payment for Order #${order.id}?',
              style: const TextStyle(fontSize: 14, fontFamily: kantumruyPro),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Amount:',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                      Text(
                        '\$${order.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF44336),
                          fontFamily: kantumruyPro,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Items:',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                      Text(
                        '${order.itemCount} item(s)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: kantumruyPro,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _handleRetryPayment(order);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Retry Payment',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: kantumruyPro,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Handle retry payment
  void _handleRetryPayment(OrderModel order) {
    print('🔄 Retry payment for Order #${order.id}');
    context.read<OrderBloc>().add(RetryPaymentEvent(order.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      // ✅ NEW: Listen for retry payment states
      listener: (context, state) {
        if (state is RetryPaymentSuccess) {
          print('✅ Retry payment success! Order #${state.orderId}');

          // Show QR Payment Dialog
          if (state.qrCode.isNotEmpty && state.expiresAt.isNotEmpty) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => QRPaymentDialog(
                orderId: state.orderId,
                qrCode: state.qrCode,
                expiresAt: state.expiresAt,
                amount: state.amount,
              ),
            );
          }

          // Reload orders
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.read<OrderBloc>().add(GetMyOrdersEvent());
            }
          });
        } else if (state is RetryPaymentFailure) {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.error,
                style: const TextStyle(fontFamily: kantumruyPro),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: kantumruyPro,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: () {
                context.read<OrderBloc>().add(GetMyOrdersEvent());
              },
            ),
          ],
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            // ✅ NEW: Show loading overlay when retrying payment
            if (state is RetryPaymentLoading) {
              return Stack(
                children: [
                  _buildMainContent(),
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFFF44336),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Processing retry payment...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: kantumruyPro,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return _buildMainContent();
          },
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFF44336)),
          );
        }

        if (state is MyOrdersLoaded) {
          // ✅ Filter only FAILED orders
          final failedOrders = state.orders
              .where((order) => order.status.toLowerCase() == 'failed')
              .toList();

          // Sort by date (newest first)
          failedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (failedOrders.isEmpty) {
            return _buildEmptyState();
          }

          final unreadCount = _getUnreadCount(failedOrders);

          return Column(
            children: [
              // ✅ Unread count header with "Mark all as read" button
              if (unreadCount > 0)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$unreadCount unread notification${unreadCount > 1 ? "s" : ""}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          fontFamily: kantumruyPro,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<OrderBloc>().add(
                            MarkAllFailedReadEvent(),
                          );
                        },
                        child: const Text(
                          'Mark all as read',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF44336),
                            fontFamily: kantumruyPro,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Notifications list
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFFF44336),
                  onRefresh: () async {
                    context.read<OrderBloc>().add(GetMyOrdersEvent());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: failedOrders.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(failedOrders[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        }

        if (state is MyOrdersFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  "Failed to load notifications",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: kantumruyPro,
                    color: Colors.red[400],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<OrderBloc>().add(GetMyOrdersEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF44336),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(fontFamily: kantumruyPro),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildNotificationCard(OrderModel order) {
    final isUnread = !order.notificationRead;

    return GestureDetector(
      onTap: () async {
        // ✅ Navigate to order details
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(orderId: order.id),
          ),
        );

        // ✅ Mark as read AFTER returning
        if (mounted && isUnread) {
          context.read<OrderBloc>().add(MarkNotificationReadEvent(order.id));
        }

        // Reload orders when returning
        if (mounted) {
          context.read<OrderBloc>().add(GetMyOrdersEvent());
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ✅ Orange background for unread, white for read
          color: isUnread ? const Color(0xFFFFF3E0) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? const Color(0xFFF44336).withOpacity(0.3)
                : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Color(0xFFF44336),
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with badge and unread dot
                  Row(
                    children: [
                      const Text(
                        'Order Failed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF44336),
                          fontFamily: kantumruyPro,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF44336).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#${order.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF44336),
                            fontFamily: kantumruyPro,
                          ),
                        ),
                      ),
                      // ✅ Blue dot for unread
                      if (isUnread) ...[
                        const Spacer(),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6C5CE7),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Message
                  Text(
                    'Your order #${order.id} has failed. Please try again or contact support.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontFamily: kantumruyPro,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Order details
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${order.itemCount} item(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: kantumruyPro,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.payments, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '\$${order.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                          fontFamily: kantumruyPro,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ✅ Time + Retry Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeAgo(order.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontFamily: kantumruyPro,
                        ),
                      ),
                      const Spacer(),
                      // ✅ NEW: Small Retry Button
                      InkWell(
                        onTap: () => _showRetryPaymentDialog(order),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF44336),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Pay Again',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: kantumruyPro,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Arrow icon
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: kantumruyPro,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: kantumruyPro,
            ),
          ),
        ],
      ),
    );
  }
}
