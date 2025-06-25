import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/data/models/order/cart_item_model.dart';

/// ✅ CartLocalDataSource yang sesuai dengan backend DelPick
class CartLocalDataSource {
  final StorageService _storageService;

  CartLocalDataSource(this._storageService);

  /// Save cart items to local storage
  Future<void> saveCartItems(List<CartItemModel> items) async {
    final cartData = items.map((item) => item.toJson()).toList();
    await _storageService.writeJsonList(StorageConstants.cartItems, cartData);

    // Update cart metadata
    await _storageService.writeDateTime(
        StorageConstants.cartUpdatedAt, DateTime.now());
  }

  /// Get all cart items from local storage
  Future<List<CartItemModel>> getCartItems() async {
    final cartData = _storageService.readJsonList(StorageConstants.cartItems);
    if (cartData != null && cartData.isNotEmpty) {
      return cartData.map((item) => CartItemModel.fromJson(item)).toList();
    }
    return [];
  }

  /// Add item to cart (merge if same menu item exists)
  Future<void> addCartItem(CartItemModel item) async {
    final items = await getCartItems();
    final existingIndex =
        items.indexWhere((i) => i.menuItemId == item.menuItemId);

    if (existingIndex >= 0) {
      // ✅ FIXED: Properly handle the addition of quantities
      final existingItem = items[existingIndex];
      items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + item.quantity,
      );
    } else {
      items.add(item);
    }

    await saveCartItems(items);
  }

  /// Update specific cart item quantity
  Future<void> updateCartItem(int menuItemId, int quantity) async {
    final items = await getCartItems();
    final index = items.indexWhere((item) => item.menuItemId == menuItemId);

    if (index >= 0) {
      if (quantity > 0) {
        items[index] = items[index].copyWith(quantity: quantity);
        await saveCartItems(items);
      } else {
        // Remove item if quantity is 0 or less
        await removeCartItem(menuItemId);
      }
    }
  }

  /// Remove specific item from cart
  Future<void> removeCartItem(int menuItemId) async {
    final items = await getCartItems();
    items.removeWhere((item) => item.menuItemId == menuItemId);
    await saveCartItems(items);
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    await _storageService.removeBatch([
      StorageConstants.cartItems,
      StorageConstants.cartStoreId,
      StorageConstants.cartStoreName,
      StorageConstants.cartTotal,
      StorageConstants.cartUpdatedAt,
      StorageConstants.tempOrderData,
    ]);
  }

  /// Save cart store information
  Future<void> saveCartStore(int storeId, String storeName) async {
    await _storageService.writeInt(StorageConstants.cartStoreId, storeId);
    await _storageService.writeString(
        StorageConstants.cartStoreName, storeName);
  }

  /// Get cart store ID
  Future<int?> getCartStoreId() async {
    return _storageService.readInt(StorageConstants.cartStoreId);
  }

  /// Get cart store name
  Future<String?> getCartStoreName() async {
    return _storageService.readString(StorageConstants.cartStoreName);
  }

  /// Check if cart is empty
  Future<bool> isCartEmpty() async {
    final items = await getCartItems();
    return items.isEmpty;
  }

  /// Get total number of items in cart
  Future<int> getCartItemCount() async {
    final items = await getCartItems();
    return items.fold<int>(
        0, (int sum, CartItemModel item) => sum + item.quantity);
  }

  /// Get total price of all items in cart (excluding delivery fee)
  Future<double> getCartTotal() async {
    final items = await getCartItems();
    return items.fold<double>(
        0.0, (double sum, CartItemModel item) => sum + item.totalPrice);
  }

  /// Calculate delivery fee based on distance (sesuai backend DelPick)
  Future<double> calculateDeliveryFee(double distanceKm) async {
    // Backend: Math.ceil(distance_km * 2000)
    return (distanceKm * 2000).ceilToDouble();
  }

  /// Get cart summary for displaying
  Future<Map<String, dynamic>> getCartSummary() async {
    final items = await getCartItems();
    final itemCount = items.fold<int>(
        0, (int sum, CartItemModel item) => sum + item.quantity);
    final subtotal = items.fold<double>(
        0.0, (double sum, CartItemModel item) => sum + item.totalPrice);

    return {
      'itemCount': itemCount,
      'subtotal': subtotal,
      'formattedSubtotal': _formatCurrency(subtotal),
      'isEmpty': items.isEmpty,
      'storeId': _storageService.readInt(StorageConstants.cartStoreId),
      'storeName': _storageService.readString(StorageConstants.cartStoreName),
      'items': items,
    };
  }

  /// Check if item exists in cart
  Future<bool> hasItem(int menuItemId) async {
    final items = await getCartItems();
    return items.any((item) => item.menuItemId == menuItemId);
  }

  /// Get specific item from cart
  Future<CartItemModel?> getCartItem(int menuItemId) async {
    final items = await getCartItems();
    try {
      return items.firstWhere((item) => item.menuItemId == menuItemId);
    } catch (e) {
      return null;
    }
  }

  /// Increment item quantity
  Future<void> incrementItem(int menuItemId) async {
    final item = await getCartItem(menuItemId);
    if (item != null) {
      await updateCartItem(menuItemId, item.quantity + 1);
    }
  }

  /// Decrement item quantity
  Future<void> decrementItem(int menuItemId) async {
    final item = await getCartItem(menuItemId);
    if (item != null) {
      if (item.quantity > 1) {
        await updateCartItem(menuItemId, item.quantity - 1);
      } else {
        await removeCartItem(menuItemId);
      }
    }
  }

  /// Validate cart before placing order (sesuai business rules DelPick)
  Future<Map<String, dynamic>> validateCart() async {
    final items = await getCartItems();
    final storeId = _storageService.readInt(StorageConstants.cartStoreId);

    List<String> errors = [];

    if (items.isEmpty) {
      errors.add('Keranjang kosong');
    }

    if (storeId == null) {
      errors.add('Toko tidak dipilih');
    }

    // Validate all items belong to same store
    if (storeId != null && items.any((item) => item.storeId != storeId)) {
      errors.add('Semua item harus dari toko yang sama');
    }

    // Validate minimum order (backend tidak ada minimum, tapi bisa ditambahkan di frontend)
    final total = items.fold<double>(
        0.0, (double sum, CartItemModel item) => sum + item.totalPrice);
    if (total < 5000) {
      // Minimum order 5k
      errors.add('Minimum order Rp 5.000');
    }

    // Validate item availability (basic check)
    final unavailableItems = items.where((item) => !item.isAvailable).toList();
    if (unavailableItems.isNotEmpty) {
      errors.add('Beberapa item tidak tersedia');
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'itemCount': items.length,
      'totalQuantity': items.fold<int>(0, (sum, item) => sum + item.quantity),
      'subtotal': total,
      'unavailableItems': unavailableItems.map((item) => item.name).toList(),
    };
  }

  /// Get cart items formatted for API call (sesuai backend DelPick)
  /// Backend expects: { menu_item_id, quantity, notes }
  Future<List<Map<String, dynamic>>> getCartItemsForApi() async {
    final items = await getCartItems();
    return items
        .map((item) => {
              'menu_item_id': item.menuItemId,
              'quantity': item.quantity,
              'notes': item.notes ?? '',
            })
        .toList();
  }

  /// Check if cart needs store validation (different store)
  Future<bool> needsStoreValidation(int newStoreId) async {
    final currentStoreId =
        _storageService.readInt(StorageConstants.cartStoreId);
    final items = await getCartItems();

    return currentStoreId != null &&
        currentStoreId != newStoreId &&
        items.isNotEmpty;
  }

  /// Switch to different store (clear cart if needed)
  Future<void> switchStore(int newStoreId, String newStoreName,
      {bool clearCart = true}) async {
    if (clearCart) {
      await this.clearCart();
    }
    await saveCartStore(newStoreId, newStoreName);
  }

  /// Get cart last updated time
  Future<DateTime?> getCartUpdatedAt() async {
    return _storageService.readDateTime(StorageConstants.cartUpdatedAt);
  }

  /// Check if cart is expired (older than 24 hours)
  Future<bool> isCartExpired() async {
    final updatedAt = await getCartUpdatedAt();
    if (updatedAt == null) return false;

    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    return difference.inHours >= 24;
  }

  /// Clear expired cart automatically
  Future<void> clearExpiredCart() async {
    if (await isCartExpired()) {
      await clearCart();
    }
  }

  /// Prepare order data for API (sesuai format backend DelPick)
  Future<Map<String, dynamic>> prepareOrderData() async {
    final items = await getCartItemsForApi();
    final storeId = _storageService.readInt(StorageConstants.cartStoreId);

    if (storeId == null || items.isEmpty) {
      throw Exception('Cart is not ready for order');
    }

    return {
      'store_id': storeId,
      'items': items,
    };
  }

  /// Save order draft for later (sesuai dengan backend)
  Future<void> saveOrderDraft() async {
    final orderData = await prepareOrderData();
    await _storageService.writeJson(StorageConstants.draftOrderData, {
      ...orderData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get saved order draft
  Future<Map<String, dynamic>?> getOrderDraft() async {
    return _storageService.readJson(StorageConstants.draftOrderData);
  }

  /// Clear order draft
  Future<void> clearOrderDraft() async {
    await _storageService.remove(StorageConstants.draftOrderData);
  }

  /// Save cart to temporary storage (for offline support)
  Future<void> saveCartToTemp() async {
    final cartData = {
      'items': (await getCartItems()).map((item) => item.toJson()).toList(),
      'storeId': _storageService.readInt(StorageConstants.cartStoreId),
      'storeName': _storageService.readString(StorageConstants.cartStoreName),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await _storageService.writeJson(StorageConstants.tempOrderData, cartData);
  }

  /// Restore cart from temporary storage
  Future<void> restoreCartFromTemp() async {
    final tempData = _storageService.readJson(StorageConstants.tempOrderData);
    if (tempData != null) {
      final items = (tempData['items'] as List<dynamic>?)
              ?.map((item) =>
                  CartItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      await saveCartItems(items);

      if (tempData['storeId'] != null && tempData['storeName'] != null) {
        await saveCartStore(
            tempData['storeId'] as int, tempData['storeName'] as String);
      }

      // Clear temp data after restore
      await _storageService.remove(StorageConstants.tempOrderData);
    }
  }

  /// Get cart analytics data
  Future<Map<String, dynamic>> getCartAnalytics() async {
    final items = await getCartItems();
    final updatedAt = await getCartUpdatedAt();

    if (items.isEmpty) {
      return {
        'isEmpty': true,
        'itemCount': 0,
        'totalQuantity': 0,
        'subtotal': 0.0,
      };
    }

    final categories = <String, int>{};
    double maxPrice = 0.0;
    double minPrice = double.infinity;

    for (final item in items) {
      categories[item.category] =
          (categories[item.category] ?? 0) + item.quantity;
      if (item.price > maxPrice) maxPrice = item.price;
      if (item.price < minPrice) minPrice = item.price;
    }

    return {
      'isEmpty': false,
      'itemCount': items.length,
      'totalQuantity': items.fold<int>(0, (sum, item) => sum + item.quantity),
      'subtotal': await getCartTotal(),
      'averagePrice': items.fold<double>(0.0, (sum, item) => sum + item.price) /
          items.length,
      'maxPrice': maxPrice,
      'minPrice': minPrice == double.infinity ? 0.0 : minPrice,
      'categories': categories,
      'lastUpdated': updatedAt?.toIso8601String(),
      'isExpired': await isCartExpired(),
    };
  }

  /// Helper method to format currency
  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Sync cart with server (untuk future enhancement)
  Future<void> syncCartWithServer() async {
    // TODO: Implement cart sync with server
    // Untuk saat ini DelPick tidak memiliki cart server-side
    // Cart hanya disimpan lokal dan langsung dikonversi ke order
  }

  /// Export cart data for backup
  Future<Map<String, dynamic>> exportCartData() async {
    return {
      'items': (await getCartItems()).map((item) => item.toJson()).toList(),
      'storeId': _storageService.readInt(StorageConstants.cartStoreId),
      'storeName': _storageService.readString(StorageConstants.cartStoreName),
      'updatedAt': (await getCartUpdatedAt())?.toIso8601String(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  /// Import cart data from backup
  Future<void> importCartData(Map<String, dynamic> cartData) async {
    try {
      final items = (cartData['items'] as List<dynamic>?)
              ?.map((item) =>
                  CartItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      await saveCartItems(items);

      if (cartData['storeId'] != null && cartData['storeName'] != null) {
        await saveCartStore(
            cartData['storeId'] as int, cartData['storeName'] as String);
      }
    } catch (e) {
      throw Exception('Failed to import cart data: $e');
    }
  }
}
