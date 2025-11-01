import 'package:mini_mart/model/user/user_model.dart';

class AuthResponseModel {
  final bool success;
  final String message;
  final UserModel? user;
  final String? accessToken;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.user,
    this.accessToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing AuthResponseModel from JSON:');
      print('   success: ${json['success']}');
      print('   message: ${json['message']}');
      print('   user: ${json['user']}');
      print('   access_token: ${json['access_token']}');

      return AuthResponseModel(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? 'Unknown error',
        user: json['user'] != null
            ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        accessToken: json['access_token'] as String?,
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing AuthResponseModel: $e');
      print('📋 Stack trace: $stackTrace');
      print('📦 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user?.toJson(),
      'access_token': accessToken,
    };
  }

  @override
  String toString() {
    return 'AuthResponseModel(success: $success, message: $message, user: $user, accessToken: ${accessToken?.substring(0, 20)}...)';
  }
}
