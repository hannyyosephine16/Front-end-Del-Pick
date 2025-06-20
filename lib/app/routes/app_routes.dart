abstract class Routes {
  Routes._();

  // Initial routes
  static const SPLASH = '/splash';
  static const ONBOARDING = '/onboarding';
  static const MAIN_NAVIGATION = '/main_navigation';

  // Auth routes
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot_password';
  static const RESET_PASSWORD = '/reset_password';
  static const PROFILE = '/profile';
  static const EDIT_PROFILE = '/edit_profile';

  // Customer routes
  static const CUSTOMER_HOME = '/customer/home';
  static const STORE_LIST = '/customer/store_list';
  static const STORE_DETAIL = '/customer/store_detail';
  static const MENU = '/customer/menu';
  static const MENU_ITEM_DETAIL = '/customer/menu_item_detail';
  static const CART = '/customer/cart';
  static const CHECKOUT = '/customer/checkout';
  static const ORDER_HISTORY = '/customer/order_history';
  static const CUSTOMER_ORDER_DETAIL = '/customer/order_detail';
  static const ORDER_TRACKING = '/customer/order_tracking';
  static const REVIEW = '/customer/review';
  static const CUSTOMER_PROFILE = '/customer/profile';

  // Driver routes
  static const DRIVER_HOME = '/driver/home';
  static const DRIVER_MAIN = '/driver/main';
  static const DRIVER_REQUESTS = '/driver/requests';
  static const DRIVER_MAP = 'driver/map';
  static const REQUEST_DETAIL = '/driver/request_detail';
  static const DELIVERY = '/driver/delivery';
  static const NAVIGATION = '/driver/navigation';
  static const DRIVER_ORDERS = '/drivers/orders';
  static const DRIVER_EARNINGS = '/driver/earnings';
  static const DRIVER_PROFILE = '/driver/profile';
  static const DRIVER_SETTINGS = '/driver/settings';

  // Store routes
  static const STORE_DASHBOARD = '/store/dashboard';
  static const STORE_ANALYTICS = '/store/analytics';
  static const MENU_MANAGEMENT = '/store/menu_management';
  static const ADD_MENU_ITEM = '/store/add_menu_item';
  static const EDIT_MENU_ITEM = '/store/edit_menu_item';
  static const STORE_ORDERS = '/store/orders';
  static const STORE_ORDER_DETAIL = '/store/order_detail';
  static const STORE_PROFILE = '/store/profile';
  static const STORE_SETTINGS = '/store/settings';

  // Shared routes
  static const NO_INTERNET = '/no_internet';
  static const MAINTENANCE = '/maintenance';
  static const ERROR = '/error';

  // Settings routes
  static const SETTINGS = '/settings';
  static const LANGUAGE_SETTINGS = '/settings/language';
  static const THEME_SETTINGS = '/settings/theme';
  static const NOTIFICATION_SETTINGS = '/settings/notifications';
  static const PRIVACY_POLICY = '/privacy_policy';
  static const TERMS_OF_SERVICE = '/terms_of_service';
  static const ABOUT = '/about';
  static const HELP = '/help';
  static const CONTACT_US = '/contact_us';

  // Address routes
  static const ADDRESS_LIST = '/address/list';
  static const ADD_ADDRESS = '/address/add';
  static const EDIT_ADDRESS = '/address/edit';
  static const SELECT_ADDRESS = '/address/select';

  // Search routes
  static const SEARCH = '/search';
  static const SEARCH_RESULTS = '/search/results';

  // Filter routes
  static const FILTER = '/filter';

  // Map routes
  static const MAP_VIEW = '/map';
  static const LOCATION_PICKER = '/location_picker';

  // Notification routes
  static const NOTIFICATIONS = '/notifications';
  static const NOTIFICATION_DETAIL = '/notification_detail';

  // Chat routes (if implementing chat feature)
  static const CHAT_LIST = '/chat/list';
  static const CHAT_DETAIL = '/chat/detail';

  // Favorites routes
  static const FAVORITES = '/favorites';

  // Coupon routes (if implementing coupon system)
  static const COUPONS = '/coupons';
  static const COUPON_DETAIL = '/coupon_detail';
}
