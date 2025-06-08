import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/data/models/menu/menu_item_model.dart';
import 'package:del_pick/data/repositories/store_repository.dart';
import 'package:del_pick/data/repositories/menu_repository.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';
import 'package:del_pick/core/errors/error_handler.dart';

class StoreDetailController extends GetxController {
  final StoreRepository _storeRepository;
  final MenuRepository _menuRepository;
  final CartController _cartController;

  StoreDetailController({
    required StoreRepository storeRepository,
    required MenuRepository menuRepository,
    required CartController cartController,
  })  : _storeRepository = storeRepository,
        _menuRepository = menuRepository,
        _cartController = cartController;

  // Observable state
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMenu = false.obs;
  final Rx<StoreModel?> _store = Rx<StoreModel?>(null);
  final RxList<MenuItemModel> _menuItems = <MenuItemModel>[].obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoadingMenu => _isLoadingMenu.value;
  StoreModel? get store => _store.value;
  List<MenuItemModel> get menuItems => _menuItems;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasMenuItems => _menuItems.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['storeId'] != null) {
      final storeId = arguments['storeId'] as int;
      fetchStoreDetail(storeId);
      fetchMenuItems(storeId);
    }
  }

  Future<void> fetchStoreDetail(int storeId) async {
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      // Since we don't have getStoreById in repository, we'll get from the store list
      final result = await _storeRepository.getAllStores();

      if (result.isSuccess && result.data != null) {
        final stores = result.data!;
        final foundStore =
            stores.firstWhereOrNull((store) => store.id == storeId);

        if (foundStore != null) {
          _store.value = foundStore;
        } else {
          _hasError.value = true;
          _errorMessage.value = 'Store not found';
        }
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to fetch store details';
      }
    } catch (e) {
      _hasError.value = true;
      if (e is Exception) {
        final failure = ErrorHandler.handleException(e);
        _errorMessage.value = ErrorHandler.getErrorMessage(failure);
      } else {
        _errorMessage.value = 'An unexpected error occurred';
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchMenuItems(int storeId) async {
    _isLoadingMenu.value = true;

    try {
      final result = await _menuRepository.getMenuItemsByStoreId(storeId);

      if (result.isSuccess && result.data != null) {
        _menuItems.value = result.data!;
      } else {
        // Don't show error for menu items, just empty list
        _menuItems.clear();
      }
    } catch (e) {
      // Silent error for menu items
      _menuItems.clear();
    } finally {
      _isLoadingMenu.value = false;
    }
  }

  Future<void> addToCart(MenuItemModel menuItem, {int quantity = 1}) async {
    if (store == null) return;

    final success = await _cartController.addToCart(
      menuItem,
      store!,
      quantity: quantity,
    );

    if (success) {
      Get.snackbar(
        'Added to Cart',
        '${menuItem.name} has been added to your cart',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void showAddToCartDialog(MenuItemModel menuItem) {
    Get.dialog(
      AddToCartDialog(
        menuItem: menuItem,
        onAddToCart: (quantity, notes) {
          addToCart(menuItem, quantity: quantity);
          Get.back();
        },
      ),
    );
  }

  Future<void> refreshStore() async {
    if (store != null) {
      await fetchStoreDetail(store!.id);
      await fetchMenuItems(store!.id);
    }
  }
}

// Add to Cart Dialog Widget
class AddToCartDialog extends StatefulWidget {
  final MenuItemModel menuItem;
  final Function(int quantity, String? notes) onAddToCart;

  const AddToCartDialog({
    super.key,
    required this.menuItem,
    required this.onAddToCart,
  });

  @override
  State<AddToCartDialog> createState() => _AddToCartDialogState();
}

class _AddToCartDialogState extends State<AddToCartDialog> {
  int quantity = 1;
  final notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.menuItem.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.menuItem.formattedPrice),
          if (widget.menuItem.description != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(widget.menuItem.description!),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed:
                    quantity > 1 ? () => setState(() => quantity--) : null,
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$quantity'),
              ),
              IconButton(
                onPressed: () => setState(() => quantity++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Special instructions (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => widget.onAddToCart(
            quantity,
            notesController.text.isEmpty ? null : notesController.text,
          ),
          child: const Text('Add to Cart'),
        ),
      ],
    );
  }
}
