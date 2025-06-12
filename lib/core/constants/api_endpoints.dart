// lib/core/constants/api_endpoints.dart - ENHANCED VERSION
class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'https://delpick.horas-code.my.id/api/v1';

  // Base paths
  static const String auth = '/auth';
  static const String customers = '/customers';
  static const String drivers = '/drivers';
  static const String stores = '/stores';
  static const String menuItems = '/menu';
  static const String orders = '/orders';
  static const String driverRequests = '/driver-requests';
  static const String tracking = '/tracking';

  // Auth endpoints
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String logout = '$auth/logout';
  static const String profile = '$auth/profile';
  static const String updateProfile = '$auth/update-profile';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';

  // ✅ ADDED: Customer endpoints (berdasarkan backend Anda)
  static const String getAllCustomers = customers;
  static String getCustomerById(int id) => '$customers/$id';
  static const String createCustomer = customers;
  static String updateCustomer(int id) => '$customers/$id';
  static String deleteCustomer(int id) => '$customers/$id';

  // Store endpoints
  static const String getAllStores = stores;
  static String getStoreById(int id) => '$stores/$id';
  static const String createStore = stores;
  static String updateStore(int id) => '$stores/$id';
  static String deleteStore(int id) => '$stores/$id';
  static const String updateStoreProfile = '$stores/update';
  static String updateStoreStatus(int id) => '$stores/$id/status';

  // Menu item endpoints
  static const String getAllMenuItems = menuItems;
  static String getMenuItemsByStoreId(int storeId) =>
      '$menuItems/store/$storeId';
  static String getMenuItemById(int id) => '$menuItems/$id';
  static const String createMenuItem = menuItems;
  static String updateMenuItem(int id) => '$menuItems/$id';
  static String deleteMenuItem(int id) => '$menuItems/$id';

  // Order endpoints
  static const String createOrder = orders;
  static const String userOrders = '$orders/user';
  static const String storeOrders = '$orders/store';
  static String getOrderById(int id) => '$orders/$id';
  static String processOrder(int id) => '$orders/$id/process';
  static String cancelOrder(int id) => '$orders/$id/cancel';
  static const String createReview = '$orders/review';
  static const String updateOrderStatus = '$orders/status';

  // Driver endpoints
  static const String getAllDrivers = drivers;
  static String getDriverById(int id) => '$drivers/$id';
  static const String createDriver = drivers;
  static String updateDriver(int id) => '$drivers/$id';
  static String deleteDriver(int id) => '$drivers/$id';
  static const String updateDriverLocation = '$drivers/location';
  static String getDriverLocation(int driverId) =>
      '$drivers/$driverId/location';
  static const String updateDriverStatus = '$drivers/status';
  static const String updateDriverProfile = '$drivers/update';
  static const String driverOrders = '$drivers/orders';

  // Driver request endpoints
  static const String getDriverRequests = driverRequests;
  static String getDriverRequestById(int id) => '$driverRequests/$id';
  static String respondToDriverRequest(int id) => '$driverRequests/$id/respond';

  // Tracking endpoints
  static String getTrackingData(int orderId) => '$tracking/$orderId';
  static String startDelivery(int orderId) => '$tracking/$orderId/start';
  static String completeDelivery(int orderId) => '$tracking/$orderId/complete';

  // ✅ ADDED: File upload endpoints (jika backend support)
  static const String uploadImage = '/upload/image';
  static const String uploadAvatar = '/upload/avatar';
  static const String uploadStoreImage = '/upload/store';
  static const String uploadMenuImage = '/upload/menu';

  // ✅ ADDED: Search endpoints (useful untuk future features)
  static const String searchStores = '$stores/search';
  static const String searchMenuItems = '$menuItems/search';
  static const String searchOrders = '$orders/search';

  // ✅ ADDED: Statistics endpoints (untuk dashboard/analytics)
  static const String orderStatistics = '$orders/statistics';
  static const String storeStatistics = '$stores/statistics';
  static const String driverStatistics = '$drivers/statistics';
  static const String userStatistics = '$customers/statistics';

  // ✅ ADDED: Notification endpoints (future feature)
  static const String notifications = '/notifications';
  static const String markNotificationRead = '$notifications/read';
  static const String getUnreadCount = '$notifications/unread-count';

  // ✅ ADDED: Location services
  static const String getNearbyStores = '$stores/nearby';
  static const String getDeliveryZones = '/delivery-zones';
  static const String checkDeliveryAvailability = '/delivery/check';

  // ✅ ADDED: Admin endpoints (untuk management)
  static const String adminDashboard = '/admin/dashboard';
  static const String adminReports = '/admin/reports';
  static const String adminSettings = '/admin/settings';

  // ✅ ADDED: Payment endpoints (jika ada integration)
  static const String payments = '/payments';
  static const String createPayment = '$payments/create';
  static const String verifyPayment = '$payments/verify';
  static const String paymentHistory = '$payments/history';

  // ✅ ADDED: Promotion/Coupon endpoints (future feature)
  static const String promotions = '/promotions';
  static const String coupons = '/coupons';
  static const String applyCoupon = '$coupons/apply';
  static const String validateCoupon = '$coupons/validate';

  // ✅ ADDED: App configuration endpoints
  static const String appConfig = '/config';
  static const String appVersion = '/version';
  static const String maintenanceMode = '/maintenance';

  // ✅ ADDED: Helper methods dengan query parameters
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

    final queryString =
        params.entries.map((e) => '${e.key}=${e.value}').join('&');

    return queryString.isEmpty ? stores : '$stores?$queryString';
  }

  static String getOrdersWithFilters({
    String? status,
    String? userId,
    String? storeId,
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? limit,
  }) {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (userId != null) params['userId'] = userId;
    if (storeId != null) params['storeId'] = storeId;
    if (driverId != null) params['driverId'] = driverId;
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;

    final queryString =
        params.entries.map((e) => '${e.key}=${e.value}').join('&');

    return queryString.isEmpty ? orders : '$orders?$queryString';
  }

  // ✅ ADDED: Pagination helper
  static String addPagination(String endpoint, {int? page, int? limit}) {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;

    if (params.isEmpty) return endpoint;

    final queryString =
        params.entries.map((e) => '${e.key}=${e.value}').join('&');

    final separator = endpoint.contains('?') ? '&' : '?';
    return '$endpoint$separator$queryString';
  }

  // ✅ ADDED: API versioning support
  static String v1(String endpoint) => '/api/v1$endpoint';
  static String v2(String endpoint) => '/api/v2$endpoint';

  // Review endpoints (existing)
  static const String reviews = '/reviews';
  static String getStoreReviews(int storeId) => '$reviews/store/$storeId';
  static String getDriverReviews(int driverId) => '$reviews/driver/$driverId';
  static String getUserReviews(int userId) => '$reviews/user/$userId';
}
