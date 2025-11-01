import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/bloc/category/category_event.dart';
import 'package:mini_mart/bloc/category/category_state.dart';
import 'package:mini_mart/repositories/category/category_repository.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repository;

  CategoryBloc(this._repository) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<RefreshCategories>(_onRefreshCategories);
    on<SelectCategory>(_onSelectCategory);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final response = await _repository.getCategories();
      emit(
        CategoryLoaded(
          categories: response.data,
          count: response.count,
          selectedCategoryId: null,
        ),
      );
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onRefreshCategories(
    RefreshCategories event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final response = await _repository.getCategories();
      final currentState = state;
      emit(
        CategoryLoaded(
          categories: response.data,
          count: response.count,
          selectedCategoryId: currentState is CategoryLoaded
              ? currentState.selectedCategoryId
              : null,
        ),
      );
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  void _onSelectCategory(SelectCategory event, Emitter<CategoryState> emit) {
    final currentState = state;
    if (currentState is CategoryLoaded) {
      final selectedId = event.categoryId == 0 ? null : event.categoryId;
      emit(currentState.copyWith(selectedCategoryId: selectedId));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repository.createCategory(
        name: event.name,
        imageFile: event.imagePath,
      );
      emit(CategoryOperationSuccess(message: 'Category created successfully'));
      add(RefreshCategories());
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repository.updateCategory(
        id: event.id,
        name: event.name,
        imageFile: event.imagePath,
      );
      emit(CategoryOperationSuccess(message: 'Category updated successfully'));
      add(RefreshCategories());
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repository.deleteCategory(event.id);
      emit(CategoryOperationSuccess(message: 'Category deleted successfully'));
      add(RefreshCategories());
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }
}
