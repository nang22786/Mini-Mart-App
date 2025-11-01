import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/bloc/cart/cart_event.dart';
import 'package:mini_mart/bloc/cart/cart_state.dart';
import 'package:mini_mart/model/cart/cart_model.dart';
import 'package:mini_mart/repositories/cart/cart_respository.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;

  CartBloc(this._cartRepository) : super(const CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    on<RefreshCart>(_onRefreshCart);
  }

  // Private method to calculate cart totals
  Map<String, dynamic> _calculateTotals(List<CartItem> items) {
    final totalPrice = items.fold<double>(
      0,
      (sum, item) => sum + item.getSubtotal(),
    );
    final totalItems = items.fold<int>(0, (sum, item) => sum + item.qty);

    return {'totalPrice': totalPrice, 'totalItems': totalItems};
  }

  // Handle Load Cart Event
  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(const CartLoading());
    try {
      final items = await _cartRepository.getCart();

      if (items.isEmpty) {
        emit(const CartEmpty());
      } else {
        final totals = _calculateTotals(items);
        emit(
          CartLoaded(
            items: items,
            totalPrice: totals['totalPrice'] as double,
            totalItems: totals['totalItems'] as int,
          ),
        );
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  // Handle Add To Cart Event
  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      final result = await _cartRepository.addToCart(
        productId: event.productId,
        qty: event.qty,
      );

      if (result['success'] == true) {
        // Reload cart to get updated data
        final items = await _cartRepository.getCart();
        final totals = _calculateTotals(items);

        emit(
          CartOperationSuccess(
            message:
                result['message'] as String? ?? 'Added to cart successfully',
            items: items,
            totalPrice: totals['totalPrice'] as double,
            totalItems: totals['totalItems'] as int,
          ),
        );
      } else {
        emit(
          CartError(
            message: result['message'] as String? ?? 'Failed to add to cart',
          ),
        );
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  // Handle Update Cart Quantity Event
  Future<void> _onUpdateCartQuantity(
    UpdateCartQuantity event,
    Emitter<CartState> emit,
  ) async {
    try {
      final result = await _cartRepository.updateCartQuantity(
        cartId: event.cartId,
        qty: event.qty,
      );

      if (result['success'] == true) {
        // Reload cart
        final items = await _cartRepository.getCart();
        final totals = _calculateTotals(items);

        emit(
          CartOperationSuccess(
            message: 'Cart updated successfully',
            items: items,
            totalPrice: totals['totalPrice'] as double,
            totalItems: totals['totalItems'] as int,
          ),
        );
      } else {
        emit(
          CartError(
            message: result['message'] as String? ?? 'Failed to update cart',
          ),
        );
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  // Handle Remove From Cart Event
  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      final result = await _cartRepository.removeFromCart(event.cartId);

      if (result['success'] == true) {
        // Reload cart
        final items = await _cartRepository.getCart();

        if (items.isEmpty) {
          emit(const CartEmpty());
        } else {
          final totals = _calculateTotals(items);
          emit(
            CartOperationSuccess(
              message: 'Item removed from cart',
              items: items,
              totalPrice: totals['totalPrice'] as double,
              totalItems: totals['totalItems'] as int,
            ),
          );
        }
      } else {
        emit(
          CartError(
            message: result['message'] as String? ?? 'Failed to remove item',
          ),
        );
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  // Handle Clear Cart Event
  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      final result = await _cartRepository.clearCart();

      if (result['success'] == true) {
        emit(const CartEmpty());
      } else {
        emit(
          CartError(
            message: result['message'] as String? ?? 'Failed to clear cart',
          ),
        );
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  // Handle Refresh Cart Event
  Future<void> _onRefreshCart(
    RefreshCart event,
    Emitter<CartState> emit,
  ) async {
    await _onLoadCart(const LoadCart(), emit);
  }
}
