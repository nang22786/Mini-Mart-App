import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mini_mart/config/storage_service.dart';
import 'package:mini_mart/model/user/auth_response_model.dart';
import 'package:mini_mart/model/user/user_model.dart';
import 'package:mini_mart/services/api_service.dart';
import '../../../config/api_config.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  // Register
  Future<AuthResponseModel> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        data: {'email': email, 'password': password},
      );

      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw e.toString();
    }
  }

  // Verify OTP
  Future<AuthResponseModel> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.verifyOtp,
        data: {'email': email, 'code': code},
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Save to storage if successful
      if (authResponse.success && authResponse.accessToken != null) {
        await StorageService.saveAccessToken(authResponse.accessToken!);
        if (authResponse.user != null) {
          await StorageService.saveUserId(authResponse.user!.id);
          await StorageService.saveUserEmail(authResponse.user!.email);
        }
      }

      return authResponse;
    } catch (e) {
      throw e.toString();
    }
  }

  // Resend OTP
  Future<AuthResponseModel> resendOtp({required String email}) async {
    try {
      final response = await _apiService.post(
        ApiConfig.resendOtp,
        data: {'email': email},
      );

      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw e.toString();
    }
  }

  // Login
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Save to storage if successful
      if (authResponse.success && authResponse.accessToken != null) {
        await StorageService.saveAccessToken(authResponse.accessToken!);
        if (authResponse.user != null) {
          await StorageService.saveUserId(authResponse.user!.id);
          await StorageService.saveUserEmail(authResponse.user!.email);
        }
      }

      return authResponse;
    } catch (e) {
      throw e.toString();
    }
  }

  // Forgot Password
  Future<AuthResponseModel> forgotPassword({required String email}) async {
    try {
      final response = await _apiService.post(
        ApiConfig.forgotPassword,
        data: {'email': email},
      );

      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw e.toString();
    }
  }

  // Reset Password
  Future<AuthResponseModel> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      print('🔐 Resetting password for: $email');
      print('🔑 OTP Code: $code');
      print('📝 New Password Length: ${newPassword.length}');

      final requestData = {
        'email': email,
        'code': code,
        'new_password': newPassword,
      };

      print('📤 Request data: $requestData');

      final response = await _apiService.post(
        ApiConfig.resetPassword,
        data: requestData,
      );

      print('✅ Reset password response: ${response.data}');

      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      print('❌ Reset password error: $e');

      if (e.toString().contains('403')) {
        throw 'Invalid or expired verification code. Please request a new one.';
      } else if (e.toString().contains('400')) {
        throw 'Invalid request. Please check your information.';
      } else if (e.toString().contains('401')) {
        throw 'Unauthorized. Please try again.';
      }

      throw 'Failed to reset password: ${e.toString()}';
    }
  }

  // Get User Info
  Future<UserModel> getUserInfo(int userId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.getUserInfo}/$userId',
      );
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw e.toString();
    }
  }

  // Update User Info with FormData (POST multipart/form-data)
  Future<UserModel> updateUserInfo({
    required int userId,
    String? userName,
    String? phone,
    String? profileImage,
  }) async {
    try {
      print('📝 Updating user info for ID: $userId');
      print('   userName: $userName');
      print('   phone: $phone');
      print('   profileImage: $profileImage');

      // Create FormData
      final formData = FormData();

      // Add text fields
      if (userName != null && userName.isNotEmpty) {
        formData.fields.add(MapEntry('userName', userName));
      }

      if (phone != null && phone.isNotEmpty) {
        formData.fields.add(MapEntry('phone_number', phone));
      }

      // Add image file if exists
      if (profileImage != null && profileImage.isNotEmpty) {
        final file = File(profileImage);
        if (await file.exists()) {
          final fileName = profileImage.split('/').last;
          formData.files.add(
            MapEntry(
              'image',
              await MultipartFile.fromFile(profileImage, filename: fileName),
            ),
          );
          print('📸 Image file added: $fileName');
        } else {
          print('⚠️ Image file does not exist: $profileImage');
        }
      }

      print('📤 Sending FormData to: ${ApiConfig.updateUserInfo}/$userId');

      // Use POST with FormData
      final response = await _apiService.postFormData(
        '${ApiConfig.updateUserInfo}/$userId',
        formData: formData,
      );

      print('✅ Update response: ${response.data}');

      return UserModel.fromJson(response.data);
    } catch (e) {
      print('❌ Update user error: $e');
      throw e.toString();
    }
  }

  // Logout
  Future<void> logout() async {
    await StorageService.clearAll();
  }

  // Check if logged in
  bool isLoggedIn() {
    return StorageService.isLoggedIn();
  }
}
