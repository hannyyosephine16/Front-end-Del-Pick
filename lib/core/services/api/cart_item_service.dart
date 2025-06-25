// // File: lib/core/services/cart_service.dart
//
// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:del_pick/data/models/order/cart_item_model.dart';
// import 'package:del_pick/data/models/menu/menu_item_model.dart';
// import 'package:del_pick/core/constants/storage_constants.dart';
// import 'package:del_pick/core/utils/helpers.dart';
//
// /// ✅ Cart Service yang sesuai dengan backend DelPick
// /// Cart hanya ada di frontend, backend langsung terima items saat place order
// class CartService extends GetxService {
//   final GetStorage _storage = GetStorage();
//
//   // Reactive cart items
//   final RxList<CartItemModel> _cartItems = <CartItemModel>[].obs;
//   final RxBool _isLoading = false.obs;
//   final RxString _lastError = ''.obs;
//
//   // Getters
//   List<CartItemModel> get items => _cartItems.toList();
//   RxList<CartItemModel> get reactiveItems => _cartItems;
//   bool get isLoading => _isLoading.value;
//   String get lastError => _lastError.value;
//   bool get isEmpty => _cartItems.isEmpty;
//   bool get isNotEmpty => _cartItems.isNotEmpty;
//   int get itemCount => _cartItems.length;
//   int get totalQuantity => CartItemModel.calculateTotalQuantity(_cartItems);
//   double get totalPrice => CartItemModel.calculateTotal(_cartItems);
//   String get formattedTotalPrice => _formatCurrency(totalPrice);
//
//   // Store validation
//   int? get storeId => CartItemModel.getStoreId(_cartItems);
//   bool get hasConsistentStore => CartItemModel.hasConsistentStore(_cartItems);
//
//   @override
//   void onInit() {
//     super.onInit();
//     _loadCartFromStorage();
//   }
//
//   /// ✅ Load cart from local storage
//   void _loadCartFromStorage() {
//     try {
//       _isLoading.value = true;
//       _lastError.value = '';
//
//       final cartData = _storage.read<String>(StorageConstants.cartItems);
//       if (cartData != null && cartData.isNotEmpty) {
//         final List<dynamic> jsonList = json.decode(cartData);
//         final items = CartItemModel.fromJsonList(jsonList);
//
//         // Validate and filter valid items
//         final validItems = items.where((item) => item.isValid).toList();
//         _cartItems.assignAll(validItems);
//
//         // If some items were invalid, save the cleaned cart
//         if (validItems.length != items.length) {
//           _saveCartToStorage();
//         }
//
//         Helpers.showWarningSnackbar('Log Info',
//             'Cart loaded: ${validItems.length} items', Get.context!);
//       }
//     } catch (e) {
//       _lastError.value = 'Failed to load cart: $e';
//       Helpers.showErrorSnackbar(
//           'Error loading cart from storage', e.toString(), Get.context!);
//       _cartItems.clear();
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   /// ✅ Save cart to local storage
//   void _saveCartToStorage() {
//     try {
//       final jsonString = json.encode(CartItemModel.toJsonList(_cartItems));
//       _storage.write(StorageConstants.cartItems, jsonString);
//       Helpers.logInfo('Cart saved: ${_cartItems.length} items');
//     } catch (e) {
//       _lastError.value = 'Failed to save cart: $e';
//       Helpers.logError('Error saving cart to storage', e);
//     }
//   }
//
//   /// ✅ Add item to cart
//   Future<bool> addItem({
//     required MenuItemModel menuItem,
//     int quantity = 1,
//     String? notes,
//   }) async {
//     try {
//       _isLoading.value = true;
//       _lastError.value = '';
//
//       // Validate menu item
//       if (!menuItem.isValid || !menuItem.isAvailable) {
//         _lastError.value = 'Menu item tidak valid atau tidak tersedia';
//         return false;
//       }
//
//       // Check store consistency
//       if (_cartItems.isNotEmpty && menuItem.storeId != storeId) {
//         _lastError.value = 'Tidak bisa menambah item dari toko yang berbeda';
//         return false;
//       }
//
//       // Check if item already exists
//       final existingItemIndex = _cartItems.indexWhere(
//         (item) => item.menuItemId == menuItem.id,
//       );
//
//       if (existingItemIndex != -1) {
//         // Update existing item quantity
//         final existingItem = _cartItems[existingItemIndex];
//         final newQuantity = existingItem.quantity + quantity;
//
//         if (newQuantity > 99) {
//           _lastError.value = 'Maksimal 99 item per menu';
//           return false;
//         }
//
//         _cartItems[existingItemIndex] = existingItem.copyWith(
//           quantity: newQuantity,
//           notes: notes ?? existingItem.notes,
//           updatedAt: DateTime.now(),
//         );
//       } else {
//         // Add new item
//         final cartItem = CartItemModel.fromMenuItem(
//           menuItem.toJson(),
//           quantity: quantity,
//           notes: notes,
//         );
//         _cartItems.add(cartItem);
//       }
//
//       _saveCartToStorage();
//       Helpers.showSuccessSnackbar('Item ditambahkan ke keranjang');
//       return true;
//     } catch (e) {
//       _lastError.value = 'Failed to add item: $e';
//       Helpers.logError('Error adding item to cart', e);
//       return false;
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   /// ✅ Remove item from cart
//   bool removeItem(int menuItemId) {
//     try {
//       _lastError.value = '';
//
//       final removed = _cartItems.removeWhere(
//         (item) => item.menuItemId == menuItemId,
//       );
//
//       if (removed > 0) {
//         _saveCartToStorage();
//         Helpers.showSuccessSnackbar('Item dihapus dari keranjang');
//         return true;
//       }
//
//       return false;
//     } catch (e) {
//       _lastError.value = 'Failed to remove item: $e';
//       Helpers.logError('Error removing item from cart', e);
//       return false;
//     }
//   }
//
//   /// ✅ Update item quantity
//   bool updateItemQuantity(int menuItemId, int newQuantity) {
//     try {
//       _lastError.value = '';
//
//       if (newQuantity < 1) {
//         return removeItem(menuItemId);
//       }
//
//       if (newQuantity > 99) {
//         _lastError.value = 'Maksimal 99 item per menu';
//         return false;
//       }
//
//       final itemIndex = _cartItems.indexWhere(
//         (item) => item.menuItemId == menuItemId,
//       );
//
//       if (itemIndex != -1) {
//         _cartItems[itemIndex] = _cartItems[itemIndex].copyWith(
//           quantity: newQuantity,
//           updatedAt: DateTime.now(),
//         );
//         _saveCartToStorage();
//         return true;
//       }
//
//       return false;
//     } catch (e) {
//       _lastError.value = 'Failed to update quantity: $e';
//       Helpers.logError('Error updating item quantity', e);
//       return false;
//     }
//   }
//
//   /// ✅ Update item notes
//   bool updateItemNotes(int menuItemId, String? notes) {
//     try {
//       _lastError.value = '';
//
//       final itemIndex = _cartItems.indexWhere(
//         (item) => item.menuItemId == menuItemId,
//       );
//
//       if (itemIndex != -1) {
//         _cartItems[itemIndex] = _cartItems[itemIndex].copyWith(
//           notes: notes,
//           updatedAt: DateTime.now(),
//         );
//         _saveCartToStorage();
//         return true;
//       }
//
//       return false;
//     } catch (e) {
//       _lastError.value = 'Failed to update notes: $e';
//       Helpers.logError('Error updating item notes', e);
//       return false;
//     }
//   }
//
//   /// ✅ Increment item quantity
//   bool incrementItem(int menuItemId) {
//     final item = CartItemModel.findByMenuItemId(_cartItems, menuItemId);
//     if (item == null) return false;
//
//     return updateItemQuantity(menuItemId, item.quantity + 1);
//   }
//
//   /// ✅ Decrement item quantity
//   bool decrementItem(int menuItemId) {
//     final item = CartItemModel.findByMenuItemId(_cartItems, menuItemId);
//     if (item == null) return false;
//
//     return updateItemQuantity(menuItemId, item.quantity - 1);
//   }
//
//   /// ✅ Clear entire cart
//   void clearCart() {
//     try {
//       _cartItems.clear();
//       _storage.remove(StorageConstants.cartItems);
//       _lastError.value = '';
//       Helpers.showSuccessSnackbar('Keranjang dikosongkan');
//     } catch (e) {
//       _lastError.value = 'Failed to clear cart: $e';
//       Helpers.logError('Error clearing cart', e);
//     }
//   }
//
//   /// ✅ Get cart item by menu item id
//   CartItemModel? getItem(int menuItemId) {
//     return CartItemModel.findByMenuItemId(_cartItems, menuItemId);
//   }
//
//   /// ✅ Check if item exists in cart
//   bool hasItem(int menuItemId) {
//     return getItem(menuItemId) != null;
//   }
//
//   /// ✅ Get item quantity in cart
//   int getItemQuantity(int menuItemId) {
//     final item = getItem(menuItemId);
//     return item?.quantity ?? 0;
//   }
//
//   /// ✅ Validate cart for order placement
//   Map<String, dynamic> validateForOrder() {
//     return CartItemModel.validateForOrder(_cartItems);
//   }
//
//   /// ✅ Get items formatted for order API (sesuai backend DelPick)
//   /// Backend expects: { store_id, items: [{ menu_item_id, quantity, notes }] }
//   Map<String, dynamic> getOrderData() {
//     final validation = validateForOrder();
//
//     if (!validation['isValid']) {
//       throw Exception('Cart tidak valid: ${validation['errors'].join(', ')}');
//     }
//
//     return {
//       'store_id': storeId,
//       'items': CartItemModel.toApiJsonList(_cartItems),
//     };
//   }
//
//   /// ✅ Group items by category
//   Map<String, List<CartItemModel>> getItemsByCategory() {
//     return CartItemModel.groupByCategory(_cartItems);
//   }
//
//   /// ✅ Get available items only
//   List<CartItemModel> getAvailableItems() {
//     return CartItemModel.filterAvailable(_cartItems);
//   }
//
//   /// ✅ Get unavailable items
//   List<CartItemModel> getUnavailableItems() {
//     return CartItemModel.filterUnavailable(_cartItems);
//   }
//
//   /// ✅ Update item availability (when menu item status changes)
//   void updateItemAvailability(int menuItemId, bool isAvailable) {
//     try {
//       final itemIndex = _cartItems.indexWhere(
//         (item) => item.menuItemId == menuItemId,
//       );
//
//       if (itemIndex != -1) {
//         _cartItems[itemIndex] = _cartItems[itemIndex].copyWith(
//           isAvailable: isAvailable,
//           updatedAt: DateTime.now(),
//         );
//         _saveCartToStorage();
//
//         if (!isAvailable) {
//           Helpers.showWarningSnackbar(
//               'Item ${_cartItems[itemIndex].name} tidak tersedia');
//         }
//       }
//     } catch (e) {
//       Helpers.logError('Error updating item availability', e);
//     }
//   }
//
//   /// ✅ Refresh cart items (check availability from server)
//   Future<void> refreshItems() async {
//     try {
//       _isLoading.value = true;
//       _lastError.value = '';
//
//       if (_cartItems.isEmpty) return;
//
//       // In real implementation, you would call API to check item availability
//       // For now, we'll just validate current items
//       final validItems = _cartItems.where((item) => item.isValid).toList();
//
//       if (validItems.length != _cartItems.length) {
//         _cartItems.assignAll(validItems);
//         _saveCartToStorage();
//         Helpers.showWarningSnackbar('Beberapa item tidak valid telah dihapus');
//       }
//     } catch (e) {
//       _lastError.value = 'Failed to refresh cart: $e';
//       Helpers.logError('Error refreshing cart items', e);
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   /// ✅ Merge with existing cart (useful when user logs in)
//   Future<void> mergeCart(List<CartItemModel> newItems) async {
//     try {
//       _isLoading.value = true;
//       _lastError.value = '';
//
//       final allItems = [..._cartItems, ...newItems];
//       final mergedItems = CartItemModel.mergeDuplicates(allItems);
//
//       _cartItems.assignAll(mergedItems);
//       _saveCartToStorage();
//
//       if (newItems.isNotEmpty) {
//         Helpers.showSuccessSnackbar('Keranjang digabungkan');
//       }
//     } catch (e) {
//       _lastError.value = 'Failed to merge cart: $e';
//       Helpers.logError('Error merging cart', e);
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   /// ✅ Export cart (for sharing or backup)
//   String exportCart() {
//     try {
//       return json.encode({
//         'items': CartItemModel.toJsonList(_cartItems),
//         'exportedAt': DateTime.now().toIso8601String(),
//         'totalItems': itemCount,
//         'totalQuantity': totalQuantity,
//         'totalPrice': totalPrice,
//         'storeId': storeId,
//       });
//     } catch (e) {
//       Helpers.showErrorSnackbar('Error exporting cart', e);
//       return '';
//     }
//   }
//
//   /// ✅ Import cart (from sharing or backup)
//   Future<bool> importCart(String cartData) async {
//     try {
//       _isLoading.value = true;
//       _lastError.value = '';
//
//       final data = json.decode(cartData) as Map<String, dynamic>;
//       final itemsData = data['items'] as List<dynamic>;
//       final items = CartItemModel.fromJsonList(itemsData);
//
//       // Validate imported items
//       final validItems = items.where((item) => item.isValid).toList();
//
//       if (validItems.isNotEmpty) {
//         _cartItems.assignAll(validItems);
//         _saveCartToStorage();
//         Helpers.showSuccessSnackbar('Keranjang berhasil dimuat');
//         return true;
//       } else {
//         _lastError.value = 'Tidak ada item valid untuk dimuat';
//         return false;
//       }
//     } catch (e) {
//       _lastError.value = 'Failed to import cart: $e';
//       Helpers.logError('Error importing cart', e);
//       return false;
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   /// ✅ Get cart summary for display
//   Map<String, dynamic> getCartSummary() {
//     final validation = validateForOrder();
//
//     return {
//       'itemCount': itemCount,
//       'totalQuantity': totalQuantity,
//       'totalPrice': totalPrice,
//       'formattedTotalPrice': formattedTotalPrice,
//       'storeId': storeId,
//       'hasConsistentStore': hasConsistentStore,
//       'isEmpty': isEmpty,
//       'isValid': validation['isValid'],
//       'errors': validation['errors'],
//       'availableItems': getAvailableItems().length,
//       'unavailableItems': getUnavailableItems().length,
//     };
//   }
//
//   /// ✅ Format currency helper
//   String _formatCurrency(double amount) {
//     return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
//           RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]}.',
//         )}';
//   }
//
//   /// ✅ Debug methods
//   // void debugPrintCart() {
//   //   Helpers.logInfo('=== CART DEBUG ===');
//   //   Helpers.logInfo('Items: ${itemCount}');
//   //   Helpers.logInfo('Total Quantity: ${totalQuantity}');
//   //   Helpers.logInfo('Total Price: ${formattedTotalPrice}');
//   //   Helpers.logInfo('Store ID: ${storeId}');
//   //   Helpers.logInfo('Is Valid: ${validateForOrder()['isValid']}');
//   //
//   //   for (int i = 0; i < _cartItems.length; i++) {
//   //     final item = _cartItems[i];
//   //     Helpers.logInfo(
//   //         'Item $i: ${item.name} x${item.quantity} = ${item.formattedTotalPrice}');
//   //   }
//   //   Helpers.logInfo('==================');
//   // }
//
//   /// ✅ Cleanup when service is disposed
//   @override
//   void onClose() {
//     _cartItems.close();
//     _isLoading.close();
//     _lastError.close();
//     super.onClose();
//   }
// }
