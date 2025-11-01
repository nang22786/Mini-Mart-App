abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {}

class RefreshCategories extends CategoryEvent {}

class SelectCategory extends CategoryEvent {
  final int categoryId;
  SelectCategory(this.categoryId);
}

class CreateCategoryEvent extends CategoryEvent {
  final String name;
  final String imagePath;

  CreateCategoryEvent({required this.name, required this.imagePath});
}

class UpdateCategoryEvent extends CategoryEvent {
  final int id;
  final String name;
  final String? imagePath;

  UpdateCategoryEvent({required this.id, required this.name, this.imagePath});
}

class DeleteCategoryEvent extends CategoryEvent {
  final int id;

  DeleteCategoryEvent(this.id);
}
