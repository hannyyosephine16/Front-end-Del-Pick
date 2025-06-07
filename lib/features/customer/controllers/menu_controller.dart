import 'package:get/get.dart';
import 'package:del_pick/data/repositories/menu_repository.dart';
import 'package:del_pick/data/models/menu/menu_item_model.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/features/customer/controllers/cart_controller.dart';
import 'package:del_pick/core/errors/error_handler.dart';

class MenuController extends GetxController {
  final MenuRepository _menuRepository;
  final CartController _cartController = Get.find<CartController>();

  MenuController(this._menuRepository);

  // Observable state
  final RxBool _isLoading = false.obs;
  final RxList<MenuItemModel> _menuItems = <MenuItemModel>[].obs;
  final RxList<MenuItemModel> _filteredMenuItems = <MenuItemModel>[].obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;
  final Rx<StoreModel?> _currentStore = Rx<StoreModel?>(null);
  final RxString _searchQuery = ''.obs;
  final RxString _selectedCategory = 'All'.obs;
  final RxList<String> _categories = <String>['All'].obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<MenuItemModel> get menuItems => _filteredMenuItems;
  List<MenuItemModel> get allMenuItems => _menuItems;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  StoreModel? get currentStore => _currentStore.value;
  bool get hasMenuItems => _filteredMenuItems.isNotEmpty;
  String get searchQuery => _searchQuery.value;
  String get selectedCategory => _selectedCategory.value;
  List<String> get categories => _categories;

  @override
  void onInit() {
    super.onInit();

    // Get store data from arguments if available
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      final storeId = arguments['storeId'] as int?;
      final store = arguments['store'] as StoreModel?;

      if (store != null) {
        _currentStore.value = store;
      }

      if (storeId != null) {
        fetchMenuItemsByStore(storeId);
      }
    }
  }

  Future<void> fetchMenuItemsByStore(int storeId) async {
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      final result = await _menuRepository.getMenuItemsByStoreId(storeId);

      if (result.isSuccess && result.data != null) {
        _menuItems.value = result.data!;
        _extractCategories();
        _filterMenuItems();
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to fetch menu items';
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

  void _extractCategories() {
    final categorySet = <String>{'All'};
    for (final item in _menuItems) {
      if (item.category != null && item.category!.isNotEmpty) {
        categorySet.add(item.category!);
      }
    }
    _categories.value = categorySet.toList();
  }

  void _filterMenuItems() {
    List<MenuItemModel> filtered = _menuItems.toList();

    // Filter by category
    if (_selectedCategory.value != 'All') {
      filtered = filtered
          .where((item) => item.category == _selectedCategory.value)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              item.name
                  .toLowerCase()
                  .contains(_searchQuery.value.toLowerCase()) ||
              (item.description != null &&
                  item.description!
                      .toLowerCase()
                      .contains(_searchQuery.value.toLowerCase())))
          .toList();
    }

    // Filter only available items
    filtered = filtered.where((item) => item.canOrder).toList();

    _filteredMenuItems.value = filtered;
  }

  void searchMenuItems(String query) {
    _searchQuery.value = query;
    _filterMenuItems();
  }

  void selectCategory(String category) {
    _selectedCategory.value = category;
    _filterMenuItems();
  }

  void clearSearch() {
    _searchQuery.value = '';
    _filterMenuItems();
  }

  Future<void> refreshMenuItems() async {
    if (_currentStore.value != null) {
      await fetchMenuItemsByStore(_currentStore.value!.id);
    }
  }

  Future<void> addToCart(MenuItemModel menuItem,
      {int quantity = 1, String? notes}) async {
    if (_currentStore.value == null) {
      Get.snackbar('Error', 'Store information not available');
      return;
    }

    final success = await _cartController.addToCart(
      menuItem,
      _currentStore.value!,
      quantity: quantity,
      notes: notes,
    );

    if (success) {
      // Optionally show success message or update UI
    }
  }

  void navigateToMenuItemDetail(MenuItemModel menuItem) {
    Get.toNamed(
      '/menu_item_detail',
      arguments: {
        'menuItem': menuItem,
        'store': _currentStore.value,
      },
    );
  }

  void navigateToCart() {
    Get.toNamed('/cart');
  }

  // Helper methods
  int get cartItemCount => _cartController.itemCount;
  bool get hasItemsInCart => _cartController.isNotEmpty;
}
