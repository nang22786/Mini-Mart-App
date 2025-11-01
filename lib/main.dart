// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mini_mart/bloc/address/address_bloc.dart';
// import 'package:mini_mart/bloc/auth/auth_bloc.dart';
// import 'package:mini_mart/bloc/cart/cart_bloc.dart';
// import 'package:mini_mart/bloc/category/category_bloc.dart';
// import 'package:mini_mart/bloc/order/order_bloc.dart';
// import 'package:mini_mart/bloc/product/product_bloc.dart';
// import 'package:mini_mart/bloc/user/user_bloc.dart';
// import 'package:mini_mart/config/storage_service.dart';
// import 'package:mini_mart/repositories/address/address_repository.dart';
// import 'package:mini_mart/repositories/cart/cart_respository.dart';
// import 'package:mini_mart/repositories/category/category_repository.dart';
// import 'package:mini_mart/repositories/order/order_repository.dart';
// import 'package:mini_mart/repositories/product/product_repository.dart';
// import 'package:mini_mart/repositories/user/auth_repository.dart';
// import 'package:mini_mart/screens/splash_screen/splash_screen.dart';
// import 'package:mini_mart/services/api_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Storage Service
//   await StorageService.init();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Create repository instances
//     final authRepository = AuthRepository();
//     final apiService = ApiService();
//     final categoryRepository = CategoryRepository(apiService);
//     final productRepository = ProductRepository(apiService);
//     final cartRepository = CartRepository(apiService);
//     final addressRepository = AddressRepository(apiService);
//     final orderRepository = OrderRepository(apiService);

//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => AuthBloc(authRepository: authRepository),
//         ),
//         BlocProvider(
//           create: (context) => UserBloc(authRepository: authRepository),
//         ),
//         BlocProvider(create: (context) => CategoryBloc(categoryRepository)),
//         BlocProvider(create: (context) => ProductBloc(productRepository)),
//         BlocProvider(create: (context) => CartBloc(cartRepository)),
//         BlocProvider(create: (context) => AddressBloc(addressRepository)),
//         BlocProvider(create: (context) => OrderBloc(orderRepository)),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Mini Mart',
//         theme: ThemeData(
//           primarySwatch: Colors.red,
//           scaffoldBackgroundColor: Colors.white,
//         ),
//         home: const SplashScreen(),
//       ),
//     );
//   }
// }

// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mini_mart/bloc/address/address_bloc.dart';
import 'package:mini_mart/bloc/advertising/advertising_bloc.dart';
import 'package:mini_mart/bloc/auth/auth_bloc.dart';
import 'package:mini_mart/bloc/cart/cart_bloc.dart';
import 'package:mini_mart/bloc/category/category_bloc.dart';
import 'package:mini_mart/bloc/order/order_bloc.dart';
import 'package:mini_mart/bloc/product/product_bloc.dart';
import 'package:mini_mart/bloc/user/user_bloc.dart';
import 'package:mini_mart/config/storage_service.dart';
import 'package:mini_mart/repositories/address/address_repository.dart';
import 'package:mini_mart/repositories/advertising/advertising_repository.dart';
import 'package:mini_mart/repositories/cart/cart_respository.dart';
import 'package:mini_mart/repositories/category/category_repository.dart';
import 'package:mini_mart/repositories/order/order_repository.dart';
import 'package:mini_mart/repositories/product/product_repository.dart';
import 'package:mini_mart/repositories/user/auth_repository.dart';
import 'package:mini_mart/screens/splash_screen/splash_screen.dart';
import 'package:mini_mart/services/api_service.dart';
import 'package:mini_mart/services/fcm_service.dart';

// ✅ Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage Service
  await StorageService.init();

  // ✅ Initialize Firebase
  await Firebase.initializeApp();

  // ✅ Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Initialize FCM Service
  await FCMService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create repository instances
    final authRepository = AuthRepository();
    final apiService = ApiService();
    final categoryRepository = CategoryRepository(apiService);
    final productRepository = ProductRepository(apiService);
    final cartRepository = CartRepository(apiService);
    final addressRepository = AddressRepository(apiService);
    final orderRepository = OrderRepository(apiService);
    final advertisingRepository = AdvertisingRepository(apiService);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider(
          create: (context) => UserBloc(authRepository: authRepository),
        ),
        BlocProvider(create: (context) => CategoryBloc(categoryRepository)),
        BlocProvider(create: (context) => ProductBloc(productRepository)),
        BlocProvider(create: (context) => CartBloc(cartRepository)),
        BlocProvider(create: (context) => AddressBloc(addressRepository)),
        BlocProvider(create: (context) => OrderBloc(orderRepository)),
        BlocProvider(
          create: (context) => AdvertisingBloc(advertisingRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mini Mart',
        theme: ThemeData(
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
