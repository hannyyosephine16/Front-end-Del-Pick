import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/data/models/menu/menu_item_model.dart';
import 'package:del_pick/data/models/base/paginated_response.dart';
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
      // Sesuai dengan response backend GET /stores/{id}
      final result = await _storeRepository.getStoreById(storeId);

      if (result.isSuccess && result.data != null) {
        _store.value = result.data!;
        print('Store loaded successfully: ${_store.value!.name}');
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Gagal memuat detail toko';
        print('Failed to load store: ${result.message}');
      }
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';
      print('Error in fetchStoreDetail: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchMenuItems(int storeId) async {
    _isLoadingMenu.value = true;

    try {
      // Sesuai dengan endpoint GET /menu/store/{store_id}
      final result = await _menuRepository.getMenuItemsByStoreId(storeId);

      if (result.isSuccess && result.data != null) {
        // Handle response from menu endpoint
        if (result.data is List<MenuItemModel>) {
          _menuItems.value = result.data as List<MenuItemModel>;
        } else if (result.data is PaginatedResponse<MenuItemModel>) {
          _menuItems.value =
              (result.data as PaginatedResponse<MenuItemModel>).items;
        } else {
          // Handle raw list response
          _menuItems.clear();
        }
        print('Loaded ${_menuItems.length} menu items for store $storeId');
      } else {
        // Tidak ada menu item atau gagal load - bukan error kritik
        _menuItems.clear();
        print('No menu items found for store $storeId: ${result.message}');
      }
    } catch (e) {
      // Silent error untuk menu items
      _menuItems.clear();
      print('Error loading menu items for store $storeId: $e');
    } finally {
      _isLoadingMenu.value = false;
    }
  }

  Future<void> addToCart(MenuItemModel menuItem, {int quantity = 1}) async {
    if (store == null) {
      Get.snackbar(
        'Error',
        'Toko tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final success = await _cartController.addToCart(
        menuItem,
        store!,
        quantity: quantity,
      );

      if (success) {
        Get.snackbar(
          'Berhasil',
          '${menuItem.name} telah ditambahkan ke keranjang',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal menambahkan item ke keranjang',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
      await Future.wait([
        fetchStoreDetail(store!.id),
        fetchMenuItems(store!.id),
      ]);
    }
  }

  void retryLoadStore() {
    if (store != null) {
      fetchStoreDetail(store!.id);
    } else {
      // Jika store null, ambil dari arguments
      final arguments = Get.arguments as Map<String, dynamic>?;
      if (arguments != null && arguments['storeId'] != null) {
        final storeId = arguments['storeId'] as int;
        fetchStoreDetail(storeId);
      }
    }
  }

  @override
  void onClose() {
    // Cleanup jika diperlukan
    super.onClose();
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
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.menuItem.name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Harga
            Text(
              widget.menuItem.formattedPrice,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),

            // Deskripsi
            if (widget.menuItem.description != null &&
                widget.menuItem.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  widget.menuItem.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Quantity selector
            const Text(
              'Jumlah:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed:
                        quantity > 1 ? () => setState(() => quantity--) : null,
                    icon: const Icon(Icons.remove),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => setState(() => quantity++),
                    icon: const Icon(Icons.add),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Notes field
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan khusus (opsional)',
                hintText: 'Contoh: Tidak pedas, tanpa bawang...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 2,
              maxLength: 100,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => widget.onAddToCart(
            quantity,
            notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Tambah ke Keranjang'),
        ),
      ],
    );
  }
}
