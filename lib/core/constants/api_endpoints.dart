// lib/core/constants/api_endpoints.dart
import 'package:del_pick/app/app.dart';

class ApiEndpoints {
  /// Base URLs
  static const String baseUrl = EnvironmentConfig.productionUrl;

  /// Base paths
  /// Base paths
  static const String auth = '/auth';
  static const String users = '/users';
  static const String customers = '/customers';
  static const String drivers = '/drivers';
  static const String stores = '/stores';
  static const String menu = '/menu';
  static const String orders = '/orders';
  static const String driverRequests = '/driver-requests';
  static const String health = '/health';

  /// AUTH ENDPOINTS
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String logout = '$auth/logout';
  static const String profile = '$auth/profile';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';
  static const String verifyEmail = '$auth/verify-email';
  static const String resendVerification = '$auth/resend-verification';

  /// USER ENDPOINTS
  static const String updateProfile = '$users/profile';
  static const String deleteProfile = '$users/profile';
  static const String updateFcmToken = '$users/fcm-token';
  static const String notifications = '$users/notifications';
  static String markNotificationAsRead(int id) =>
      '$users/notifications/$id/read';
  static String deleteNotification(int id) => '$users/notifications/$id';

  /// CUSTOMER ENDPOINTS (sesuai backend routes/v1/customerRoutes.js)
  static const String getAllCustomers = customers;
  static String getCustomerById(int id) => '$customers/$id';
  static const String createCustomer = customers;
  static String updateCustomer(int id) => '$customers/$id';
  static String deleteCustomer(int id) => '$customers/$id';

  /// STORE ENDPOINTS (sesuai backend routes/v1/storeRoutes.js)
  static const String getAllStores = stores;
  static String getStoreById(int id) => '$stores/$id';
  static const String createStore = stores;
  static String updateStore(int id) => '$stores/$id';
  static String deleteStore(int id) => '$stores/$id';

  /// MENU ENDPOINTS (sesuai backend routes/v1/menuRoutes.js)
  static const String getAllMenuItems = menu;
  static String getMenuItemsByStoreId(int storeId) => '$menu/store/$storeId';
  static String getMenuItemById(int id) => '$menu/$id';
  static const String createMenuItem = menu;
  static String updateMenuItem(int id) => '$menu/$id';
  static String deleteMenuItem(int id) => '$menu/$id';
  static String updateMenuItemStatus(int id) => '$menu/$id/status';

  /// ORDER ENDPOINTS (sesuai backend routes/v1/orderRoutes.js)
  static const String createOrder = orders;
  static const String customerOrders = '$orders/customer';
  static const String storeOrders = '$orders/store';
  static String getOrderById(int orderId) => '$orders/$orderId';
  static String updateOrderStatus(int orderId) => '$orders/$orderId/status';
  static String processOrder(int orderId) => '$orders/$orderId/process';
  static String createOrderReview(int orderId) => '$orders/$orderId/review';

  /// TRACKING ENDPOINTS (sesuai backend routes/v1/orderRoutes.js)
  static String getOrderTracking(int orderId) => '$orders/$orderId/tracking';
  static String startDelivery(int orderId) => '$orders/$orderId/tracking/start';
  static String completeDelivery(int orderId) =>
      '$orders/$orderId/tracking/complete';
  static String updateTrackingDriverLocation(int orderId) =>
      '$orders/$orderId/tracking/location';
  static String getTrackingHistory(int orderId) =>
      '$orders/$orderId/tracking/history';

  /// DRIVER ENDPOINTS (sesuai backend routes/v1/driverRoutes.js)
  static const String getAllDrivers = drivers;
  static String getDriverById(int driverId) => '$drivers/$driverId';
  static const String createDriver = drivers;
  static String updateDriverbyAdmin(int driverId) => '$drivers/$driverId';
  static String deleteDriver(int driverId) => '$drivers/$driverId';
  static String updateDriverStatus(int driverId) => '$drivers/$driverId/status';
  static String updateDriverLocation(int driverId) =>
      '$drivers/$driverId/location';

  /// DRIVER REQUEST ENDPOINTS (sesuai backend routes/v1/driverRequestRoutes.js)
  static const String getDriverRequests = driverRequests;
  static String getDriverRequestById(int requestId) =>
      '$driverRequests/$requestId';
  static String respondToDriverRequest(int requestId) =>
      '$driverRequests/$requestId/respond';

  /// HEALTH CHECK ENDPOINTS (sesuai backend routes/v1/healthRoutes.js)
  static const String healthCheck = health;
  static const String healthDatabase = '$health/db';
  static const String healthCache = '$health/cache';
  static const String healthStorage = '$health/storage';

  static String getFullImageUrl(String relativePath) {
    if (relativePath.startsWith('http')) {
      return relativePath; // Already full URL
    }
    return '$baseUrl$relativePath';
  }

  static String getUserAvatarUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return getDefaultAvatarUrl();
    }
    return getFullImageUrl(avatarPath);
  }

  static String getDefaultAvatarUrl() {
    return '$baseUrl/images/default-avatar.png';
  }

  /// HELPER METHODS DENGAN QUERY PARAMETERS
  /// Get stores with filters
  static String getStoresWithFilters({
    double? latitude,
    double? longitude,
    double? radius,
    String? category,
    bool? isOpen,
    int? page,
    int? limit,
  }) {
    final params = <String, dynamic>{};
    if (latitude != null) params['latitude'] = latitude;
    if (longitude != null) params['longitude'] = longitude;
    if (radius != null) params['radius'] = radius;
    if (category != null) params['category'] = category;
    if (isOpen != null) params['is_open'] = isOpen;
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;

    return _buildUrlWithParams(stores, params);
  }

  /// Get orders with filters
  static String getOrdersWithFilters({
    String? status,
    String? customerId,
    String? storeId,
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? limit,
  }) {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (customerId != null) params['customer_id'] = customerId;
    if (storeId != null) params['store_id'] = storeId;
    if (driverId != null) params['driver_id'] = driverId;
    if (startDate != null) params['start_date'] = startDate.toIso8601String();
    if (endDate != null) params['end_date'] = endDate.toIso8601String();
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;

    return _buildUrlWithParams(orders, params);
  }

  /// Get menu items with filters
  static String getMenuItemsWithFilters({
    int? storeId,
    String? category,
    bool? isAvailable,
    double? minPrice,
    double? maxPrice,
    String? search,
    int? page,
    int? limit,
  }) {
    final queryParams = <String>[];

    if (storeId != null) queryParams.add('storeId=$storeId');
    if (category != null && category.isNotEmpty)
      queryParams.add('category=$category');
    if (isAvailable != null) queryParams.add('isAvailable=$isAvailable');
    if (minPrice != null) queryParams.add('minPrice=$minPrice');
    if (maxPrice != null) queryParams.add('maxPrice=$maxPrice');
    if (search != null && search.isNotEmpty) queryParams.add('search=$search');
    if (page != null) queryParams.add('page=$page');
    if (limit != null) queryParams.add('limit=$limit');

    if (queryParams.isEmpty) {
      return getAllMenuItems;
    }

    return '$getAllMenuItems?${queryParams.join('&')}';
  }
  //
  // static String getMenuItemsWithFilters({
  //   int? storeId,
  //   String? category,
  //   bool? isAvailable,
  //   double? minPrice,
  //   double? maxPrice,
  //   String? search,
  //   int? page,
  //   int? limit,
  // }) {
  //   final params = <String, dynamic>{};
  //   if (storeId != null) params['store_id'] = storeId;
  //   if (category != null) params['category'] = category;
  //   if (isAvailable != null) params['is_available'] = isAvailable;
  //   if (minPrice != null) params['min_price'] = minPrice;
  //   if (maxPrice != null) params['max_price'] = maxPrice;
  //   if (search != null) params['search'] = search;
  //   if (page != null) params['page'] = page;
  //   if (limit != null) params['limit'] = limit;
  //
  //   return _buildUrlWithParams(menu, params);
  // }

  /// Add pagination to endpoint
  static String addPagination(String endpoint, {int? page, int? limit}) {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;

    return _buildUrlWithParams(endpoint, params);
  }

  /// Build URL with query parameters
  static String _buildUrlWithParams(
      String endpoint, Map<String, dynamic> params) {
    if (params.isEmpty) return endpoint;

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final separator = endpoint.contains('?') ? '&' : '?';
    return '$endpoint$separator$queryString';
  }

  /// Get full URL
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Get full URL with parameters
  static String getFullUrlWithParams(
      String endpoint, Map<String, dynamic> params) {
    return getFullUrl(_buildUrlWithParams(endpoint, params));
  }

  static String buildQueryString(Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return '';

    final query = params.entries
        .where((entry) => entry.value != null)
        .map((entry) =>
            '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');

    return query.isNotEmpty ? '?$query' : '';
  }

  /// Build endpoint with query parameters
  static String withParams(String endpoint, Map<String, dynamic>? params) {
    return endpoint + buildQueryString(params);
  }
}
