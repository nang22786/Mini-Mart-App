import 'package:dio/dio.dart';
import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/model/advertising/advertising_model.dart';
import 'package:mini_mart/services/api_service.dart';

class AdvertisingRepository {
  final ApiService _apiService;

  AdvertisingRepository(this._apiService);

  // Get all advertising
  Future<List<AdvertisingModel>> getAllAdvertising() async {
    try {
      final response = await _apiService.get(ApiConfig.getAllAdvertising);

      // Handle wrapped response format: {"data": [...], "success": true}
      if (response.data is Map && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((json) => AdvertisingModel.fromJson(json))
            .toList();
      }

      // Handle direct array format: [...]
      if (response.data is List) {
        return (response.data as List)
            .map((json) => AdvertisingModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load advertising: $e');
    }
  }

  // Get advertising by ID
  Future<AdvertisingModel> getAdvertisingById(int id) async {
    try {
      final response = await _apiService.get(ApiConfig.getAdvertisingById(id));
      return AdvertisingModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load advertising: $e');
    }
  }

  // Create advertising with image
  Future<AdvertisingModel> createAdvertising({
    required String imagePath,
    bool isActive = true,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
        'isActive': isActive,
      });

      final response = await _apiService.postFormData(
        ApiConfig.createAdvertising,
        formData: formData,
      );

      return AdvertisingModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create advertising: $e');
    }
  }

  // Update advertising with image
  Future<AdvertisingModel> updateAdvertising({
    required int id,
    required String imagePath,
    bool? isActive,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
        if (isActive != null) 'isActive': isActive,
      });

      final response = await _apiService.putFormData(
        ApiConfig.updateAdvertising(id),
        formData: formData,
      );

      return AdvertisingModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update advertising: $e');
    }
  }

  // Update only isActive status (without image)
  Future<AdvertisingModel> toggleActiveStatus({
    required int id,
    required bool isActive,
  }) async {
    try {
      final response = await _apiService.patch(
        '/api/advertising/$id/status',
        queryParameters: {'isActive': isActive},
      );

      return AdvertisingModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to toggle active status: $e');
    }
  }

  // Delete advertising
  Future<void> deleteAdvertising(int id) async {
    try {
      await _apiService.delete(ApiConfig.deleteAdvertising(id));
    } catch (e) {
      throw Exception('Failed to delete advertising: $e');
    }
  }
}
