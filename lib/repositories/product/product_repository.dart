import 'package:dio/dio.dart';
import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/services/api_service.dart';
import 'package:mini_mart/model/product/product_model.dart';

class ProductRepository {
  final ApiService _apiService;

  ProductRepository(this._apiService);

  Future<ProductResponse> getProducts() async {
    try {
      print('🔍 Fetching products from: ${ApiConfig.createProduct}');

      final response = await _apiService.get(ApiConfig.createProduct);

      print('📦 Raw Response Type: ${response.data.runtimeType}');
      print('📦 Response Keys: ${response.data?.keys}');

      if (response.data == null) {
        print('❌ Response data is null!');
        throw Exception('Server returned null data');
      }

      // Check if response is wrapped in 'data' key or is direct array
      final jsonData = response.data is Map && response.data.containsKey('data')
          ? response.data
          : {
              'data': response.data,
              'success': true,
              'count': (response.data as List?)?.length ?? 0,
            };

      print('📊 Data Length: ${(jsonData['data'] as List?)?.length ?? 0}');

      final productResponse = ProductResponse.fromJson(jsonData);
      print('✅ Successfully parsed ${productResponse.count} products');

      return productResponse;
    } catch (e, stackTrace) {
      print('❌ Error loading products: $e');
      print('📍 Stack trace: $stackTrace');
      throw Exception('Failed to load products: $e');
    }
  }

  Future<Product> getProductById(int id) async {
    try {
      print('🔍 Fetching product by ID: $id');

      final response = await _apiService.get('${ApiConfig.createProduct}/$id');

      print('📦 Product Response: ${response.data}');

      return Product.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error loading product: $e');
      throw Exception('Failed to load product: $e');
    }
  }

  Future<ProductResponse> searchProducts(String keyword) async {
    try {
      print('🔍 Searching products: $keyword');

      final response = await _apiService.get(
        '${ApiConfig.createProduct}/search',
        queryParameters: {'keyword': keyword},
      );

      print('📦 Search Response: ${response.data}');

      return ProductResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Error searching products: $e');
      throw Exception('Failed to search products: $e');
    }
  }

  // ✅ FIXED: Create product with FormData matching your Postman example
  Future<Product> createProduct({
    required String name,
    required String detail,
    required double price,
    required int stock,
    String? imagePath,
    required int categoryId,
  }) async {
    try {
      print('📤 Creating product: $name');
      print('💰 Price: $price, 📦 Stock: $stock, 🏷️ Category: $categoryId');
      print('📷 Image path: $imagePath');

      // ✅ Build FormData exactly like Postman
      Map<String, dynamic> formDataMap = {
        'name': name,
        'detail': detail,
        'price': price.toString(), // Backend expects string
        'stock': stock.toString(), // Backend expects string
        'category_id': categoryId
            .toString(), // ✅ FIXED: underscore not camelCase!
      };

      // Add image file if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        print('🖼️ Adding image file');
        formDataMap['image'] = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(formDataMap);

      print('📤 Sending FormData with keys: ${formDataMap.keys}');

      final response = await _apiService.postFormData(
        ApiConfig.createProduct,
        formData: formData,
      );

      print('✅ Product created: ${response.data}');
      return Product.fromJson(response.data['data']);
    } catch (e, stackTrace) {
      print('❌ Error creating product: $e');
      print('📍 Stack trace: $stackTrace');
      throw Exception('Failed to create product: $e');
    }
  }

  // ✅ FIXED: Update product with FormData matching your backend
  Future<Product> updateProduct({
    required int id,
    required String name,
    required String detail,
    required double price,
    required int stock,
    String? imagePath,
    required int categoryId,
  }) async {
    try {
      print('📝 Updating product $id: $name');
      print('💰 Price: $price, 📦 Stock: $stock, 🏷️ Category: $categoryId');
      print('📷 Image path: $imagePath');

      // ✅ Build FormData exactly like Postman
      Map<String, dynamic> formDataMap = {
        'name': name,
        'detail': detail,
        'price': price.toString(),
        'stock': stock.toString(),
        'category_id': categoryId.toString(), // ✅ FIXED: underscore!
      };

      // Add image file if provided (optional for update)
      if (imagePath != null && imagePath.isNotEmpty) {
        print('🖼️ Adding new image file');
        formDataMap['image'] = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(formDataMap);

      print('📤 Sending FormData with keys: ${formDataMap.keys}');

      final response = await _apiService.putFormData(
        '${ApiConfig.updateProduct}/$id',
        formData: formData,
      );

      print('✅ Product updated: ${response.data}');
      return Product.fromJson(response.data['data']);
    } catch (e, stackTrace) {
      print('❌ Error updating product: $e');
      print('📍 Stack trace: $stackTrace');
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      print('🗑️ Deleting product: $id');

      await _apiService.delete('${ApiConfig.updateProduct}/$id');

      print('✅ Product deleted: $id');
    } catch (e) {
      print('❌ Error deleting product: $e');
      throw Exception('Failed to delete product: $e');
    }
  }
}
