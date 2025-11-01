import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mini_mart/bloc/cart/cart_bloc.dart';
import 'package:mini_mart/bloc/cart/cart_event.dart';
import 'package:mini_mart/bloc/cart/cart_state.dart';
import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/model/cart/cart_model.dart';
import 'package:mini_mart/screens/check_out/check_out.dart';
import 'package:mini_mart/styles/fonts.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // ✅ Track selected items
  Set<int> selectedItemIds = {};

  // ✅ Group items by category
  Map<String, List<CartItem>> groupedItems = {};

  // ✅ Track selected categories (for select all in category)
  Set<String> selectedCategories = {};

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const LoadCart());
  }

  void _groupItemsByCategory(List<CartItem> items) {
    groupedItems.clear();
    for (var item in items) {
      final categoryName = item.product?.category?.name ?? 'Uncategorized';
      if (!groupedItems.containsKey(categoryName)) {
        groupedItems[categoryName] = [];
      }
      groupedItems[categoryName]!.add(item);
    }
  }

  void _toggleSelectAll() {
    setState(() {
      if (selectedItemIds.length == _getTotalItemCount()) {
        // Deselect all
        selectedItemIds.clear();
        selectedCategories.clear();
      } else {
        // Select all
        selectedCategories.addAll(groupedItems.keys);
        selectedItemIds.clear();
        groupedItems.forEach((category, items) {
          for (var item in items) {
            selectedItemIds.add(item.id);
          }
        });
      }
    });
  }

  void _toggleCategorySelection(String categoryName) {
    setState(() {
      if (selectedCategories.contains(categoryName)) {
        // Deselect category
        selectedCategories.remove(categoryName);
        final categoryItems = groupedItems[categoryName] ?? [];
        for (var item in categoryItems) {
          selectedItemIds.remove(item.id);
        }
      } else {
        // Select category
        selectedCategories.add(categoryName);
        final categoryItems = groupedItems[categoryName] ?? [];
        for (var item in categoryItems) {
          selectedItemIds.add(item.id);
        }
      }
    });
  }

  void _toggleItemSelection(CartItem item) {
    setState(() {
      if (selectedItemIds.contains(item.id)) {
        selectedItemIds.remove(item.id);
        // Check if category should be deselected
        final categoryName = item.product?.category?.name ?? 'Uncategorized';
        final categoryItems = groupedItems[categoryName] ?? [];
        final allSelected = categoryItems.every(
          (i) => selectedItemIds.contains(i.id),
        );
        if (!allSelected) {
          selectedCategories.remove(categoryName);
        }
      } else {
        selectedItemIds.add(item.id);
        // Check if all items in category are now selected
        final categoryName = item.product?.category?.name ?? 'Uncategorized';
        final categoryItems = groupedItems[categoryName] ?? [];
        final allSelected = categoryItems.every(
          (i) => selectedItemIds.contains(i.id),
        );
        if (allSelected) {
          selectedCategories.add(categoryName);
        }
      }
    });
  }

  int _getTotalItemCount() {
    int count = 0;
    groupedItems.forEach((category, items) {
      count += items.length;
    });
    return count;
  }

  double _getSelectedTotal(List<CartItem> allItems) {
    double total = 0;
    for (var item in allItems) {
      if (selectedItemIds.contains(item.id)) {
        total += (item.product?.price ?? 0) * item.qty;
      }
    }
    return total;
  }

  int _getSelectedCount() {
    return selectedItemIds.length;
  }

  Future<void> _refreshCart() async {
    context.read<CartBloc>().add(const RefreshCart());
    await Future.delayed(const Duration(seconds: 1));
  }

  void _goToCheckout(List<CartItem> allItems) {
    // Get selected items
    final selectedItems = allItems
        .where((item) => selectedItemIds.contains(item.id))
        .toList();
    if (selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select items to checkout'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    } else {
      // Navigate to checkout screen with selected items
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckOutScreen(selectedItems: selectedItems),
        ),
      );
    }
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
        title: const Text(
          'My Cart',
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
            onPressed: _refreshCart,
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: Duration(milliseconds: 800),
              ),
            );
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
        builder: (context, state) {
          if (state is CartLoading) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFFDB3022)),
            );
          }

          if (state is CartEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      fontFamily: kantumruyPro,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Add some products to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                      fontFamily: kantumruyPro,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontFamily: kantumruyPro,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CartBloc>().add(const LoadCart());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFDB3022),
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<CartItem> items = [];

          // ✅ FIXED: Handle both CartLoaded and CartOperationSuccess states
          if (state is CartLoaded) {
            items = state.items;
          } else if (state is CartOperationSuccess) {
            items = state.items;
          }

          // Group items by category
          _groupItemsByCategory(items);

          return Stack(
            children: [
              Column(
                children: [
                  // ✅ Select All Header
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Checkbox(
                          value:
                              selectedItemIds.length == _getTotalItemCount() &&
                              _getTotalItemCount() > 0,
                          onChanged: (value) => _toggleSelectAll(),
                          activeColor: Color(0xFFDB3022),
                        ),
                        Text(
                          'Select All',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: kantumruyPro,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${selectedItemIds.length}/${_getTotalItemCount()} selected',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: kantumruyPro,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),

                  // ✅ Cart Items Grouped by Category
                  Expanded(
                    child: RefreshIndicator(
                      color: Color(0xFFDB3022),
                      onRefresh: _refreshCart,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 200),
                        itemCount: groupedItems.length,
                        itemBuilder: (context, index) {
                          final categoryName = groupedItems.keys.elementAt(
                            index,
                          );
                          final categoryItems = groupedItems[categoryName]!;

                          return _CategorySection(
                            categoryName: categoryName,
                            items: categoryItems,
                            isSelected: selectedCategories.contains(
                              categoryName,
                            ),
                            selectedItemIds: selectedItemIds,
                            onCategoryToggle: () =>
                                _toggleCategorySelection(categoryName),
                            onItemToggle: _toggleItemSelection,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // ✅ Checkout Button
              Positioned(
                left: 20,
                right: 20,
                bottom: 90,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () => _goToCheckout(items),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFDB3022), Color(0xFFFF6B6B)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDB3022).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Checkout (${_getSelectedCount()})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: kantumruyPro,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '\$${_getSelectedTotal(items).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: kantumruyPro,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ✅ Category Section Widget
class _CategorySection extends StatelessWidget {
  final String categoryName;
  final List<CartItem> items;
  final bool isSelected;
  final Set<int> selectedItemIds;
  final VoidCallback onCategoryToggle;
  final Function(CartItem) onItemToggle;

  const _CategorySection({
    required this.categoryName,
    required this.items,
    required this.isSelected,
    required this.selectedItemIds,
    required this.onCategoryToggle,
    required this.onItemToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Category Header with Checkbox
          GestureDetector(
            onTap: onCategoryToggle,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Color(0xFFF8F8F8),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) => onCategoryToggle(),
                    activeColor: Color(0xFFDB3022),
                  ),
                  Icon(Icons.category, size: 20, color: Color(0xFFDB3022)),
                  SizedBox(width: 8),
                  Text(
                    categoryName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: kantumruyPro,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${items.length} item${items.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: kantumruyPro,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Category Items
          ...items.map(
            (item) => _CartItemWidget(
              item: item,
              isSelected: selectedItemIds.contains(item.id),
              onToggle: () => onItemToggle(item),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Cart Item Widget with Checkbox
class _CartItemWidget extends StatelessWidget {
  final CartItem item;
  final bool isSelected;
  final VoidCallback onToggle;

  const _CartItemWidget({
    required this.item,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          // ✅ Checkbox
          Checkbox(
            value: isSelected,
            onChanged: (value) => onToggle(),
            activeColor: Color(0xFFDB3022),
          ),

          // Product Image
          Container(
            width: 70,
            height: 70,
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
                          color: Color(0xFFDB3022),
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
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
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
                const SizedBox(height: 6),

                // Price & Quantity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Text(
                      '\$${item.product?.price.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDB3022),
                        fontFamily: kantumruyPro,
                      ),
                    ),

                    // Quantity Controls
                    Row(
                      children: [
                        // Decrease
                        GestureDetector(
                          onTap: () {
                            if (item.qty > 1) {
                              context.read<CartBloc>().add(
                                UpdateCartQuantity(
                                  cartId: item.id,
                                  qty: item.qty - 1,
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.remove, size: 16),
                          ),
                        ),

                        // Quantity
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${item.qty}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: kantumruyPro,
                            ),
                          ),
                        ),

                        // Increase
                        GestureDetector(
                          onTap: () {
                            context.read<CartBloc>().add(
                              UpdateCartQuantity(
                                cartId: item.id,
                                qty: item.qty + 1,
                              ),
                            );
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Color(0xFFDB3022),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(width: 8),

                        // Delete
                        GestureDetector(
                          onTap: () {
                            context.read<CartBloc>().add(
                              RemoveFromCart(cartId: item.id),
                            );
                          },
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      ],
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
}
