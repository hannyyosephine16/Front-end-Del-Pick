// core/widgets/price_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';

class PriceWidget extends StatelessWidget {
  final double price;
  final TextStyle? style;
  final String currency;
  final bool showCurrency;
  final bool isDiscounted;
  final double? originalPrice;
  final Color? color;
  final bool isLarge;
  final bool isSmall;

  const PriceWidget({
    Key? key,
    required this.price,
    this.style,
    this.currency = 'IDR',
    this.showCurrency = true,
    this.isDiscounted = false,
    this.originalPrice,
    this.color,
    this.isLarge = false,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveStyle = _getEffectiveStyle();

    if (isDiscounted && originalPrice != null) {
      return _buildDiscountedPrice(effectiveStyle);
    }

    return Text(
      _formatPrice(price),
      style: effectiveStyle.copyWith(
        color: color ?? effectiveStyle.color,
      ),
    );
  }

  Widget _buildDiscountedPrice(TextStyle effectiveStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Original price (strikethrough)
        Text(
          _formatPrice(originalPrice!),
          style: (isSmall ? AppTextStyles.labelSmall : AppTextStyles.bodySmall)
              .copyWith(
            color: AppColors.textSecondary,
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColors.textSecondary,
          ),
        ),
        // Discounted price
        Text(
          _formatPrice(price),
          style: effectiveStyle.copyWith(
            color: color ?? AppColors.error, // Use red for discount price
          ),
        ),
      ],
    );
  }

  TextStyle _getEffectiveStyle() {
    if (style != null) return style!;

    if (isLarge) {
      return AppTextStyles.h6.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );
    }

    if (isSmall) {
      return AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w500,
      );
    }

    return AppTextStyles.bodyMedium.copyWith(
      fontWeight: FontWeight.w600,
    );
  }

  String _formatPrice(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: showCurrency ? 'Rp ' : '',
      decimalDigits: amount % 1 == 0 ? 0 : 2, // No decimal if whole number
    );

    return formatter.format(amount);
  }
}

// Named constructors untuk use case umum
extension PriceWidgetConstructors on PriceWidget {
  static Widget large(
    double price, {
    TextStyle? style,
    Color? color,
    bool showCurrency = true,
  }) {
    return PriceWidget(
      price: price,
      style: style,
      color: color,
      showCurrency: showCurrency,
      isLarge: true,
    );
  }

  static Widget small(
    double price, {
    TextStyle? style,
    Color? color,
    bool showCurrency = true,
  }) {
    return PriceWidget(
      price: price,
      style: style,
      color: color,
      showCurrency: showCurrency,
      isSmall: true,
    );
  }

  static Widget discounted(
    double price,
    double originalPrice, {
    TextStyle? style,
    Color? color,
    bool showCurrency = true,
  }) {
    return PriceWidget(
      price: price,
      originalPrice: originalPrice,
      style: style,
      color: color,
      showCurrency: showCurrency,
      isDiscounted: true,
    );
  }
}

// Extension untuk double/int ke PriceWidget
extension PriceExtension on double {
  Widget toPriceWidget({
    TextStyle? style,
    Color? color,
    bool showCurrency = true,
    bool isLarge = false,
    bool isSmall = false,
  }) {
    return PriceWidget(
      price: this,
      style: style,
      color: color,
      showCurrency: showCurrency,
      isLarge: isLarge,
      isSmall: isSmall,
    );
  }

  Widget toLargePriceWidget({
    TextStyle? style,
    Color? color,
    bool showCurrency = true,
  }) {
    return PriceWidget(
      price: this,
      style: style,
      color: color,
      showCurrency: showCurrency,
      isLarge: true,
    );
  }

  Widget toSmallPriceWidget({
    TextStyle? style,
    Color? color,
    bool showCurrency = true,
  }) {
    return PriceWidget(
      price: this,
      style: style,
      color: color,
      showCurrency: showCurrency,
      isSmall: true,
    );
  }

  Widget toDiscountedPriceWidget(
    double originalPrice, {
    TextStyle? style,
    Color? color,
    bool showCurrency = true,
  }) {
    return PriceWidget(
      price: this,
      originalPrice: originalPrice,
      style: style,
      color: color,
      showCurrency: showCurrency,
      isDiscounted: true,
    );
  }
}

extension IntPriceExtension on int {
  Widget toPriceWidget({
    TextStyle? style,
    Color? color,
    bool showCurrency = true,
    bool isLarge = false,
    bool isSmall = false,
  }) {
    return toDouble().toPriceWidget(
      style: style,
      color: color,
      showCurrency: showCurrency,
      isLarge: isLarge,
      isSmall: isSmall,
    );
  }

  Widget toLargePriceWidget({
    TextStyle? style,
    Color? color,
    bool showCurrency = true,
  }) {
    return toDouble().toLargePriceWidget(
      style: style,
      color: color,
      showCurrency: showCurrency,
    );
  }

  Widget toSmallPriceWidget({
    TextStyle? style,
    Color? color,
    bool showCurrency = true,
  }) {
    return toDouble().toSmallPriceWidget(
      style: style,
      color: color,
      showCurrency: showCurrency,
    );
  }
}
