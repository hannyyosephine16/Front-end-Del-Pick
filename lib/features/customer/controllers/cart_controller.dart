// lib/features/customer/controllers/cart_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/models/order/cart_item_model.dart';
import 'package:del_pick/data/models/menu/menu_item_model.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/core/services/local/storage_service.dart';
import 'package:del_pick/core/constants/storage_constants.dart';
import 'package:del_pick/app/routes/app_routes.dart';

/// ✅ Cart Controller yang sesuai dengan backend DelPick API
class CartController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Observables
  final RxList<CartItemModel> _cartItems = <CartItemModel>[].obs;
  final RxDouble _subtotal = 0.0.obs;
  final RxInt _currentStoreId = 0.obs;
  final RxString _currentStoreName = ''.obs;

  // Getters
  List<CartItemModel> get cartItems => _cartItems;
  int get currentStoreId => _currentStoreId.value;
  String get currentStoreName => _currentStoreName.value;
  double get subtotal => _subtotal.value;
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _cartItems.isEmpty;
  bool get isNotEmpty => _cartItems.isNotEmpty;

  // Formatted getters untuk UI
  String get formattedSubtotal =>
      'Rp ${_subtotal.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  @override
  void onInit() {
    super.onInit();
    _loadCartFromStorage();
  }

  /// ✅ Load cart dari local storage
  void _loadCartFromStorage() {
    try {
      final cartData = _storageService.readJsonList(StorageConstants.cartItems);
      final storeId = _storageService.readInt(StorageConstants.cartStoreId);
      final storeName =
          _storageService.readString(StorageConstants.cartStoreName) ?? '';

      if (cartData != null && storeId != null) {
        _cartItems.value =
            cartData.map((json) => CartItemModel.fromJson(json)).toList();
        _currentStoreId.value = storeId;
        _currentStoreName.value = storeName;
        _calculateSubtotal();
      }
    } catch (e) {
      // Jika error loading, mulai dengan cart kosong
      _clearCart();
    }
  }

  /// ✅ Save cart ke local storage
  void _saveCartToStorage() {
    try {
      final cartData = _cartItems.map((item) => item.toJson()).toList();
      _storageService.writeJsonList(StorageConstants.cartItems, cartData);
      _storageService.writeInt(
          StorageConstants.cartStoreId, _currentStoreId.value);
      _storageService.writeString(
          StorageConstants.cartStoreName, _currentStoreName.value);
      _storageService.writeDouble(StorageConstants.cartTotal, _subtotal.value);
      _storageService.writeDateTime(
          StorageConstants.cartUpdatedAt, DateTime.now());
    } catch (e) {
      Get.snackbar('Error', 'Failed to save cart');
    }
  }

  /// ✅ Hitung subtotal (hanya item, delivery fee dihitung di backend)
  void _calculateSubtotal() {
    _subtotal.value = _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  /// ✅ Add item to cart - FIXED sesuai dengan CartItemModel.fromMenuItem signature
  Future<bool> addToCart(
    MenuItemModel menuItem,
    StoreModel store, {
    int quantity = 1,
    String? notes,
  }) async {
    try {
      // Check jika mencoba add dari store yang berbeda
      if (_cartItems.isNotEmpty && _currentStoreId.value != store.id) {
        final shouldClear = await _showStoreConflictDialog(store.name);
        if (shouldClear) {
          _clearCart();
        } else {
          return false;
        }
      }

      // Set current store jika cart kosong
      if (_cartItems.isEmpty) {
        _currentStoreId.value = store.id;
        _currentStoreName.value = store.name;
      }

      // Check jika item sudah ada
      final existingIndex = _cartItems.indexWhere(
        (item) => item.menuItemId == menuItem.id,
      );

      if (existingIndex != -1) {
        // Update quantity untuk item yang sudah ada
        final existingItem = _cartItems[existingIndex];
        _cartItems[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
          notes: notes ?? existingItem.notes,
          updatedAt: DateTime.now(),
        );
      } else {
        // ✅ FIXED: Buat Map untuk fromMenuItem yang sesuai dengan signature
        final menuItemMap = {
          'id': menuItem.id,
          'store_id': store.id,
          'name': menuItem.name,
          'description': menuItem.description,
          'price': menuItem.price,
          'category': menuItem.category,
          'image_url': menuItem.imageUrl,
          'is_available': menuItem.isAvailable,
        };

        final cartItem = CartItemModel.fromMenuItem(
          menuItemMap,
          quantity: quantity,
          notes: notes,
        );

        _cartItems.add(cartItem);
      }

      _calculateSubtotal();
      _saveCartToStorage();

      Get.snackbar(
        'Success',
        '${menuItem.name} added to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add item to cart: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// ✅ Update quantity item di cart
  void updateQuantity(int menuItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(menuItemId);
      return;
    }

    final index = _cartItems.indexWhere(
      (item) => item.menuItemId == menuItemId,
    );

    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(
        quantity: newQuantity,
        updatedAt: DateTime.now(),
      );
      _calculateSubtotal();
      _saveCartToStorage();
    }
  }

  /// ✅ Remove item dari cart
  void removeFromCart(int menuItemId) {
    _cartItems.removeWhere((item) => item.menuItemId == menuItemId);

    if (_cartItems.isEmpty) {
      _currentStoreId.value = 0;
      _currentStoreName.value = '';
    }

    _calculateSubtotal();
    _saveCartToStorage();

    Get.snackbar(
      'Removed',
      'Item removed from cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// ✅ Clear semua items dari cart
  void _clearCart() {
    _cartItems.clear();
    _currentStoreId.value = 0;
    _currentStoreName.value = '';
    _subtotal.value = 0.0;

    _storageService.remove(StorageConstants.cartItems);
    _storageService.remove(StorageConstants.cartStoreId);
    _storageService.remove(StorageConstants.cartStoreName);
    _storageService.remove(StorageConstants.cartTotal);
    _storageService.remove(StorageConstants.cartUpdatedAt);
  }

  /// ✅ Public method untuk clear cart
  void clearCart() {
    _clearCart();
    Get.snackbar(
      'Cart Cleared',
      'All items removed from cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// ✅ Dialog konfirmasi untuk store yang berbeda
  Future<bool> _showStoreConflictDialog(String newStoreName) async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Different Store'),
            content: Text(
              'Your cart contains items from $_currentStoreName. '
              'Adding items from $newStoreName will clear your current cart. '
              'Do you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Clear Cart',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// ✅ Proceed ke checkout
  void proceedToCheckout() {
    if (_cartItems.isEmpty) {
      Get.snackbar(
        'Empty Cart',
        'Please add items to cart before checkout',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Validate cart items
    final validation = CartItemModel.validateForOrder(_cartItems);
    if (!validation['isValid']) {
      Get.snackbar(
        'Invalid Cart',
        validation['errors'].join(', '),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Navigate ke checkout screen
    Get.toNamed(
      Routes.CHECKOUT,
      arguments: {
        'cartItems': _cartItems,
        'storeId': _currentStoreId.value,
        'storeName': _currentStoreName.value,
        'subtotal': _subtotal.value,
      },
    );
  }

  /// ✅ Get order data sesuai format backend API
  Map<String, dynamic> getOrderData() {
    return {
      'store_id': _currentStoreId.value,
      'items': _cartItems.map((item) => item.toApiJson()).toList(),
    };
  }

  /// ✅ Update notes untuk item tertentu
  void updateItemNotes(int menuItemId, String? notes) {
    final index = _cartItems.indexWhere(
      (item) => item.menuItemId == menuItemId,
    );

    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(
        notes: notes,
        updatedAt: DateTime.now(),
      );
      _saveCartToStorage();
    }
  }

  /// ✅ Get total quantity untuk item tertentu
  int getItemQuantity(int menuItemId) {
    final item = _cartItems.firstWhereOrNull(
      (item) => item.menuItemId == menuItemId,
    );
    return item?.quantity ?? 0;
  }

  /// ✅ Check apakah item ada di cart
  bool isItemInCart(int menuItemId) {
    return _cartItems.any((item) => item.menuItemId == menuItemId);
  }

  /// ✅ Get cart summary untuk display
  Map<String, dynamic> getCartSummary() {
    return {
      'store_id': _currentStoreId.value,
      'store_name': _currentStoreName.value,
      'item_count': _cartItems.length,
      'total_quantity': itemCount,
      'subtotal': _subtotal.value,
      'formatted_subtotal': formattedSubtotal,
      'is_empty': isEmpty,
      'items': _cartItems,
    };
  }

  /// ✅ Refresh cart (reload dari storage)
  void refreshCart() {
    _loadCartFromStorage();
  }

  /// ✅ Increment item quantity dengan limit
  bool incrementItemQuantity(int menuItemId, {int maxQuantity = 99}) {
    final index = _cartItems.indexWhere(
      (item) => item.menuItemId == menuItemId,
    );

    if (index != -1) {
      final currentItem = _cartItems[index];
      if (currentItem.quantity < maxQuantity) {
        _cartItems[index] = currentItem.copyWith(
          quantity: currentItem.quantity + 1,
          updatedAt: DateTime.now(),
        );
        _calculateSubtotal();
        _saveCartToStorage();
        return true;
      }
    }
    return false;
  }

  /// ✅ Decrement item quantity
  bool decrementItemQuantity(int menuItemId) {
    final index = _cartItems.indexWhere(
      (item) => item.menuItemId == menuItemId,
    );

    if (index != -1) {
      final currentItem = _cartItems[index];
      if (currentItem.quantity > 1) {
        _cartItems[index] = currentItem.copyWith(
          quantity: currentItem.quantity - 1,
          updatedAt: DateTime.now(),
        );
        _calculateSubtotal();
        _saveCartToStorage();
        return true;
      } else {
        // Jika quantity = 1, remove item
        removeFromCart(menuItemId);
        return true;
      }
    }
    return false;
  }

  /// ✅ Get item by menu item ID
  CartItemModel? getItemByMenuItemId(int menuItemId) {
    return _cartItems.firstWhereOrNull(
      (item) => item.menuItemId == menuItemId,
    );
  }

  /// ✅ Check minimum order amount
  bool isMinimumOrderMet({double minimumAmount = 5000}) {
    return _subtotal.value >= minimumAmount;
  }

  /// ✅ Get items grouped by category
  Map<String, List<CartItemModel>> getItemsByCategory() {
    return CartItemModel.groupByCategory(_cartItems);
  }

  /// ✅ Clear cart saat logout
  void onLogout() {
    _clearCart();
  }
}
