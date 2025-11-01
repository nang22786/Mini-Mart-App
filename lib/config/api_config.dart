class ApiConfig {
  // Base URL
  // static const String baseUrl = 'http://10.0.2.2:8080';
  // static const String baseUrl = 'http://localhost:8080';
  // static const String baseUrl = 'http://192.168.1.83:8080';
  static const String baseUrl = 'http://157.10.73.21';

  // Authentication Endpoints
  static const String login = '/api/users/login';
  static const String register = '/api/users/register';
  static const String verifyOtp = '/api/users/verify-otp';
  static const String resendOtp = '/api/users/resend-otp';
  static const String forgotPassword = '/api/users/forgot-password';
  static const String resetPassword = '/api/users/reset-password';

  // User Endpoints
  static const String getUserInfo = '/api/users/info';
  static const String updateUserInfo = '/api/users/info';

  // Category Endpoints
  static const String getCategories = '/api/categories';
  static const String createCategories = '/api/categories';
  static const String updateCategories = '/api/categories';
  static const String deleteCategories = '/api/categories';

  // Product Endpoints
  static const String getProduct = '/api/products';
  static const String createProduct = '/api/products';
  static const String updateProduct = '/api/products';

  // Cart Endpoints
  static const String addCart = '/api/cart/add';
  static const String updateCart = '/api/cart';
  static const String getCartUserID = '/api/cart';
  static const String getCartSummary = '/api/cart';

  // Address Endpoints
  static const String getListAddresses = '/api/addresses';
  static const String getAddressesDetail = '/api/addresses';
  static const String getListAddressesByUser = '/api/addresses/user';
  static const String addAddress = '/api/addresses';
  static const String updateAddress = '/api/addresses';
  static const String deleteAddress = '/api/addresses';

  // ✅ Order Endpoints (UPDATED for KHQR!)
  static const String checkout = '/api/orders/checkout'; // 🆕 NEW!
  static const String myOrders = '/api/orders/my-orders';
  static const String allOrders = '/api/orders/all'; // Owner only
  static String orderById(int orderId) => '/api/orders/$orderId';
  static String updateOrderStatus(int orderId) =>
      '/api/orders/$orderId'; // Owner only
  static String deleteOrder(int orderId) =>
      '/api/orders/$orderId'; // Owner only
  static String reCheckOut(int orderId) => '/api/orders/$orderId/retry-payment';

  // ✅ Advertising Endpoints
  static const String createAdvertising = '/api/advertising';
  static String updateAdvertising(int id) => '/api/advertising/$id';
  static const String getAllAdvertising = '/api/advertising';
  static String getAdvertisingById(int id) => '/api/advertising/$id';
  static String deleteAdvertising(int id) => '/api/advertising/$id';

  // ✅ ADD THESE NOTIFICATION ENDPOINTS
  static String markNotificationRead(int orderId) =>
      '/api/orders/$orderId/mark-notification-read';
  static const String markAllFailedRead = '/api/orders/mark-all-failed-read';
  static const String unreadFailedCount = '/api/orders/unread-failed-count';

  // Timeout Configuration
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // Private constructor to prevent instantiation
  ApiConfig._();
}
