// ignore_for_file: deprecated_member_use
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/bloc/user/user_event.dart';
import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/config/storage_service.dart';
import 'package:mini_mart/model/advertising/advertising_model.dart';
import 'package:mini_mart/model/category/category_model.dart';
import 'package:mini_mart/model/product/product_model.dart';
import 'package:mini_mart/repositories/advertising/advertising_repository.dart';
import 'package:mini_mart/repositories/category/category_repository.dart';
import 'package:mini_mart/repositories/product/product_repository.dart';
import 'package:mini_mart/screens/notification_screen/notification_screen.dart';
import 'package:mini_mart/screens/product_screen/view/product_detail.dart';
import 'package:mini_mart/services/api_service.dart';
import 'package:mini_mart/styles/fonts.dart';
import 'package:mini_mart/bloc/user/user_bloc.dart';
import 'package:mini_mart/bloc/user/user_state.dart';
import 'package:mini_mart/bloc/order/order_bloc.dart';
import 'package:mini_mart/bloc/order/order_event.dart';
import 'package:mini_mart/bloc/order/order_state.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AdvertisingRepository _advertisingRepo = AdvertisingRepository(
    ApiService(),
  );
  final CategoryRepository _categoryRepo = CategoryRepository(ApiService());
  final ProductRepository _productRepo = ProductRepository(ApiService());

  List<AdvertisingModel> _advertisingList = [];
  List<Category> _categoryList = [];
  List<Product> _productList = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _loadUserInfo();
    context.read<OrderBloc>().add(GetMyOrdersEvent());
  }

  Future<void> _loadUserInfo() async {
    final userId = StorageService.getUserId();
    if (userId != null) {
      context.read<UserBloc>().add(GetUserInfoEvent(userId: userId));
    }
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadAdvertising(),
        _loadCategories(),
        _loadProducts(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load home screen data: $e')),
        );
      }
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadAdvertising() async {
    try {
      List<AdvertisingModel> allAds = await _advertisingRepo
          .getAllAdvertising();
      _advertisingList = allAds.where((ad) => ad.isActive == true).toList();
    } catch (e) {
      print('Error loading advertising: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      CategoryModel categoryModel = await _categoryRepo.getCategories();
      _categoryList = categoryModel.data.take(8).toList();
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadProducts() async {
    try {
      ProductResponse productResponse = await _productRepo.getProducts();
      _productList = productResponse.data.take(10).toList();
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildProfileAvatar(String? profileImageUrl, String userName) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';
    const double radius = 20;

    Widget defaultAvatar = CircleAvatar(
      backgroundColor: Colors.grey[800],
      radius: radius,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: kantumruyPro,
        ),
      ),
    );

    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: Image.network(
            "${ApiConfig.baseUrl}$profileImageUrl",
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return defaultAvatar;
            },
          ),
        ),
      );
    }

    return defaultAvatar;
  }

  // ✅ NEW: Build notification icon with badge
  Widget _buildNotificationIcon(int failedOrderCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
            // Reload orders when returning from notification screen
            if (mounted) {
              context.read<OrderBloc>().add(GetMyOrdersEvent());
            }
          },
          child: const Icon(Icons.notifications_outlined, size: 28),
        ),
        // Badge
        if (failedOrderCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFF44336),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  failedOrderCount > 99 ? '99+' : failedOrderCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: kantumruyPro,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await _loadAllData();
                  _loadUserInfo();
                  context.read<OrderBloc>().add(GetMyOrdersEvent());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with notification badge
                      BlocBuilder<UserBloc, UserState>(
                        builder: (context, userState) {
                          String userName = 'Guest';
                          String? profileImageUrl;

                          if (userState is UserLoaded) {
                            userName = userState.user.name.split(' ')[0];
                            profileImageUrl = userState.user.image;
                          } else if (userState is UserUpdated) {
                            userName = userState.user.name.split(' ')[0];
                            profileImageUrl = userState.user.image;
                          }

                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                _buildProfileAvatar(profileImageUrl, userName),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontFamily: kantumruyPro,
                                      ),
                                    ),
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: kantumruyPro,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                // ✅ UPDATED: Show UNREAD count only
                                BlocBuilder<OrderBloc, OrderState>(
                                  builder: (context, state) {
                                    int unreadCount = 0;
                                    if (state is MyOrdersLoaded) {
                                      // Get failed orders that are UNREAD only
                                      unreadCount = state.orders
                                          .where(
                                            (order) =>
                                                order.status.toLowerCase() ==
                                                    'failed' &&
                                                !order.notificationRead,
                                          ) // ✅ Check if unread
                                          .length;
                                    }
                                    return _buildNotificationIcon(unreadCount);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Advertising Slider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _advertisingList.isEmpty
                            ? Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'No Active Ads',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            : CarouselSlider.builder(
                                itemCount: _advertisingList.length,
                                itemBuilder: (context, index, realIndex) {
                                  final ad = _advertisingList[index];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      "${ApiConfig.baseUrl}${ad.imageUrl}",
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.red.shade100,
                                              child: Center(
                                                child: Text(
                                                  'Image Load Error',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontFamily: kantumruyPro,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                  height: 150,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 4),
                                  viewportFraction: 1.0,
                                ),
                              ),
                      ),

                      if (_advertisingList.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _advertisingList.asMap().entries.map((
                              entry,
                            ) {
                              return GestureDetector(
                                onTap: () => {},
                                child: Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black)
                                            .withOpacity(0),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Category Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          mainAxisSpacing: 30,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                          children: _categoryList
                              .map(
                                (category) => _buildCategoryItem(
                                  category.name,
                                  category.image ?? '',
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Products Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: _productList.length,
                          itemBuilder: (context, index) {
                            final product = _productList[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailScreen(product: product),
                                  ),
                                );
                              },
                              child: _buildProductCard(product),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCategoryItem(String name, String imageUrl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "${ApiConfig.baseUrl}$imageUrl",
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 11, fontFamily: kantumruyPro),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: Image.network(
                        "${ApiConfig.baseUrl}${product.image}",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (product.stock != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: product.stock!.qty > 50
                            ? Colors.green
                            : product.stock!.qty > 20
                            ? Colors.orange
                            : Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.stock!.qty.toString(),
                        style: const TextStyle(
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    fontFamily: kantumruyPro,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.price}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDB3022),
                        fontFamily: kantumruyPro,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          product.category!.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: kantumruyPro,
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
