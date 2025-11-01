// lib/screens/screen_controller/screen_controller.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/bloc/cart/cart_bloc.dart';
import 'package:mini_mart/bloc/cart/cart_event.dart';
import 'package:mini_mart/bloc/cart/cart_state.dart';
import 'package:mini_mart/bloc/order/order_bloc.dart';
import 'package:mini_mart/bloc/order/order_event.dart';
import 'package:mini_mart/bloc/order/order_state.dart';
import 'package:mini_mart/bloc/user/user_bloc.dart';
import 'package:mini_mart/bloc/user/user_event.dart';
import 'package:mini_mart/config/storage_service.dart';
import 'package:mini_mart/screens/home_screen/home_screen.dart';
import 'package:mini_mart/screens/product_screen/product_screen.dart';
import 'package:mini_mart/screens/profile_screen/profile_screen.dart';
import 'package:mini_mart/screens/order_screen/order_screen.dart';
import 'package:mini_mart/screens/cart_screen/cart_screen.dart';
import 'package:mini_mart/styles/colors.dart';
import 'package:mini_mart/styles/fonts.dart';

class ScreenController extends StatefulWidget {
  final Function(Locale)? changeLocale;
  final int? index;
  const ScreenController({super.key, this.changeLocale, this.index});

  @override
  State<ScreenController> createState() => _ScreenControllerState();
}

class _ScreenControllerState extends State<ScreenController> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      _currentIndex = widget.index!;
    }

    // ✅ Load user info
    _loadUserInfo();

    // Load cart on app start
    context.read<CartBloc>().add(const LoadCart());

    // ✅ Load orders on app start
    context.read<OrderBloc>().add(GetMyOrdersEvent());
  }

  // ✅ Load user info
  Future<void> _loadUserInfo() async {
    final userId = StorageService.getUserId();
    if (userId != null) {
      context.read<UserBloc>().add(GetUserInfoEvent(userId: userId));
    }
  }

  void changeScreen(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Load cart when switching to cart screen
    if (index == 3) {
      context.read<CartBloc>().add(const LoadCart());
    }

    // ✅ Load orders when switching to orders screen
    if (index == 2) {
      context.read<OrderBloc>().add(GetMyOrdersEvent());
    }
  }

  List<Widget> get _pages => [
    HomeScreen(),
    ProductScreen(),
    OrdersScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;

    // ✅ Orders icon with UNREAD paid orders count badge
    if (index == 2) {
      return InkWell(
        onTap: () => changeScreen(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with badge
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(icon, color: isSelected ? black : iconColor, size: 26),
                // Badge - UNREAD paid orders count
                BlocBuilder<OrderBloc, OrderState>(
                  builder: (context, state) {
                    int unreadCount = 0;

                    if (state is MyOrdersLoaded) {
                      // ✅ Count UNREAD paid orders only
                      unreadCount = state.orders.where((order) {
                        return order.status.toLowerCase() == 'paid' &&
                            !order.notificationRead;
                      }).length;
                    }

                    if (unreadCount == 0) return const SizedBox.shrink();

                    return Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? black : iconColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: kantumruyPro,
              ),
            ),
          ],
        ),
      );
    }

    // Cart icon with quantity badge
    if (index == 3) {
      return InkWell(
        onTap: () => changeScreen(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with badge
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(icon, color: isSelected ? black : iconColor, size: 26),
                // Badge
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    int totalQty = 0;

                    if (state is CartLoaded) {
                      totalQty = state.totalItems;
                    } else if (state is CartOperationSuccess) {
                      totalQty = state.totalItems;
                    }

                    if (totalQty == 0) return const SizedBox.shrink();

                    return Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$totalQty',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? black : iconColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: kantumruyPro,
              ),
            ),
          ],
        ),
      );
    }

    // Regular nav items
    return InkWell(
      onTap: () => changeScreen(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? black : iconColor, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? black : iconColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: kantumruyPro,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          _pages[_currentIndex],
          Positioned(
            bottom: 15,
            left: 10,
            right: 10,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.075,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildNavItem(0, CupertinoIcons.house_fill, "Home"),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      1,
                      CupertinoIcons.square_grid_2x2,
                      "Products",
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(2, CupertinoIcons.bag, "Orders"),
                  ),
                  Expanded(
                    child: _buildNavItem(3, CupertinoIcons.cart, "Cart"),
                  ),
                  Expanded(
                    child: _buildNavItem(4, CupertinoIcons.person, "Profile"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
