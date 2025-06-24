import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart' as getx;
import 'package:del_pick/app/config/database_config.dart';

class DatabaseService extends getx.GetxService {
  Database? _database;

  Database? get database => _database;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initDatabase();
  }

  @override
  void onClose() {
    _database?.close();
    super.onClose();
  }

  Future<void> _initDatabase() async {
    _database = await DatabaseConfig.database;
  }

  // -------------------- USER --------------------
  Future<int> insertUser(Map<String, dynamic> user) async {
    return await _database!.insert(DatabaseConfig.userTable, user);
  }

  Future<Map<String, dynamic>?> getUser(int id) async {
    final results = await _database!.query(
      DatabaseConfig.userTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    return await _database!.update(
      DatabaseConfig.userTable,
      user,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    return await _database!.delete(
      DatabaseConfig.userTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -------------------- CART --------------------
  Future<int> insertCartItem(Map<String, dynamic> cartItem) async {
    return await _database!.insert(DatabaseConfig.cartTable, cartItem);
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    return await _database!
        .query(DatabaseConfig.cartTable, orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getCartItemsByStore(int storeId) async {
    return await _database!.query(
      DatabaseConfig.cartTable,
      where: 'store_id = ?',
      whereArgs: [storeId],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> updateCartItem(int id, Map<String, dynamic> cartItem) async {
    return await _database!.update(
      DatabaseConfig.cartTable,
      cartItem,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateCartItemQuantity(int id, int quantity) async {
    return await _database!.update(
      DatabaseConfig.cartTable,
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCartItem(int id) async {
    return await _database!.delete(
      DatabaseConfig.cartTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearCart() async {
    return await _database!.delete(DatabaseConfig.cartTable);
  }

  Future<int> clearCartByStore(int storeId) async {
    return await _database!.delete(
      DatabaseConfig.cartTable,
      where: 'store_id = ?',
      whereArgs: [storeId],
    );
  }

  Future<Map<String, dynamic>?> getCartItemByMenuId(int menuItemId) async {
    final results = await _database!.query(
      DatabaseConfig.cartTable,
      where: 'menu_item_id = ?',
      whereArgs: [menuItemId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<double> getCartTotal() async {
    final result = await _database!.rawQuery(
      'SELECT SUM(price * quantity) as total FROM ${DatabaseConfig.cartTable}',
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> getCartItemCount() async {
    final result = await _database!.rawQuery(
      'SELECT SUM(quantity) as count FROM ${DatabaseConfig.cartTable}',
    );
    return result.first['count'] as int? ?? 0;
  }

  // -------------------- FAVORITES --------------------
  Future<int> insertFavorite(Map<String, dynamic> favorite) async {
    return await _database!.insert(DatabaseConfig.favoritesTable, favorite);
  }

  Future<List<Map<String, dynamic>>> getFavoriteStores() async {
    return await _database!.query(
      DatabaseConfig.favoritesTable,
      where: 'type = ?',
      whereArgs: ['store'],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getFavoriteMenuItems() async {
    return await _database!.query(
      DatabaseConfig.favoritesTable,
      where: 'type = ?',
      whereArgs: ['menu_item'],
      orderBy: 'created_at DESC',
    );
  }

  Future<bool> isFavoriteStore(int storeId) async {
    final results = await _database!.query(
      DatabaseConfig.favoritesTable,
      where: 'store_id = ? AND type = ?',
      whereArgs: [storeId, 'store'],
    );
    return results.isNotEmpty;
  }

  Future<bool> isFavoriteMenuItem(int menuItemId) async {
    final results = await _database!.query(
      DatabaseConfig.favoritesTable,
      where: 'menu_item_id = ? AND type = ?',
      whereArgs: [menuItemId, 'menu_item'],
    );
    return results.isNotEmpty;
  }

  Future<int> removeFavoriteStore(int storeId) async {
    return await _database!.delete(
      DatabaseConfig.favoritesTable,
      where: 'store_id = ? AND type = ?',
      whereArgs: [storeId, 'store'],
    );
  }

  Future<int> removeFavoriteMenuItem(int menuItemId) async {
    return await _database!.delete(
      DatabaseConfig.favoritesTable,
      where: 'menu_item_id = ? AND type = ?',
      whereArgs: [menuItemId, 'menu_item'],
    );
  }

  // -------------------- ORDERS --------------------
  Future<int> insertOrder(Map<String, dynamic> order) async {
    return await _database!.insert(DatabaseConfig.ordersTable, order);
  }

  Future<List<Map<String, dynamic>>> getOfflineOrders() async {
    return await _database!.query(
      DatabaseConfig.ordersTable,
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    return await _database!.query(
      DatabaseConfig.ordersTable,
      orderBy: 'created_at DESC',
    );
  }

  Future<int> markOrderAsSynced(int orderId, int serverId) async {
    return await _database!.update(
      DatabaseConfig.ordersTable,
      {'synced': 1, 'server_id': serverId},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> deleteOrder(int id) async {
    return await _database!.delete(
      DatabaseConfig.ordersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -------------------- NOTIFICATIONS --------------------
  Future<int> insertNotification(Map<String, dynamic> notification) async {
    return await _database!
        .insert(DatabaseConfig.notificationsTable, notification);
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    return await _database!.query(
      DatabaseConfig.notificationsTable,
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    return await _database!.query(
      DatabaseConfig.notificationsTable,
      where: 'is_read = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> markNotificationAsRead(int id) async {
    return await _database!.update(
      DatabaseConfig.notificationsTable,
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markAllNotificationsAsRead() async {
    return await _database!
        .update(DatabaseConfig.notificationsTable, {'is_read': 1});
  }

  Future<int> deleteNotification(int id) async {
    return await _database!.delete(
      DatabaseConfig.notificationsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getUnreadNotificationCount() async {
    final result = await _database!.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConfig.notificationsTable} WHERE is_read = 0',
    );
    return result.first['count'] as int? ?? 0;
  }

  // -------------------- UTILITIES --------------------
  Future<void> clearAllData() async {
    await DatabaseConfig.clearDatabase();
  }

  Future<Map<String, int>> getDatabaseStats() async {
    final cartCount = await _database!.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConfig.cartTable}',
    );
    final favoritesCount = await _database!.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConfig.favoritesTable}',
    );
    final ordersCount = await _database!.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConfig.ordersTable}',
    );
    final notificationsCount = await _database!.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConfig.notificationsTable}',
    );

    return {
      'cartItems': cartCount.first['count'] as int,
      'favorites': favoritesCount.first['count'] as int,
      'orders': ordersCount.first['count'] as int,
      'notifications': notificationsCount.first['count'] as int,
    };
  }
}
