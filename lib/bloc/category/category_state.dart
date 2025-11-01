import 'package:mini_mart/model/category/category_model.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  final int count;
  final int? selectedCategoryId;

  CategoryLoaded({
    required this.categories,
    required this.count,
    this.selectedCategoryId,
  });

  CategoryLoaded copyWith({
    List<Category>? categories,
    int? count,
    int? selectedCategoryId,
  }) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
      count: count ?? this.count,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError({required this.message});
}

class CategoryOperationSuccess extends CategoryState {
  final String message;
  CategoryOperationSuccess({required this.message});
}
