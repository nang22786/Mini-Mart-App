import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/bloc/order/order_bloc.dart';
import 'package:mini_mart/bloc/order/order_event.dart';
import 'package:mini_mart/bloc/order/order_state.dart';
import 'package:mini_mart/screens/notification_screen/notification_screen.dart';

class NotificationBadgeIcon extends StatefulWidget {
  const NotificationBadgeIcon({super.key});

  @override
  State<NotificationBadgeIcon> createState() => _NotificationBadgeIconState();
}

class _NotificationBadgeIconState extends State<NotificationBadgeIcon> {
  @override
  void initState() {
    super.initState();
    // Load orders to check unread count
    context.read<OrderBloc>().add(GetMyOrdersEvent());
  }

  int _getUnreadCount(OrderState state) {
    if (state is MyOrdersLoaded) {
      final failedOrders = state.orders
          .where((order) => order.status.toLowerCase() == 'failed')
          .toList();
      return failedOrders.where((order) => !order.notificationRead).length;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        final unreadCount = _getUnreadCount(state);

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                ).then((_) {
                  // Refresh count when coming back
                  context.read<OrderBloc>().add(GetMyOrdersEvent());
                });
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF44336),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
