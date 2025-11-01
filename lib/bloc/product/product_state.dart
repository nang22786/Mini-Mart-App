import 'package:mini_mart/model/product/product_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final int count;
  final int? selectedCategoryId;

  ProductLoaded({
    required this.products,
    required this.filteredProducts,
    required this.count,
    this.selectedCategoryId,
  });

  ProductLoaded copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    int? count,
    int? selectedCategoryId,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      count: count ?? this.count,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}

class ProductError extends ProductState {
  final String message;
  ProductError({required this.message});
}

class ProductOperationSuccess extends ProductState {
  final String message;
  ProductOperationSuccess({required this.message});
}
