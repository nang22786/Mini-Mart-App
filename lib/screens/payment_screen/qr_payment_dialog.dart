import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mini_mart/bloc/order/order_bloc.dart';
import 'package:mini_mart/bloc/order/order_event.dart';
import 'package:mini_mart/bloc/order/order_state.dart';
import 'package:mini_mart/styles/fonts.dart';
import 'package:mini_mart/helper/notification_helper.dart';
import 'package:mini_mart/screens/screen_controller/screen_controller.dart';
import 'package:mini_mart/screens/notification_screen/notification_screen.dart';

class QRPaymentDialog extends StatefulWidget {
  final int orderId;
  final String qrCode;
  final String expiresAt;
  final double amount;

  const QRPaymentDialog({
    super.key,
    required this.orderId,
    required this.qrCode,
    required this.expiresAt,
    required this.amount,
  });

  @override
  State<QRPaymentDialog> createState() => _QRPaymentDialogState();
}

class _QRPaymentDialogState extends State<QRPaymentDialog> {
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  int _secondsRemaining = 300;

  @override
  void initState() {
    super.initState();
    _startPolling();
    _startCountdown();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        context.read<OrderBloc>().add(GetOrderDetailsEvent(widget.orderId));
      }
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsRemaining--);
      if (_secondsRemaining <= 0) {
        timer.cancel();
        _pollingTimer?.cancel();
        _handleTimeout();
      }
    });
  }

  // ✅ Timeout → Send notification → Go to NOTIFICATION SCREEN
  void _handleTimeout() {
    if (!mounted) return;

    // ✅ Send timeout notification
    NotificationHelper.sendPaymentTimeoutNotification(
      orderId: widget.orderId,
      amount: widget.amount,
    );

    print('⏱️ Payment timeout - Order #${widget.orderId}');

    // ✅ Navigate to notification screen
    _navigateToNotificationScreen();
  }

  // ✅ Success → Send notification → Go to home with refresh
  void _handleSuccess() {
    if (!mounted) return;

    _pollingTimer?.cancel();
    _countdownTimer?.cancel();

    // ✅ Send success notification
    NotificationHelper.sendPaymentSuccessNotification(
      orderId: widget.orderId,
      amount: widget.amount,
    );

    print('✅ Payment success - Order #${widget.orderId}');

    // ✅ Navigate to home and refresh orders
    _navigateToHomeAndRefresh();
  }

  // ✅ Navigate to ScreenController with Orders tab + Refresh
  void _navigateToHomeAndRefresh() {
    // Close all dialogs and go to home with orders tab
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const ScreenController(index: 2), // Orders tab
      ),
      (route) => false, // Remove all previous routes
    );

    // ✅ Refresh orders after navigation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<OrderBloc>().add(GetMyOrdersEvent());
      }
    });
  }

  // ✅ NEW: Navigate directly to NotificationScreen (for failed payments)
  void _navigateToNotificationScreen() {
    // Close dialog and go directly to NotificationScreen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            const NotificationScreen(), // ✅ Direct to NotificationScreen
      ),
      (route) => false, // Remove all previous routes
    );

    // ✅ Refresh orders after navigation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<OrderBloc>().add(GetMyOrdersEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        // ✅ Payment success → Go home
        if (state is OrderDetailsLoaded && state.order.status == 'paid') {
          _handleSuccess();
        }
        // ✅ NEW: Payment failed → Go to notification screen
        else if (state is OrderDetailsLoaded &&
            state.order.status == 'failed') {
          _pollingTimer?.cancel();
          _countdownTimer?.cancel();

          // Send notification
          NotificationHelper.sendPaymentTimeoutNotification(
            orderId: widget.orderId,
            amount: widget.amount,
          );

          print('❌ Payment failed - Order #${widget.orderId}');

          // Navigate to notification screen
          _navigateToNotificationScreen();
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(30),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  spreadRadius: 3,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔴 Red Header with KHQR logo
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Image.asset(
                        'assets/logo/KHQR_Logo.png',
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // White Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SAMNANG YORN',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontFamily: kantumruyPro,
                        ),
                      ),

                      // Amount + Currency
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.amount.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: kantumruyPro,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              'USD',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
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

                // Dotted divider
                CustomPaint(
                  painter: DottedLinePainter(),
                  size: const Size(double.infinity, 1),
                ),

                // QR Code
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 24,
                  ),
                  child: QrImageView(
                    data: widget.qrCode,
                    version: QrVersions.auto,
                    size: 230,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                    embeddedImage: const AssetImage(
                      'assets/logo/dollor_icon.png',
                    ),
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(35, 35),
                    ),
                  ),
                ),

                // ✅ TIMER UNDER QR CODE
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _secondsRemaining < 20
                          ? Colors.red.withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          color: _secondsRemaining < 20
                              ? Colors.red
                              : Colors.grey[700],
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_secondsRemaining s',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _secondsRemaining < 20
                                ? Colors.red
                                : Colors.grey[800],
                            fontFamily: kantumruyPro,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ⚪ Dotted line painter
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    const dashWidth = 6;
    const dashSpace = 4;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
