import 'package:mini_mart/config/api_config.dart';
import 'package:mini_mart/model/address/address_model.dart';
import 'package:mini_mart/services/api_service.dart';

class AddressRepository {
  final ApiService _apiService;

  AddressRepository(this._apiService);

  // Get all addresses (for owner)
  Future<List<AddressModel>> getAllAddresses() async {
    try {
      final response = await _apiService.get(ApiConfig.getListAddresses);

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AddressModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load addresses');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Get addresses by user ID
  Future<List<AddressModel>> getAddressesByUserId(int userId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.getListAddressesByUser}/$userId',
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AddressModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load addresses');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Get address detail by ID
  Future<AddressModel> getAddressById(int id) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.getAddressesDetail}/$id',
      );

      if (response.data['success'] == true) {
        return AddressModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load address');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Create address
  Future<AddressModel> createAddress(AddressModel address) async {
    try {
      final response = await _apiService.post(
        ApiConfig.addAddress,
        data: address.toJson(),
      );

      if (response.data['success'] == true) {
        return AddressModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create address');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Update address
  Future<AddressModel> updateAddress(int id, AddressModel address) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.updateAddress}/$id',
        data: address.toJson(),
      );

      if (response.data['success'] == true) {
        return AddressModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update address');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Delete address
  Future<void> deleteAddress(int id) async {
    try {
      final response = await _apiService.delete(
        '${ApiConfig.deleteAddress}/$id',
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete address');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
