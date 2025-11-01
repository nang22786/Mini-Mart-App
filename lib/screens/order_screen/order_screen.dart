import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart/bloc/order/order_bloc.dart';
import 'package:mini_mart/bloc/order/order_event.dart';
import 'package:mini_mart/bloc/order/order_state.dart';
import 'package:mini_mart/model/order/order_model.dart';
import 'package:mini_mart/screens/order_screen/order_details_screen.dart';
import 'package:mini_mart/styles/fonts.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(GetMyOrdersEvent());
  }

  int _getUnreadCount(List<OrderModel> paidOrders) {
    return paidOrders.where((order) => !order.notificationRead).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: kantumruyPro,
          ),
        ),
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
          if (state is OrderLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00A69D)),
            );
          }

          if (state is MyOrdersLoaded) {
            // ✅ Filter to show only PAID orders
            final paidOrders = state.orders
                .where(
                  (order) =>
                      order.status.toLowerCase() == 'pending' ||
                      order.status.toLowerCase() == 'paid',
                )
                .toList();

            // Sort by date (newest first)
            paidOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (paidOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No paid orders yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: kantumruyPro,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your paid orders will appear here",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: kantumruyPro,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            final unreadCount = _getUnreadCount(paidOrders);

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
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$unreadCount new order${unreadCount > 1 ? "s" : ""}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                            fontFamily: kantumruyPro,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Mark all paid orders as read
                            for (var order in paidOrders) {
                              if (!order.notificationRead) {
                                context.read<OrderBloc>().add(
                                  MarkNotificationReadEvent(order.id),
                                );
                              }
                            }
                            // Reload after marking
                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                if (mounted) {
                                  context.read<OrderBloc>().add(
                                    GetMyOrdersEvent(),
                                  );
                                }
                              },
                            );
                          },
                          child: const Text(
                            'Mark all as read',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00A69D),
                              fontFamily: kantumruyPro,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Orders list
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFF00A69D),
                    onRefresh: () async {
                      context.read<OrderBloc>().add(GetMyOrdersEvent());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: paidOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(paidOrders[index]);
                        },
                      ),
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
                    "Failed to load orders",
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
                      backgroundColor: const Color(0xFF00A69D),
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
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final formattedDate = DateFormat(
      'yyyy-MM-dd hh:mm a',
    ).format(order.createdAt);
    final isUnread = !order.notificationRead;

    return GestureDetector(
      onTap: () async {
        // ✅ Navigate FIRST
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(orderId: order.id),
          ),
        );

        // ✅ Mark as read AFTER returning (if unread)
        if (mounted && isUnread) {
          context.read<OrderBloc>().add(MarkNotificationReadEvent(order.id));
        }

        // Reload orders
        if (mounted) {
          context.read<OrderBloc>().add(GetMyOrdersEvent());
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          // ✅ Light green background for unread, white for read
          color: isUnread ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? const Color(0xFF4CAF50).withOpacity(0.3)
                : Colors.grey[200]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Order #${order.id}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontFamily: kantumruyPro,
                              ),
                            ),
                            // ✅ Blue dot for unread
                            if (isUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2196F3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Price: \$${order.amount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontFamily: kantumruyPro,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${order.itemCount} item(s)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: kantumruyPro,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Paid badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: kantumruyPro,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFEAEAEA)),
              const SizedBox(height: 8),
              // Bottom Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontFamily: kantumruyPro,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      // ✅ Navigate FIRST
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailsScreen(orderId: order.id),
                        ),
                      );

                      // ✅ Mark as read AFTER returning
                      if (mounted && isUnread) {
                        context.read<OrderBloc>().add(
                          MarkNotificationReadEvent(order.id),
                        );
                      }

                      // Reload orders
                      if (mounted) {
                        context.read<OrderBloc>().add(GetMyOrdersEvent());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF00A69D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Details",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: kantumruyPro,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
