import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/config/storage_service.dart';
import 'package:mini_mart/model/cart/cart_model.dart';
import 'package:mini_mart/services/api_service.dart';

class CartRepository {
  final ApiService _apiService;

  CartRepository(this._apiService);

  // Get current user ID from storage
  int? _getCurrentUserId() {
    return StorageService.getUserId();
  }

  // Validate user is logged in
  void _validateUserLoggedIn() {
    if (_getCurrentUserId() == null) {
      throw Exception('User not logged in. Please login first.');
    }
  }

  // Get user's cart items
  Future<List<CartItem>> getCart() async {
    try {
      _validateUserLoggedIn();
      final userId = _getCurrentUserId()!;

      final response = await _apiService.get(
        '${ApiConfig.getCartUserID}/$userId',
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          response.data['message'] as String? ?? 'Failed to load cart',
        );
      }
    } catch (e) {
      throw Exception('Error loading cart: ${e.toString()}');
    }
  }

  // Get cart summary with totals
  Future<CartSummary> getCartSummary() async {
    try {
      _validateUserLoggedIn();
      final userId = _getCurrentUserId()!;

      final response = await _apiService.get(
        '${ApiConfig.getCartSummary}/$userId/summary',
      );

      return CartSummary.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error loading cart summary: ${e.toString()}');
    }
  }

  // Add product to cart
  Future<Map<String, dynamic>> addToCart({
    required int productId,
    required int qty,
  }) async {
    try {
      _validateUserLoggedIn();
      final userId = _getCurrentUserId()!;

      if (qty <= 0) {
        throw Exception('Quantity must be greater than 0');
      }

      final response = await _apiService.post(
        ApiConfig.addCart,
        data: {'userId': userId, 'productId': productId, 'qty': qty},
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error adding to cart: ${e.toString()}');
    }
  }

  // Update cart item quantity
  Future<Map<String, dynamic>> updateCartQuantity({
    required int cartId,
    required int qty,
  }) async {
    try {
      if (qty <= 0) {
        throw Exception('Quantity must be greater than 0');
      }

      final response = await _apiService.put(
        '${ApiConfig.updateCart}/$cartId',
        data: {'qty': qty},
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error updating cart: ${e.toString()}');
    }
  }

  // Remove item from cart
  Future<Map<String, dynamic>> removeFromCart(int cartId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConfig.updateCart}/$cartId',
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error removing from cart: ${e.toString()}');
    }
  }

  // Clear entire cart
  Future<Map<String, dynamic>> clearCart() async {
    try {
      _validateUserLoggedIn();
      final userId = _getCurrentUserId()!;

      final response = await _apiService.delete(
        '${ApiConfig.updateCart}/clear/$userId',
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error clearing cart: ${e.toString()}');
    }
  }

  // Get cart item count
  Future<int> getCartCount() async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        return 0;
      }

      final response = await _apiService.get(
        '${ApiConfig.getCartUserID}/$userId/count',
      );

      if (response.data['success'] == true) {
        return response.data['count'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Check if product is in cart
  Future<bool> isProductInCart(int productId) async {
    try {
      final items = await getCart();
      return items.any((item) => item.productId == productId);
    } catch (e) {
      return false;
    }
  }

  // Get specific cart item by product ID
  Future<CartItem?> getCartItemByProductId(int productId) async {
    try {
      final items = await getCart();
      return items.firstWhere(
        (item) => item.productId == productId,
        orElse: () => throw Exception('Item not found'),
      );
    } catch (e) {
      return null;
    }
  }
}
