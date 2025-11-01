abstract class ProductEvent {}

class LoadProducts extends ProductEvent {}

class RefreshProducts extends ProductEvent {}

class FilterProductsByCategory extends ProductEvent {
  final int? categoryId;
  FilterProductsByCategory(this.categoryId);
}

class SearchProducts extends ProductEvent {
  final String keyword;
  SearchProducts(this.keyword);
}

class CreateProduct extends ProductEvent {
  final String name;
  final String detail;
  final double price;
  final int stock;
  final String? image;
  final int categoryId;

  CreateProduct({
    required this.name,
    required this.detail,
    required this.price,
    required this.stock,
    this.image,
    required this.categoryId,
  });
}

class UpdateProduct extends ProductEvent {
  final int id;
  final String name;
  final String detail;
  final double price;
  final int stock;
  final String? image;
  final int categoryId;

  UpdateProduct({
    required this.id,
    required this.name,
    required this.detail,
    required this.price,
    required this.stock,
    this.image,
    required this.categoryId,
  });
}

class DeleteProduct extends ProductEvent {
  final int id;
  DeleteProduct(this.id);
}
