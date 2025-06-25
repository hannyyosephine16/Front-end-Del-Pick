// lib/features/customer/widgets/menu_item_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:del_pick/data/models/menu/menu_item_model.dart';
import 'package:del_pick/core/widgets/network_image_widget.dart';
import 'package:del_pick/core/widgets/price_widget.dart';
import 'package:del_pick/core/widgets/custom_button.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

import '../../shared/widgets/netwrok_image_widget.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel menuItem;
  final VoidCallback? onTap;
  final Function(int quantity, String? notes)? onAddToCart;

  const MenuItemCard({
    super.key,
    required this.menuItem,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              const SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppDimensions.spacingSM),
                    _buildDescription(),
                    const SizedBox(height: AppDimensions.spacingMD),
                    _buildPriceAndButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            child: menuItem.imageUrl != null && menuItem.imageUrl!.isNotEmpty
                ? NetworkImageWidget(
                    imageUrl: menuItem.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 30,
                      color: Colors.grey[600],
                    ),
                  ),
          ),
          if (!menuItem.canOrder)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: const Center(
                child: Text(
                  'Habis',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                menuItem.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (menuItem.category != null && menuItem.category!.isNotEmpty)
                const SizedBox(height: 4),
              if (menuItem.category != null && menuItem.category!.isNotEmpty)
                _buildCategoryBadge(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        menuItem.category,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    if (menuItem.description == null || menuItem.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      menuItem.description!,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPriceAndButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Gunakan method formattedPrice dari model atau PriceWidget
        Text(
          menuItem.formattedPrice,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildAddToCartButton(),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    if (!menuItem.canOrder) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSM,
          vertical: AppDimensions.paddingXS,
        ),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        child: Text(
          'Habis',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return CustomButton(
      text: 'Tambah',
      onPressed: () => _showAddToCartDialog(),
      style: CustomButtonStyle.primary,
      size: CustomButtonSize.small,
      icon: Icons.add_shopping_cart,
    );
  }

  void _showAddToCartDialog() {
    if (onAddToCart == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Tambah ke Keranjang'),
        content: AddToCartDialog(
          menuItem: menuItem,
          onConfirm: onAddToCart!,
        ),
      ),
    );
  }
}

class AddToCartDialog extends StatefulWidget {
  final MenuItemModel menuItem;
  final Function(int quantity, String? notes) onConfirm;

  const AddToCartDialog({
    super.key,
    required this.menuItem,
    required this.onConfirm,
  });

  @override
  State<AddToCartDialog> createState() => _AddToCartDialogState();
}

class _AddToCartDialogState extends State<AddToCartDialog> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menu item info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.menuItem.imageUrl != null &&
                        widget.menuItem.imageUrl!.isNotEmpty
                    ? NetworkImageWidget(
                        imageUrl: widget.menuItem.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.restaurant_menu,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.menuItem.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Gunakan formattedPrice dari model
                    Text(
                      widget.menuItem.formattedPrice,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quantity selector
          Text(
            'Jumlah',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed:
                    _quantity > 1 ? () => setState(() => _quantity--) : null,
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: AppColors.primary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _quantity.toString(),
                  style: AppTextStyles.h5.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _quantity++),
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notes
          Text(
            'Catatan (Opsional)',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Tambahkan catatan untuk pesanan ini...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Total price
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Gunakan formattedPrice untuk total
                Text(
                  'Rp ${(widget.menuItem.price * _quantity).toStringAsFixed(0).replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]}.',
                      )}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Batal',
                  onPressed: () => Get.back(),
                  style: CustomButtonStyle.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Tambah ke Keranjang',
                  onPressed: () {
                    widget.onConfirm(
                      _quantity,
                      _notesController.text.trim().isEmpty
                          ? null
                          : _notesController.text.trim(),
                    );
                    Get.back();
                  },
                  style: CustomButtonStyle.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
