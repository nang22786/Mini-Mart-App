import 'package:dio/dio.dart';
import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/model/category/category_model.dart';
import 'package:mini_mart/services/api_service.dart';

class CategoryRepository {
  final ApiService _apiService;

  CategoryRepository(this._apiService);

  Future<CategoryModel> getCategories() async {
    try {
      print('🔍 Fetching categories from: ${ApiConfig.getCategories}');

      final response = await _apiService.get(ApiConfig.getCategories);

      print('📦 Raw Response: ${response.data}');
      print('📊 Response Type: ${response.data.runtimeType}');

      // Check if response.data is null
      if (response.data == null) {
        print('❌ Response data is null!');
        throw Exception('Server returned null data');
      }

      // Parse the response
      final categoryModel = CategoryModel.fromJson(response.data);
      print('✅ Successfully parsed ${categoryModel.count} categories');

      return categoryModel;
    } catch (e, stackTrace) {
      print('❌ Error loading categories: $e');
      print('📍 Stack trace: $stackTrace');
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<Category> createCategory({
    required String name,
    required String imageFile,
  }) async {
    try {
      print('📤 Creating category: $name');

      FormData formData = FormData.fromMap({
        'name': name,
        'image': await MultipartFile.fromFile(imageFile),
      });

      final response = await _apiService.postFormData(
        ApiConfig.createCategories,
        formData: formData,
      );

      print('✅ Category created: ${response.data}');
      return Category.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error creating category: $e');
      throw Exception('Failed to create category: $e');
    }
  }

  Future<Category> updateCategory({
    required int id,
    required String name,
    String? imageFile,
  }) async {
    try {
      print('📝 Updating category $id: $name');

      Map<String, dynamic> formDataMap = {'name': name};

      // Only add image if a new one is selected
      if (imageFile != null) {
        print('🖼️ New image provided');
        formDataMap['image'] = await MultipartFile.fromFile(imageFile);
      }

      FormData formData = FormData.fromMap(formDataMap);

      final response = await _apiService.putFormData(
        '${ApiConfig.updateCategories}/$id',
        formData: formData,
      );

      print('✅ Category updated: ${response.data}');
      return Category.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error updating category: $e');
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      print('🗑️ Deleting category: $id');

      await _apiService.delete('${ApiConfig.deleteCategories}/$id');

      print('✅ Category deleted: $id');
    } catch (e) {
      print('❌ Error deleting category: $e');
      throw Exception('Failed to delete category: $e');
    }
  }
}
