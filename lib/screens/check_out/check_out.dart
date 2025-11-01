import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/bloc/address/address_bloc.dart';
import 'package:mini_mart/bloc/address/address_event.dart';
import 'package:mini_mart/bloc/address/address_state.dart';
import 'package:mini_mart/bloc/cart/cart_bloc.dart';
import 'package:mini_mart/bloc/cart/cart_event.dart';
import 'package:mini_mart/bloc/order/order_bloc.dart';
import 'package:mini_mart/bloc/order/order_event.dart';
import 'package:mini_mart/bloc/order/order_state.dart';
import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/config/storage_service.dart';
import 'package:mini_mart/model/cart/cart_model.dart';
import 'package:mini_mart/model/address/address_model.dart';
import 'package:mini_mart/screens/check_out/address/address.dart';
import 'package:mini_mart/screens/payment_screen/qr_payment_dialog.dart'; // 🆕 NEW!
import 'package:mini_mart/styles/fonts.dart';

class CheckOutScreen extends StatefulWidget {
  final List<CartItem> selectedItems;
  const CheckOutScreen({super.key, required this.selectedItems});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  AddressModel? selectedAddress;
  bool _isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  // ✅ Load saved address from storage
  void _loadSavedAddress() async {
    final savedAddressId = StorageService.getSelectedAddressId();

    if (savedAddressId != null) {
      // Load user's addresses
      final userId = StorageService.getUserId();
      if (userId != null) {
        context.read<AddressBloc>().add(LoadAddressesByUserId(userId));
      }
    } else {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  double get totalAmount {
    return widget.selectedItems.fold(
      0.0,
      (sum, item) => sum + (item.product!.price * item.qty),
    );
  }

  double get subtotal {
    return totalAmount;
  }

  double get finalTotal {
    return subtotal;
  }

  // ✅ NEW: Checkout with KHQR (replaces _createOrder)
  void _checkout() {
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a delivery address',
            style: TextStyle(fontFamily: kantumruyPro),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare items for API
    final items = widget.selectedItems.map((item) {
      return {
        'productId': item.product!.id,
        'qty': item.qty,
        'price': item.product!.price,
      };
    }).toList();

    // Calculate total
    final double total = finalTotal;

    print('🛒 Checkout - Total: \$$total');
    print('📦 Items: $items');

    // Trigger BLoC event
    context.read<OrderBloc>().add(
      CheckoutEvent(
        addressId: selectedAddress!.id!,
        items: items,
        amount: total,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ✅ Listen to AddressBloc to load saved address
        BlocListener<AddressBloc, AddressState>(
          listener: (context, state) {
            if (state is AddressesLoaded && _isLoadingAddress) {
              final savedAddressId = StorageService.getSelectedAddressId();
              if (savedAddressId != null) {
                final address = state.addresses.firstWhere(
                  (addr) => addr.id == savedAddressId,
                  orElse: () => state.addresses.first,
                );
                setState(() {
                  selectedAddress = address;
                  _isLoadingAddress = false;
                });
                print('✅ Loaded saved address: ${address.name}');
              } else {
                setState(() {
                  _isLoadingAddress = false;
                });
              }
            }
          },
        ),

        // ✅ UPDATED: Listen to OrderBloc for checkout
        BlocListener<OrderBloc, OrderState>(
          listener: (context, state) {
            // ✅ REMOVED: No loading dialog!
            if (state is CheckoutSuccess) {
              // ✅ NEW STATE! (No Navigator.pop needed!)

              print('✅ Checkout success! Order #${state.orderId}');
              print(
                '📱 QR Code: ${state.qrCode != null ? "Received" : "NULL"}',
              );

              // ❌ REMOVED: Don't send notification on order creation!
              // Notification will be sent on payment success or timeout

              // ✅ DELETE ITEMS FROM CART
              for (var item in widget.selectedItems) {
                context.read<CartBloc>().add(RemoveFromCart(cartId: item.id));
              }

              // Refresh cart
              Future.delayed(const Duration(milliseconds: 500), () {
                context.read<CartBloc>().add(const LoadCart());
              });

              // ✅ CHECK IF QR CODE IS AVAILABLE
              if (state.qrCode != null && state.expiresAt != null) {
                // Show QR Payment Dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => QRPaymentDialog(
                    orderId: state.orderId,
                    qrCode: state.qrCode!,
                    expiresAt: state.expiresAt!,
                    amount: finalTotal,
                  ),
                );
              } else {
                // QR not available, show error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Order created but QR code generation failed. Please contact support.',
                      style: TextStyle(fontFamily: kantumruyPro),
                    ),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 5),
                  ),
                );

                // Navigate back to home
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.pop(context); // Go back to cart
                });
              }
            } else if (state is CheckoutFailure) {
              // ✅ NEW STATE!
              Navigator.pop(context); // Close loading

              // Show error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.error,
                    style: TextStyle(fontFamily: kantumruyPro),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
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
            'Checkout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: kantumruyPro,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Order Items List
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Delivery Address Section
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _navigateToAddressSelection,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xFF6C5CE7),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Delivery Address',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: kantumruyPro,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildAddressSection(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Order Items Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Color(0xFF6C5CE7),
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Order Items (${widget.selectedItems.length})',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: kantumruyPro,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, thickness: 1),
                          ...widget.selectedItems.map(
                            (item) => _buildOrderItem(item),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Price Summary Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildPriceRow('Subtotal', subtotal),
                          const SizedBox(height: 12),
                          const Divider(height: 1, thickness: 1),
                          const SizedBox(height: 12),
                          _buildPriceRow('Total', finalTotal, isTotal: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),

            // ✅ Place Order Button (calls _checkout)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: selectedAddress != null ? _checkout : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${finalTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.grey[700],
            fontFamily: kantumruyPro,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF6C5CE7) : Colors.black,
            fontFamily: kantumruyPro,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return selectedAddress != null
        ? Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF6C5CE7),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedAddress!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: kantumruyPro,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C5CE7).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Selected',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6C5CE7),
                              fontFamily: kantumruyPro,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      selectedAddress!.fullAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: kantumruyPro,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF6C5CE7),
                size: 18,
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_location_alt_outlined,
                color: Colors.grey[600],
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Select delivery address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  fontFamily: kantumruyPro,
                ),
              ),
            ],
          );
  }

  Widget _buildOrderItem(CartItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.product?.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: "${ApiConfig.baseUrl}${item.product!.image!}",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF6C5CE7),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image_outlined,
                        size: 35,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                : Icon(Icons.image_outlined, size: 35, color: Colors.grey[400]),
          ),
          const SizedBox(width: 16),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? 'Product',
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
                    // Price
                    Text(
                      '\$${item.product?.price.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C5CE7),
                        fontFamily: kantumruyPro,
                      ),
                    ),

                    // Quantity
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Qty: ${item.qty}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          fontFamily: kantumruyPro,
                        ),
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

  void _navigateToAddressSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Address(
          selectedAddressId: selectedAddress?.id,
          onAddressSelected: (address) {
            // This callback is called from Address screen
            // No need to do anything here, we handle it below
          },
        ),
      ),
    );

    // ✅ Handle the returned address and SAVE IT
    if (result != null && result is AddressModel) {
      setState(() {
        selectedAddress = result;
      });
      // ✅ Save to storage for future use
      if (result.id != null) {
        StorageService.saveSelectedAddressId(result.id!);
      }
      print('✅ Address selected and saved: ${result.name}');
    }
  }
}
