import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mini_mart/bloc/order/order_bloc.dart';
import 'package:mini_mart/bloc/order/order_event.dart';
import 'package:mini_mart/bloc/order/order_state.dart';
import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/model/address/address_model.dart';
import 'package:mini_mart/model/order/order_model.dart';
import 'package:mini_mart/screens/payment_screen/qr_payment_dialog.dart'; // ✅ ADD THIS
import 'package:mini_mart/styles/fonts.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load order details
    context.read<OrderBloc>().add(GetOrderDetailsEvent(widget.orderId));
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
                          color: Color(0xFF6C5CE7),
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
              // ✅ Dispatch retry payment event
              context.read<OrderBloc>().add(RetryPaymentEvent(order.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      // ✅ NEW: Listen for retry payment states
      listener: (context, state) {
        if (state is RetryPaymentSuccess) {
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

          // Reload order details
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.read<OrderBloc>().add(
                GetOrderDetailsEvent(widget.orderId),
              );
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
            onPressed: () => Navigator.pop(context, true),
          ),
          title: const Text(
            'Order Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: kantumruyPro,
            ),
          ),
          centerTitle: true,
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
                                color: Color(0xFF6C5CE7),
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

  // ✅ NEW: Extracted main content to separate method
  Widget _buildMainContent() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
          );
        }

        if (state is OrderDetailsLoaded) {
          final order = state.order;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Info Card
                _buildOrderInfoCard(order),

                const SizedBox(height: 20),

                // Payment Card
                if (order.status.toLowerCase() == 'paid') ...[
                  _buildPaymentCard(order.payment!),
                  const SizedBox(height: 20),
                ] else ...[
                  Container(
                    width: double.infinity,
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
                        const Text(
                          'Payment Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: kantumruyPro,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'You have not paid for this order yet. Please upload your payment screenshot to confirm your payment.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontFamily: kantumruyPro,
                            height: 1.5,
                          ),
                        ),
                        // ✅ UPDATED: Changed onPressed to call dialog
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF6C5CE7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => _showRetryPaymentDialog(
                            order,
                          ), // ✅ CHANGED THIS LINE
                          child: const Text(
                            'Pay Again',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: kantumruyPro,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Shipping Address Card
                if (order.address != null) ...[
                  _buildShippingAddressCard(order.address!),
                  const SizedBox(height: 20),
                ],

                // Order Items
                _buildOrderItemsSection(order),

                const SizedBox(height: 20),

                // Total Summary
                _buildTotalSummary(order),
              ],
            ),
          );
        }

        if (state is OrderDetailsFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Failed to load order details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontFamily: kantumruyPro,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<OrderBloc>().add(
                      GetOrderDetailsEvent(widget.orderId),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildOrderInfoCard(OrderModel order) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: kantumruyPro,
                ),
              ),
              _buildStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Order ID', '#${order.id}'),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Order Date',
            DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt),
          ),
          if (order.payDate != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'Payment Date',
              DateFormat('dd MMM yyyy, hh:mm a').format(order.payDate!),
            ),
          ],
          const SizedBox(height: 12),
          _buildInfoRow('Items', '${order.itemCount} item(s)'),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(dynamic payment) {
    return Container(
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
          const Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: kantumruyPro,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Payment ID', '#${payment.id}'),
          const SizedBox(height: 12),
          _buildInfoRow('Amount', '\$${payment.amount.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildInfoRow('Method', payment.method ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow('Status', 'Paid'),
          if (payment.payDate != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'Payment Date',
              DateFormat('dd MMM yyyy, hh:mm a').format(payment.payDate),
            ),
          ],
          if (payment.screenshot != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Payment Screenshot',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: kantumruyPro,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showFullImage(context, '${payment.screenshot}'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: '${ApiConfig.baseUrl}${payment.screenshot}',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6C5CE7),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 40,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Failed to load image',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
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
        ],
      ),
    );
  }

  Widget _buildShippingAddressCard(AddressModel address) {
    return Container(
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
          const Text(
            'Shipping Address',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: kantumruyPro,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF6C5CE7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: kantumruyPro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.fullAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: kantumruyPro,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Items',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: kantumruyPro,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
            children: [
              if (order.items != null && order.items!.isNotEmpty)
                ...order.items!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      _buildOrderItemCard(item),
                      if (index < order.items!.length - 1)
                        Divider(height: 1, color: Colors.grey[200]),
                    ],
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemCard(OrderItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.productImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: "${ApiConfig.baseUrl}${item.productImage}",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF6C5CE7),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image_outlined,
                        size: 30,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                : Icon(Icons.image_outlined, size: 30, color: Colors.grey[400]),
          ),
          const SizedBox(width: 16),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: kantumruyPro,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)} × ${item.qty}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: kantumruyPro,
                      ),
                    ),
                    Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C5CE7),
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
    );
  }

  Widget _buildTotalSummary(OrderModel order) {
    return Container(
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: kantumruyPro,
                ),
              ),
              Text(
                '\$${order.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: kantumruyPro,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: kantumruyPro,
                ),
              ),
              Text(
                '\$${order.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C5CE7),
                  fontFamily: kantumruyPro,
                ),
              ),
            ],
          ),
        ],
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontFamily: kantumruyPro,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = const Color(0xFFFDB022);
        textColor = Colors.white;
        displayText = 'Pending';
        break;
      case 'paid':
        bgColor = const Color(0xFF2196F3);
        textColor = Colors.white;
        displayText = 'Paid';
        break;
      case 'failed':
        bgColor = const Color(0xFFF44336);
        textColor = Colors.white;
        displayText = 'Failed';
        break;
      default:
        bgColor = Colors.grey;
        textColor = Colors.white;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: kantumruyPro,
        ),
      ),
    );
  }

  // Show Full Image Dialog with Zoom
  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
            // Image with zoom
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: CachedNetworkImage(
                  imageUrl: ApiConfig.baseUrl + imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load image',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
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
        ),
      ),
    );
  }
}
