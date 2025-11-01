import 'package:mini_mart/model/cart/cart_model.dart';

abstract class CartState {
  const CartState();
}

class CartInitial extends CartState {
  const CartInitial();

  @override
  String toString() => 'CartInitial';
}

class CartLoading extends CartState {
  const CartLoading();

  @override
  String toString() => 'CartLoading';
}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final double totalPrice;
  final int totalItems;

  const CartLoaded({
    required this.items,
    required this.totalPrice,
    required this.totalItems,
  });

  int get itemCount => items.length;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  @override
  String toString() =>
      'CartLoaded(items: ${items.length}, totalPrice: $totalPrice, totalItems: $totalItems)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartLoaded &&
        other.items == items &&
        other.totalPrice == totalPrice &&
        other.totalItems == totalItems;
  }

  @override
  int get hashCode =>
      items.hashCode ^ totalPrice.hashCode ^ totalItems.hashCode;
}

class CartEmpty extends CartState {
  const CartEmpty();

  @override
  String toString() => 'CartEmpty';
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  String toString() => 'CartError(message: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class CartOperationSuccess extends CartState {
  final String message;
  final List<CartItem> items;
  final double totalPrice;
  final int totalItems;

  const CartOperationSuccess({
    required this.message,
    required this.items,
    required this.totalPrice,
    required this.totalItems,
  });

  int get itemCount => items.length;

  @override
  String toString() =>
      'CartOperationSuccess(message: $message, items: ${items.length})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartOperationSuccess &&
        other.message == message &&
        other.items == items &&
        other.totalPrice == totalPrice &&
        other.totalItems == totalItems;
  }

  @override
  int get hashCode =>
      message.hashCode ^
      items.hashCode ^
      totalPrice.hashCode ^
      totalItems.hashCode;
}
