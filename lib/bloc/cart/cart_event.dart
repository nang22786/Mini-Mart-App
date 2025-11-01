abstract class CartEvent {
  const CartEvent();
}

class LoadCart extends CartEvent {
  const LoadCart();

  @override
  String toString() => 'LoadCart';
}

class AddToCart extends CartEvent {
  final int productId;
  final int qty;

  const AddToCart({required this.productId, required this.qty});

  @override
  String toString() => 'AddToCart(productId: $productId, qty: $qty)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddToCart &&
        other.productId == productId &&
        other.qty == qty;
  }

  @override
  int get hashCode => productId.hashCode ^ qty.hashCode;
}

class UpdateCartQuantity extends CartEvent {
  final int cartId;
  final int qty;

  const UpdateCartQuantity({required this.cartId, required this.qty});

  @override
  String toString() => 'UpdateCartQuantity(cartId: $cartId, qty: $qty)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateCartQuantity &&
        other.cartId == cartId &&
        other.qty == qty;
  }

  @override
  int get hashCode => cartId.hashCode ^ qty.hashCode;
}

class RemoveFromCart extends CartEvent {
  final int cartId;

  const RemoveFromCart({required this.cartId});

  @override
  String toString() => 'RemoveFromCart(cartId: $cartId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RemoveFromCart && other.cartId == cartId;
  }

  @override
  int get hashCode => cartId.hashCode;
}

class ClearCart extends CartEvent {
  const ClearCart();

  @override
  String toString() => 'ClearCart';
}

class RefreshCart extends CartEvent {
  const RefreshCart();

  @override
  String toString() => 'RefreshCart';
}
