// lib/screens/product_screen/product_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/bloc/cart/cart_bloc.dart';
import 'package:mini_mart/bloc/cart/cart_event.dart';
import 'package:mini_mart/bloc/category/category_bloc.dart';
import 'package:mini_mart/bloc/category/category_event.dart';
import 'package:mini_mart/bloc/category/category_state.dart';
import 'package:mini_mart/bloc/product/product_bloc.dart';
import 'package:mini_mart/bloc/product/product_event.dart';
import 'package:mini_mart/bloc/product/product_state.dart';
import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/model/category/category_model.dart';
import 'package:mini_mart/model/product/product_model.dart';
import 'package:mini_mart/screens/product_screen/view/product_detail.dart';
import 'package:mini_mart/styles/fonts.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with SingleTickerProviderStateMixin {
  bool _showSidebar = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  AnimationController? _searchAnimationController;

  @override
  void initState() {
    super.initState();
    // Load categories and products
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<ProductBloc>().add(LoadProducts());

    // ✅ Load cart on app start for badge count
    context.read<CartBloc>().add(const LoadCart());

    _searchAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchAnimationController?.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _searchAnimationController?.forward();
        _searchFocusNode.requestFocus();
      } else {
        _searchAnimationController?.reverse();
        _searchController.clear();
        _searchFocusNode.unfocus();
        context.read<ProductBloc>().add(LoadProducts());
      }
    });
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      context.read<ProductBloc>().add(SearchProducts(query));
    } else {
      context.read<ProductBloc>().add(LoadProducts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _isSearching
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _toggleSearch,
              )
            : IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () => setState(() => _showSidebar = !_showSidebar),
              ),
        title: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: _isSearching
              ? TextField(
                  key: ValueKey('search'),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _performSearch,
                  style: TextStyle(fontFamily: kantumruyPro),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: TextStyle(fontFamily: kantumruyPro),
                    border: InputBorder.none,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ProductBloc>().add(LoadProducts());
                            },
                          )
                        : null,
                  ),
                )
              : Text(
                  'Products',
                  key: ValueKey('title'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: kantumruyPro,
                  ),
                ),
        ),
        actions: _isSearching
            ? []
            : [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.black),
                  onPressed: _toggleSearch,
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.black),
                  onPressed: () {
                    context.read<CategoryBloc>().add(RefreshCategories());
                    context.read<ProductBloc>().add(RefreshProducts());
                    context.read<CartBloc>().add(const RefreshCart());
                  },
                ),
              ],
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, categoryState) {
            if (categoryState is CategoryLoading) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xFFDB3022)),
              );
            }

            if (categoryState is CategoryError) {
              return _buildErrorWidget(
                categoryState.message,
                () => context.read<CategoryBloc>().add(LoadCategories()),
              );
            }

            if (categoryState is CategoryLoaded) {
              final categories = categoryState.categories;

              return Stack(
                children: [
                  Row(
                    children: [
                      if (_showSidebar) SizedBox(width: 120),
                      Expanded(
                        child: BlocBuilder<ProductBloc, ProductState>(
                          builder: (context, productState) {
                            if (productState is ProductLoading) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFDB3022),
                                ),
                              );
                            }

                            if (productState is ProductError) {
                              return _buildErrorWidget(
                                productState.message,
                                () => context.read<ProductBloc>().add(
                                  LoadProducts(),
                                ),
                              );
                            }

                            if (productState is ProductLoaded) {
                              final products = productState.filteredProducts;

                              if (products.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No products available',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          fontFamily: kantumruyPro,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return RefreshIndicator(
                                color: Color(0xFFDB3022),
                                onRefresh: () async {
                                  context.read<ProductBloc>().add(
                                    RefreshProducts(),
                                  );
                                  await Future.delayed(Duration(seconds: 1));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 100),
                                  child: ListView.builder(
                                    padding: EdgeInsets.all(16),
                                    itemCount: (products.length / 2).ceil(),
                                    itemBuilder: (context, index) {
                                      final leftIndex = index * 2;
                                      final rightIndex = leftIndex + 1;

                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: _buildProductCard(
                                                product: products[leftIndex],
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            if (rightIndex < products.length)
                                              Expanded(
                                                child: _buildProductCard(
                                                  product: products[rightIndex],
                                                ),
                                              )
                                            else
                                              Expanded(child: SizedBox()),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }

                            return Center(
                              child: Text(
                                'Start loading products',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: kantumruyPro,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Sidebar
                  if (_showSidebar)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 120,
                        color: Colors.grey[50],
                        child: Column(
                          children: [
                            _buildCategorySidebarItem(
                              category: null,
                              isSelected:
                                  categoryState.selectedCategoryId == null ||
                                  categoryState.selectedCategoryId == 0,
                              onTap: () {
                                context.read<CategoryBloc>().add(
                                  SelectCategory(0),
                                );
                                context.read<ProductBloc>().add(
                                  FilterProductsByCategory(null),
                                );
                                setState(() => _showSidebar = false);
                              },
                            ),
                            Divider(height: 1),
                            Expanded(
                              child: ListView.builder(
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  var category = categories[index];
                                  bool isSelected =
                                      categoryState.selectedCategoryId ==
                                      category.id;

                                  return _buildCategorySidebarItem(
                                    category: category,
                                    isSelected: isSelected,
                                    onTap: () {
                                      context.read<CategoryBloc>().add(
                                        SelectCategory(category.id),
                                      );
                                      context.read<ProductBloc>().add(
                                        FilterProductsByCategory(category.id),
                                      );
                                      setState(() => _showSidebar = false);
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),

                  if (_showSidebar)
                    Positioned.fill(
                      left: 120,
                      child: GestureDetector(
                        onTap: () => setState(() => _showSidebar = false),
                        child: Container(color: Colors.black.withOpacity(0.3)),
                      ),
                    ),
                ],
              );
            }

            return Center(
              child: Text(
                'No categories available',
                style: TextStyle(fontSize: 16, fontFamily: kantumruyPro),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontFamily: kantumruyPro,
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFDB3022),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySidebarItem({
    required Category? category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? Color(0xFFDB3022) : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Color(0xFFDB3022).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: category == null
                  ? Icon(Icons.apps, color: Colors.grey[600], size: 24)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: ApiConfig.baseUrl + category.image.toString(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFDB3022),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.category, color: Colors.grey[600]),
                      ),
                    ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category?.name ?? 'All',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey[600],
                  fontFamily: kantumruyPro,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({required Product product}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: product.image != null
                        ? CachedNetworkImage(
                            imageUrl: ApiConfig.baseUrl + product.image!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFDB3022),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Image.network(
                                product.image ?? "",
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  // Stock Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: product.stock!.qty > 50
                            ? Colors.green
                            : product.stock!.qty > 20
                            ? Colors.orange
                            : Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${product.stock!.qty}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Info
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      fontFamily: kantumruyPro,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    product.category!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontFamily: kantumruyPro,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDB3022),
                            fontFamily: kantumruyPro,
                          ),
                        ),
                      ),
                      // ✅ QUICK ADD TO CART - Real-time, instant add
                      GestureDetector(
                        onTap: () {
                          // Instant add 1 item to cart
                          context.read<CartBloc>().add(
                            AddToCart(productId: product.id, qty: 1),
                          );

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              backgroundColor: Colors.green,
                              duration: Duration(milliseconds: 800),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Color(0xFFDB3022),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 16,
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
      ),
    );
  }
}
