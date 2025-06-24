// lib/app/config/database_config.dart - SESUAI BACKEND MIGRATIONS
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseConfig {
  static const String _dbName = 'delpick.db';
  static const int _dbVersion = 1;

  // Table names - SESUAI BACKEND MIGRATIONS
  static const String userTable = 'users';
  static const String storesTable = 'stores';
  static const String driversTable = 'drivers';
  static const String menuItemsTable = 'menu_items';
  static const String ordersTable = 'orders';
  static const String orderItemsTable = 'order_items';
  static const String driverRequestsTable = 'driver_requests';
  static const String driverReviewsTable = 'driver_reviews';
  static const String orderReviewsTable = 'order_reviews';

  // Additional local tables
  static const String cartTable = 'cart_items';
  static const String favoritesTable = 'favorites';
  static const String notificationsTable = 'notifications';

  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // Users table - SESUAI BACKEND MIGRATION create-user.js + fcm_token + avatar
    await db.execute('''
      CREATE TABLE $userTable (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'customer',
        phone TEXT,
        fcm_token TEXT,
        avatar TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Stores table - SESUAI BACKEND MIGRATION create-store.js (tanpa opening_hours)
    await db.execute('''
      CREATE TABLE $storesTable (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        description TEXT,
        open_time TEXT,
        close_time TEXT,
        rating REAL,
        total_products INTEGER,
        image_url TEXT,
        phone TEXT NOT NULL,
        review_count INTEGER,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        distance REAL,
        status TEXT DEFAULT 'active',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $userTable (id) ON DELETE CASCADE
      )
    ''');

    // Drivers table - SESUAI BACKEND MIGRATION create-driver.js + latitude/longitude
    await db.execute('''
      CREATE TABLE $driversTable (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL UNIQUE,
        license_number TEXT NOT NULL UNIQUE,
        vehicle_plate TEXT NOT NULL,
        status TEXT DEFAULT 'active',
        rating REAL NOT NULL DEFAULT 5.00,
        reviews_count INTEGER NOT NULL DEFAULT 0,
        latitude REAL,
        longitude REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $userTable (id) ON DELETE CASCADE
      )
    ''');

    // Menu items table - SESUAI BACKEND MIGRATION create-menu-item.js
    await db.execute('''
      CREATE TABLE $menuItemsTable (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT,
        image_url TEXT,
        store_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        is_available INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (store_id) REFERENCES $storesTable (id) ON DELETE CASCADE
      )
    ''');

    // Orders table - SESUAI BACKEND MIGRATION create-order.js + rejected status
    await db.execute('''
      CREATE TABLE $ordersTable (
        id INTEGER PRIMARY KEY,
        customer_id INTEGER NOT NULL,
        store_id INTEGER NOT NULL,
        driver_id INTEGER,
        order_status TEXT DEFAULT 'pending',
        delivery_status TEXT DEFAULT 'pending',
        total_amount REAL NOT NULL,
        delivery_fee REAL NOT NULL DEFAULT 0,
        estimated_pickup_time TEXT,
        actual_pickup_time TEXT,
        estimated_delivery_time TEXT,
        actual_delivery_time TEXT,
        tracking_updates TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES $userTable (id) ON DELETE CASCADE,
        FOREIGN KEY (store_id) REFERENCES $storesTable (id) ON DELETE CASCADE,
        FOREIGN KEY (driver_id) REFERENCES $driversTable (id) ON DELETE SET NULL
      )
    ''');

    // Order items table - SESUAI BACKEND MIGRATION create-order-item.js + menu fields
    await db.execute('''
      CREATE TABLE $orderItemsTable (
        id INTEGER PRIMARY KEY,
        order_id INTEGER NOT NULL,
        menu_item_id INTEGER,
        name TEXT NOT NULL,
        description TEXT,
        image_url TEXT,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        price REAL NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES $ordersTable (id) ON DELETE CASCADE,
        FOREIGN KEY (menu_item_id) REFERENCES $menuItemsTable (id) ON DELETE SET NULL
      )
    ''');

    // Driver requests table - SESUAI BACKEND MIGRATION create-driver-requests.js + expired/cancelled
    await db.execute('''
      CREATE TABLE $driverRequestsTable (
        id INTEGER PRIMARY KEY,
        order_id INTEGER NOT NULL,
        driver_id INTEGER NOT NULL,
        status TEXT DEFAULT 'pending',
        estimated_pickup_time TEXT,
        estimated_delivery_time TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES $ordersTable (id) ON DELETE CASCADE,
        FOREIGN KEY (driver_id) REFERENCES $driversTable (id) ON DELETE CASCADE
      )
    ''');

    // Driver reviews table - SESUAI BACKEND MIGRATION create-driver-reviews.js + order_id + is_auto_generated
    await db.execute('''
      CREATE TABLE $driverReviewsTable (
        id INTEGER PRIMARY KEY,
        order_id INTEGER NOT NULL,
        driver_id INTEGER NOT NULL,
        customer_id INTEGER NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        is_auto_generated INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES $ordersTable (id) ON DELETE CASCADE,
        FOREIGN KEY (driver_id) REFERENCES $driversTable (id) ON DELETE CASCADE,
        FOREIGN KEY (customer_id) REFERENCES $userTable (id) ON DELETE CASCADE
      )
    ''');

    // Order reviews table - SESUAI BACKEND MIGRATION create-order-review.js
    await db.execute('''
      CREATE TABLE $orderReviewsTable (
        id INTEGER PRIMARY KEY,
        order_id INTEGER NOT NULL,
        customer_id INTEGER NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES $ordersTable (id) ON DELETE CASCADE,
        FOREIGN KEY (customer_id) REFERENCES $userTable (id) ON DELETE CASCADE
      )
    ''');

    // Cart items table - LOCAL ONLY (untuk offline cart)
    await db.execute('''
      CREATE TABLE $cartTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        menu_item_id INTEGER NOT NULL,
        store_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        image_url TEXT,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Favorites table - LOCAL ONLY
    await db.execute('''
      CREATE TABLE $favoritesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        store_id INTEGER,
        menu_item_id INTEGER,
        type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Notifications table - LOCAL ONLY (untuk FCM offline storage)
    await db.execute('''
      CREATE TABLE $notificationsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        payload TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Create indexes untuk performance
    await db.execute('CREATE INDEX idx_users_email ON $userTable (email)');
    await db.execute('CREATE INDEX idx_users_role ON $userTable (role)');
    await db
        .execute('CREATE INDEX idx_stores_user_id ON $storesTable (user_id)');
    await db.execute('CREATE INDEX idx_stores_status ON $storesTable (status)');
    await db
        .execute('CREATE INDEX idx_drivers_user_id ON $driversTable (user_id)');
    await db
        .execute('CREATE INDEX idx_drivers_status ON $driversTable (status)');
    await db.execute(
        'CREATE INDEX idx_menu_items_store_id ON $menuItemsTable (store_id)');
    await db.execute(
        'CREATE INDEX idx_menu_items_category ON $menuItemsTable (category)');
    await db.execute(
        'CREATE INDEX idx_menu_items_is_available ON $menuItemsTable (is_available)');
    await db.execute(
        'CREATE INDEX idx_orders_customer_id ON $ordersTable (customer_id)');
    await db
        .execute('CREATE INDEX idx_orders_store_id ON $ordersTable (store_id)');
    await db.execute(
        'CREATE INDEX idx_orders_driver_id ON $ordersTable (driver_id)');
    await db.execute(
        'CREATE INDEX idx_orders_order_status ON $ordersTable (order_status)');
    await db.execute(
        'CREATE INDEX idx_orders_delivery_status ON $ordersTable (delivery_status)');
    await db.execute(
        'CREATE INDEX idx_order_items_order_id ON $orderItemsTable (order_id)');
    await db.execute(
        'CREATE INDEX idx_order_items_menu_item_id ON $orderItemsTable (menu_item_id)');
    await db.execute(
        'CREATE INDEX idx_driver_requests_order_id ON $driverRequestsTable (order_id)');
    await db.execute(
        'CREATE INDEX idx_driver_requests_driver_id ON $driverRequestsTable (driver_id)');
    await db.execute(
        'CREATE INDEX idx_driver_requests_status ON $driverRequestsTable (status)');
    await db.execute(
        'CREATE INDEX idx_driver_reviews_order_id ON $driverReviewsTable (order_id)');
    await db.execute(
        'CREATE INDEX idx_driver_reviews_driver_id ON $driverReviewsTable (driver_id)');
    await db.execute(
        'CREATE INDEX idx_driver_reviews_customer_id ON $driverReviewsTable (customer_id)');
    await db.execute(
        'CREATE INDEX idx_driver_reviews_rating ON $driverReviewsTable (rating)');
    await db.execute(
        'CREATE INDEX idx_order_reviews_order_id ON $orderReviewsTable (order_id)');
    await db.execute(
        'CREATE INDEX idx_order_reviews_customer_id ON $orderReviewsTable (customer_id)');
    await db.execute(
        'CREATE INDEX idx_order_reviews_rating ON $orderReviewsTable (rating)');
  }

  static Future<void> clearDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    await deleteDatabase(path);
    _database = null;
  }

  // Helper methods untuk ENUM values sesuai backend
  static const List<String> userRoles = [
    'customer',
    'driver',
    'admin',
    'store'
  ];

  static const List<String> driverStatuses = ['active', 'inactive', 'busy'];

  static const List<String> storeStatuses = ['active', 'inactive', 'closed'];

  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'preparing',
    'ready_for_pickup',
    'on_delivery',
    'delivered',
    'cancelled',
    'rejected'
  ];

  static const List<String> deliveryStatuses = [
    'pending',
    'picked_up',
    'on_way',
    'delivered',
    'rejected'
  ];

  static const List<String> driverRequestStatuses = [
    'pending',
    'accepted',
    'rejected',
    'completed',
    'expired',
    'cancelled'
  ];
}
