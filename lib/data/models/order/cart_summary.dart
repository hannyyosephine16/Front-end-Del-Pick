import 'package:del_pick/core/utils/parsing_helper.dart';
import 'package:del_pick/data/models/order/cart_item_model.dart';

/// ✅ Cart Summary Model untuk UI
class CartSummary {
  final List<CartItemModel> items;
  final int itemCount;
  final int totalQuantity;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final int? storeId;
  final String? storeName;
  final bool isEmpty;
  final Map<String, dynamic> deliveryInfo;

  CartSummary({
    required this.items,
    required this.itemCount,
    required this.totalQuantity,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.storeId,
    this.storeName,
    required this.isEmpty,
    required this.deliveryInfo,
  });

  factory CartSummary.empty() {
    return CartSummary(
      items: [],
      itemCount: 0,
      totalQuantity: 0,
      subtotal: 0.0,
      deliveryFee: 0.0,
      total: 0.0,
      isEmpty: true,
      deliveryInfo: {},
    );
  }

  factory CartSummary.fromItems(
    List<CartItemModel> items, {
    double deliveryFee = 0.0,
    int? storeId,
    String? storeName,
    Map<String, dynamic>? deliveryInfo,
  }) {
    final subtotal = CartItemModel.calculateTotal(items);
    final totalQuantity = CartItemModel.calculateTotalQuantity(items);

    return CartSummary(
      items: items,
      itemCount: items.length,
      totalQuantity: totalQuantity,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: subtotal + deliveryFee,
      storeId: storeId ?? CartItemModel.getStoreId(items),
      storeName: storeName,
      isEmpty: items.isEmpty,
      deliveryInfo: deliveryInfo ?? {},
    );
  }

  String get formattedSubtotal => _formatCurrency(subtotal);
  String get formattedDeliveryFee => _formatCurrency(deliveryFee);
  String get formattedTotal => _formatCurrency(total);

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  Map<String, dynamic> toJson() {
    return {
      'items': CartItemModel.toJsonList(items),
      'itemCount': itemCount,
      'totalQuantity': totalQuantity,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'storeId': storeId,
      'storeName': storeName,
      'isEmpty': isEmpty,
      'deliveryInfo': deliveryInfo,
    };
  }
}
