import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/bloc/cart/cart_bloc.dart';
import 'package:mini_mart/bloc/cart/cart_event.dart';
import 'package:mini_mart/bloc/cart/cart_state.dart';
import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/model/product/product_model.dart';
import 'package:mini_mart/styles/fonts.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  void _increaseQuantity() {
    if (quantity < widget.product.stock!.qty) {
      setState(() {
        quantity++;
      });
    }
  }

  void _decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  double get totalPrice => widget.product.price * quantity;

  // Add to cart - Real time, no dialog
  void _addToCart() {
    context.read<CartBloc>().add(
      AddToCart(productId: widget.product.id, qty: quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
          // Reset quantity after adding
          setState(() {
            quantity = 1;
          });
        } else if (state is CartError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Image Section
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Container(
                        height: 380,
                        width: double.infinity,
                        color: const Color(0xFFF0F0F0),
                        child: widget.product.image != null
                            ? CachedNetworkImage(
                                imageUrl:
                                    ApiConfig.baseUrl + widget.product.image!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFDB3022),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 100,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.inventory_2,
                                  size: 100,
                                  color: Colors.grey[400],
                                ),
                              ),
                      ),
                      // Back Button
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      // Stock Badge
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.product.stock!.qty > 50
                                ? Colors.green
                                : widget.product.stock!.qty > 20
                                ? Colors.orange
                                : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Stock: ${widget.product.stock?.qty}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: kantumruyPro,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content Section
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            widget.product.name,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: kantumruyPro,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Category Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFDB3022).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.product.category!.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFDB3022),
                                fontFamily: kantumruyPro,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Price & Quantity
                          Row(
                            children: [
                              Text(
                                '\$${widget.product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDB3022),
                                  fontFamily: kantumruyPro,
                                ),
                              ),
                              Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: _decreaseQuantity,
                                      icon: Icon(Icons.remove),
                                      color: quantity > 1
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$quantity',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: kantumruyPro,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _increaseQuantity,
                                      icon: Icon(Icons.add),
                                      color:
                                          quantity < widget.product.stock!.qty
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Description
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: kantumruyPro,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.product.detail ?? "",
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF666666),
                              height: 1.6,
                              fontFamily: kantumruyPro,
                            ),
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Bottom Add to Cart Button
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Total Price',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF666666),
                                  fontFamily: kantumruyPro,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '\$${totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDB3022),
                                  fontFamily: kantumruyPro,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _addToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDB3022),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
            ),
          ],
        ),
      ),
    );
  }
}
