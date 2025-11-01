import 'package:mini_mart/config/api_config.dart';

class ImageUrlHelper {
  /// Converts relative image paths to full URLs using ApiConfig.baseUrl
  /// Handles multiple path formats from the API
  static String getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }

    // If it's already a full URL (starts with http:// or https://), return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    String path = imageUrl;
    if (path.startsWith('/')) {
      path = path.substring(1); // Remove leading slash
    }

    return '${ApiConfig.baseUrl}/$path';
  }

  /// Gets the full URL for category images
  static String getCategoryImageUrl(String? imageUrl) {
    return getImageUrl(imageUrl);
  }

  /// Gets the full URL for product images
  static String getProductImageUrl(String? imageUrl) {
    return getImageUrl(imageUrl);
  }

  /// Debug helper to print the converted URL
  static void debugImageUrl(String? original) {
    print('Original: $original');
    print('Converted: ${getImageUrl(original)}');
    print('---');
  }
}
