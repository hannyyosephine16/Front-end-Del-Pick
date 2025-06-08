// lib/features/customer/controllers/store_detail_controller.dart
import 'package:get/get.dart';
import 'package:del_pick/data/repositories/menu_repository.dart';
import 'package:del_pick/data/models/menu/menu_item_model.dart';
import 'package:del_pick/core/errors/error_handler.dart';

class StoreDetailController extends GetxController {
  final MenuRepository _menuRepository;
  final int storeId;

  StoreDetailController({
    required MenuRepository menuRepository,
    required this.storeId,
  }) : _menuRepository = menuRepository;

  // Observable state
  final RxBool _isLoading = false.obs;
  final RxList<MenuItemModel> _menuItems = <MenuItemModel>[].obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<MenuItemModel> get menuItems => _menuItems;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasMenuItems => _menuItems.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadMenuItems();
  }

  Future<void> loadMenuItems() async {
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      final result = await _menuRepository.getMenuItemsByStoreId(
        storeId,
        params: {'limit': 50, 'page': 1},
      );

      if (result.isSuccess && result.data != null) {
        _menuItems.value = result.data!.data;
      } else {
        _hasError.value = true;
        _errorMessage.value = result.message ?? 'Failed to load menu items';
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

  Future<void> refreshMenu() async {
    await loadMenuItems();
  }

  List<MenuItemModel> getAvailableMenuItems() {
    return _menuItems.where((item) => item.canOrder).toList();
  }

  List<MenuItemModel> getMenuItemsByCategory(String category) {
    return _menuItems
        .where((item) =>
            item.category?.toLowerCase() == category.toLowerCase() &&
            item.canOrder)
        .toList();
  }

  List<String> getAvailableCategories() {
    final categories = _menuItems
        .where((item) => item.category != null && item.canOrder)
        .map((item) => item.category!)
        .toSet()
        .toList();

    categories.sort();
    return categories;
  }
}

// import 'package:get/get.dart';
// import 'package:del_pick/data/repositories/store_repository.dart';
// import 'package:del_pick/data/repositories/menu_repository.dart';
// import 'package:del_pick/data/models/store/store_model.dart';
// import 'package:del_pick/data/models/menu/menu_item_model.dart';
// import 'package:del_pick/features/customer/controllers/cart_controller.dart';
// import 'package:del_pick/core/errors/error_handler.dart';
//
// class StoreDetailController extends GetxController {
//   final StoreRepository _storeRepository = Get.find<StoreRepository>();
//   final MenuRepository _menuRepository = Get.find<MenuRepository>();
//   final CartController _cartController = Get.find<CartController>();
// // Observable state
//   final RxBool _isLoading = false.obs;
//   final RxBool _isLoadingMenu = false.obs;
//   final Rx<StoreModel?> _store = Rx<StoreModel?>(null);
//   final RxList<MenuItemModel> _menuItems = <MenuItemModel>[].obs;
//   final RxString _errorMessage = ''.obs;
//   final RxBool _hasError = false.obs;
//   final RxString _selectedCategory = 'All'.obs;
//   final RxList<String> _categories = <String>['All'].obs;
// // Getters
//   bool get isLoading => _isLoading.value;
//   bool get isLoadingMenu => _isLoadingMenu.value;
//   StoreModel? get store => _store.value;
//   List<MenuItemModel> get menuItems => _menuItems;
//   String get errorMessage => _errorMessage.value;
//   bool get hasError => _hasError.value;
//   String get selectedCategory => _selectedCategory.value;
//   List<String> get categories => _categories;
//   bool get hasMenuItems => _menuItems.isNotEmpty;
//   List<MenuItemModel> get filteredMenuItems {
//     if (_selectedCategory.value == 'All') {
//       return _menuItems;
//     }
//     return _menuItems
//         .where((item) => item.category == _selectedCategory.value)
//         .toList();
//   }
//
//   int _storeId = 0;
//   @override
//   void onInit() {
//     super.onInit();
//     final arguments = Get.arguments;
//     if (arguments != null && arguments['storeId'] != null) {
//       _storeId = arguments['storeId'];
//       loadStoreDetail();
//     }
//   }
//
//   Future<void> loadStoreDetail() async {
//     _isLoading.value = true;
//     _hasError.value = false;
//     _errorMessage.value = '';
//     try {
//       // For now, we'll get store from the list since we don't have getStoreById
//       // In a real app, you'd have a getStoreById method in the repository
//       await loadMenuItems();
//     } catch (e) {
//       _hasError.value = true;
//       _errorMessage.value = 'Failed to load store details';
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   Future<void> loadMenuItems() async {
//     _isLoadingMenu.value = true;
//     _hasError.value = false;
//     _errorMessage.value = '';
//     try {
//       final result = await _menuRepository.getMenuItemsByStoreId(_storeId);
//
//       if (result.isSuccess && result.data != null) {
//         _menuItems.value = result.data!;
//         _updateCategories();
//       } else {
//         _hasError.value = true;
//         _errorMessage.value = result.message ?? 'Failed to load menu items';
//       }
//     } catch (e) {
//       _hasError.value = true;
//       _errorMessage.value = 'Failed to load menu items';
//     } finally {
//       _isLoadingMenu.value = false;
//     }
//   }
//
//   void _updateCategories() {
//     final categorySet = <String>{'All'};
//     for (final item in _menuItems) {
//       if (item.category != null && item.category!.isNotEmpty) {
//         categorySet.add(item.category!);
//       }
//     }
//     _categories.value = categorySet.toList();
//   }
//
//   void selectCategory(String category) {
//     _selectedCategory.value = category;
//   }
//
//   Future<void> refreshData() async {
//     await loadStoreDetail();
//   }
//
//   void addToCart(MenuItemModel menuItem) {
//     if (store == null) {
//       Get.snackbar('Error', 'Store information not available');
//       return;
//     }
//     _cartController.addToCart(menuItem, store!);
//   }
//
//   void navigateToCart() {
//     Get.toNamed('/cart');
//   }
//
//   void navigateToMenuItemDetail(MenuItemModel menuItem) {
//     Get.toNamed('/menu_item_detail', arguments: {
//       'menuItem': menuItem,
//       'store': store,
//     });
//   }
//
// // Mock store data - in real app this would come from API
//   void _setMockStoreData() {
//     _store.value = StoreModel(
//       id: _storeId,
//       userId: 1,
//       name: 'Warung Padang Sederhana',
//       address: 'Jl. Sisingamangaraja No. 123, Balige',
//       description: 'Authentic Padang cuisine with traditional flavors',
//       openTime: '08:00',
//       closeTime: '22:00',
//       rating: 4.5,
//       totalProducts: 25,
//       imageUrl: 'https://via.placeholder.com/300x200',
//       phone: '+62812345678',
//       reviewCount: 150,
//       latitude: 2.38349390603264,
//       longitude: 99.14866498216043,
//       distance: 1.2,
//       status: 'active',
//     );
//   }
// }
