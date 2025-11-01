import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/repositories/product/product_repository.dart';
import 'package:mini_mart/bloc/product/product_event.dart';
import 'package:mini_mart/bloc/product/product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repository;

  ProductBloc(this._repository) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<RefreshProducts>(_onRefreshProducts);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
    on<SearchProducts>(_onSearchProducts);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final response = await _repository.getProducts();
      emit(
        ProductLoaded(
          products: response.data,
          filteredProducts: response.data,
          count: response.count,
          selectedCategoryId: null,
        ),
      );
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final response = await _repository.getProducts();
      final currentState = state;

      if (currentState is ProductLoaded) {
        final filteredProducts = currentState.selectedCategoryId == null
            ? response.data
            : response.data
                  .where(
                    (p) => p.category?.id == currentState.selectedCategoryId,
                  )
                  .toList();

        emit(
          ProductLoaded(
            products: response.data,
            filteredProducts: filteredProducts,
            count: response.count,
            selectedCategoryId: currentState.selectedCategoryId,
          ),
        );
      } else {
        emit(
          ProductLoaded(
            products: response.data,
            filteredProducts: response.data,
            count: response.count,
            selectedCategoryId: null,
          ),
        );
      }
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  void _onFilterProductsByCategory(
    FilterProductsByCategory event,
    Emitter<ProductState> emit,
  ) {
    final currentState = state;
    if (currentState is ProductLoaded) {
      final filteredProducts = event.categoryId == null
          ? currentState.products
          : currentState.products
                .where((product) => product.category?.id == event.categoryId)
                .toList();

      emit(
        currentState.copyWith(
          filteredProducts: filteredProducts,
          selectedCategoryId: event.categoryId,
        ),
      );
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final response = await _repository.searchProducts(event.keyword);
      emit(
        ProductLoaded(
          products: response.data,
          filteredProducts: response.data,
          count: response.count,
          selectedCategoryId: null,
        ),
      );
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _repository.createProduct(
        name: event.name,
        detail: event.detail,
        price: event.price,
        stock: event.stock,
        imagePath: event.image,
        categoryId: event.categoryId,
      );
      emit(ProductOperationSuccess(message: 'Product created successfully'));
      add(RefreshProducts());
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _repository.updateProduct(
        id: event.id,
        name: event.name,
        detail: event.detail,
        price: event.price,
        stock: event.stock,
        imagePath: event.image,
        categoryId: event.categoryId,
      );
      emit(ProductOperationSuccess(message: 'Product updated successfully'));
      add(RefreshProducts());
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _repository.deleteProduct(event.id);
      emit(ProductOperationSuccess(message: 'Product deleted successfully'));
      add(RefreshProducts());
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }
}
