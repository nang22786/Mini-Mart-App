import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart/bloc/order/order_bloc.dart';
import 'package:mini_mart/bloc/order/order_event.dart';
import 'package:mini_mart/bloc/order/order_state.dart';
import 'package:mini_mart/model/order/order_model.dart';
import 'package:mini_mart/screens/order_screen/order_details_screen.dart';
import 'package:mini_mart/styles/fonts.dart';

class OrderOwnerScreen extends StatefulWidget {
  const OrderOwnerScreen({super.key});

  @override
  State<OrderOwnerScreen> createState() => _OrderOwnerScreenState();
}

class _OrderOwnerScreenState extends State<OrderOwnerScreen> {
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(GetAllOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'All Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: kantumruyPro,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              context.read<OrderBloc>().add(GetAllOrdersEvent());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusTabs(),
          Expanded(
            child: BlocConsumer<OrderBloc, OrderState>(
              listener: (context, state) {
                print('🎯 BlocConsumer listener - State: ${state.runtimeType}');

                if (state is OrderDeleteSuccess) {
                  print('✅ OrderDeleteSuccess received: ${state.message}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message,
                        style: const TextStyle(fontFamily: kantumruyPro),
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                } else if (state is OrderDeleteFailure) {
                  print('❌ OrderDeleteFailure received: ${state.error}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to delete: ${state.error}',
                        style: const TextStyle(fontFamily: kantumruyPro),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                print('🏗️ BlocConsumer builder - State: ${state.runtimeType}');

                if (state is OrderLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
                  );
                }

                if (state is AllOrdersLoaded) {
                  print('📦 Orders loaded: ${state.orders.length} orders');

                  List<OrderModel> filteredOrders = _selectedStatus == 'all'
                      ? state.orders
                      : state.orders.where((order) {
                          return order.status.toLowerCase() == _selectedStatus;
                        }).toList();

                  print('🔍 Filtered orders: ${filteredOrders.length} orders');

                  if (filteredOrders.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF6C5CE7),
                    onRefresh: () async {
                      print('🔄 RefreshIndicator triggered');
                      context.read<OrderBloc>().add(GetAllOrdersEvent());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(filteredOrders[index]);
                      },
                    ),
                  );
                }

                return const Center(child: Text('No orders'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildStatusChip('all', 'All'),
            _buildStatusChip('paid', 'Paid'),
            _buildStatusChip('failed', 'Failed'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, String label) {
    bool isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatus = status;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
              fontFamily: kantumruyPro,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    print('🎨 Building order card for Order #${order.id}');

    return Dismissible(
      key: Key('order_${order.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        print('⚠️ confirmDismiss triggered for Order #${order.id}');
        print('📍 Direction: $direction');

        // Store context BEFORE showing dialog
        final BuildContext currentContext = context;

        final bool? result = await showDialog<bool>(
          context: currentContext,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Delete Order',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: kantumruyPro,
              ),
            ),
            content: Text(
              'Are you sure you want to delete Order #${order.id}?\n\nThis action cannot be undone.',
              style: const TextStyle(fontFamily: kantumruyPro),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print('❌ User cancelled delete for Order #${order.id}');
                  Navigator.pop(dialogContext, false);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: kantumruyPro,
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  print('✅ User confirmed delete for Order #${order.id}');
                  Navigator.pop(dialogContext, true);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontFamily: kantumruyPro,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );

        print('🎯 Dialog result: $result');

        // If user confirmed, dispatch event BEFORE dismissing
        if (result == true && currentContext.mounted) {
          print('✅ Context is still mounted, dispatching delete event');
          currentContext.read<OrderBloc>().add(DeleteOrderEvent(order.id));
        }

        return result ?? false;
      },
      onDismissed: (direction) {
        // Event is already dispatched in confirmDismiss
        print(
          '🗑️ onDismissed called for Order #${order.id} - event already dispatched',
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 32),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: kantumruyPro,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: _getStatusColor(order.status),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: kantumruyPro,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(order.status),
              ],
            ),

            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 16),

            // Customer Info
            _buildInfoRow('Customer', order.userName ?? 'Unknown'),
            const SizedBox(height: 8),
            if (order.userEmail != null)
              _buildInfoRow('Email', order.userEmail!),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Date',
              DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Items', '${order.itemCount} item(s)'),

            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 16),

            // Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: kantumruyPro,
                  ),
                ),
                Text(
                  '\$${order.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C5CE7),
                    fontFamily: kantumruyPro,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      print('👁️ View Details tapped for Order #${order.id}');
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailsScreen(orderId: order.id),
                        ),
                      );
                      if (mounted) {
                        print('🔄 Back from details, refreshing orders');
                        context.read<OrderBloc>().add(GetAllOrdersEvent());
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6C5CE7),
                      side: const BorderSide(
                        color: Color(0xFF6C5CE7),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: kantumruyPro,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      print('📝 Update Status tapped for Order #${order.id}');
                      _showUpdateStatusDialog(order);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Update Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontFamily: kantumruyPro,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: kantumruyPro,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: kantumruyPro,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFDB022);
      case 'paid':
        return const Color(0xFF2196F3);
      case 'shipped':
        return const Color(0xFF9C27B0);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return const Color(0xFF9E9E9E);
      case 'failed':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  void _showUpdateStatusDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Update Order Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: kantumruyPro,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption('paid', order),
            _buildStatusOption('failed', order),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(String status, OrderModel order) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getStatusColor(status).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getStatusIcon(status),
          color: _getStatusColor(status),
          size: 20,
        ),
      ),
      title: Text(
        status[0].toUpperCase() + status.substring(1),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: kantumruyPro,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order #${order.id} status updated to ${status[0].toUpperCase() + status.substring(1)}',
              style: const TextStyle(fontFamily: kantumruyPro),
            ),
            backgroundColor: _getStatusColor(status),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.payment;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: kantumruyPro,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here',
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
