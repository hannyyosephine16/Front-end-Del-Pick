import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;

  // Primary action (main button)
  final VoidCallback? onRetry;
  final VoidCallback? onRefresh;
  final VoidCallback? onAction;
  final String? actionText;
  final String? retryText;
  final String? refreshText;
  final bool isLoading;
  final IconData? actionIcon;

  // Secondary action (optional second button)
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionText;
  final IconData? secondaryActionIcon;

  // Custom styling
  final EdgeInsets? padding;
  final TextStyle? messageStyle;
  final TextStyle? subtitleStyle;
  final ButtonStyle? primaryButtonStyle;
  final ButtonStyle? secondaryButtonStyle;

  // Layout options
  final bool showVerticalSpacing;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.iconSize = 80,
    this.iconColor,

    // Actions
    this.onRetry,
    this.onRefresh,
    this.onAction,
    this.actionText,
    this.retryText,
    this.refreshText,
    this.isLoading = false,
    this.actionIcon,

    // Secondary action
    this.onSecondaryAction,
    this.secondaryActionText,
    this.secondaryActionIcon,

    // Styling
    this.padding,
    this.messageStyle,
    this.subtitleStyle,
    this.primaryButtonStyle,
    this.secondaryButtonStyle,

    // Layout
    this.showVerticalSpacing = true,
    this.spacing = 16,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  // Factory constructors for common use cases
  factory EmptyStateWidget.noData({
    String? message,
    VoidCallback? onRefresh,
    IconData? icon,
  }) {
    return EmptyStateWidget(
      message: message ?? 'Tidak ada data tersedia',
      icon: icon ?? Icons.inbox_outlined,
      onRefresh: onRefresh,
      refreshText: 'Muat Ulang',
      actionIcon: Icons.refresh,
    );
  }

  factory EmptyStateWidget.noConnection({
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      message: message ?? 'Tidak ada koneksi internet',
      subtitle: 'Periksa koneksi internet Anda dan coba lagi',
      icon: Icons.wifi_off,
      iconColor: Colors.orange,
      onRetry: onRetry,
      retryText: 'Coba Lagi',
      actionIcon: Icons.refresh,
    );
  }

  factory EmptyStateWidget.error({
    String? message,
    String? subtitle,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      message: message ?? 'Terjadi kesalahan',
      subtitle: subtitle ?? 'Silakan coba lagi dalam beberapa saat',
      icon: Icons.error_outline,
      iconColor: Colors.red,
      onRetry: onRetry,
      retryText: 'Coba Lagi',
      actionIcon: Icons.refresh,
    );
  }

  factory EmptyStateWidget.search({
    String? query,
    VoidCallback? onClear,
  }) {
    return EmptyStateWidget(
      message: query != null
          ? 'Tidak ada hasil untuk "$query"'
          : 'Tidak ada hasil pencarian',
      subtitle: 'Coba gunakan kata kunci yang berbeda',
      icon: Icons.search_off,
      onAction: onClear,
      actionText: 'Hapus Pencarian',
      actionIcon: Icons.clear,
    );
  }

  factory EmptyStateWidget.loading({
    String? message,
  }) {
    return EmptyStateWidget(
      message: message ?? 'Memuat data...',
      icon: Icons.hourglass_empty,
      showVerticalSpacing: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: padding ?? const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            // Icon
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppColors.textSecondary,
            ),

            if (showVerticalSpacing) SizedBox(height: spacing),

            // Main message
            Text(
              message,
              style: messageStyle ??
                  AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),

            // Subtitle (optional)
            if (subtitle != null) ...[
              SizedBox(height: spacing * 0.5),
              Text(
                subtitle!,
                style: subtitleStyle ??
                    AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            // Primary action button
            if (_hasPrimaryAction) ...[
              SizedBox(height: spacing * 1.5),
              _buildPrimaryButton(),
            ],

            // Secondary action button
            if (onSecondaryAction != null) ...[
              SizedBox(height: spacing),
              _buildSecondaryButton(),
            ],
          ],
        ),
      ),
    );
  }

  bool get _hasPrimaryAction {
    return onRetry != null || onRefresh != null || onAction != null;
  }

  String get _primaryActionText {
    if (actionText != null) return actionText!;
    if (retryText != null) return retryText!;
    if (refreshText != null) return refreshText!;
    if (onRetry != null) return 'Coba Lagi';
    if (onRefresh != null) return 'Muat Ulang';
    return 'OK';
  }

  VoidCallback? get _primaryAction {
    return onAction ?? onRetry ?? onRefresh;
  }

  Widget _buildPrimaryButton() {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : _primaryAction,
      style: primaryButtonStyle ??
          ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.7),
                ),
              ),
            )
          : Icon(actionIcon ?? Icons.refresh, size: 18),
      label: Text(
        isLoading ? 'Memuat...' : _primaryActionText,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return OutlinedButton.icon(
      onPressed: onSecondaryAction,
      style: secondaryButtonStyle ??
          OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      icon: Icon(secondaryActionIcon ?? Icons.arrow_back, size: 18),
      label: Text(
        secondaryActionText ?? 'Kembali',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

// Extension untuk kemudahan penggunaan
extension EmptyStateExtension on Widget {
  Widget withEmptyState({
    required bool isEmpty,
    required String emptyMessage,
    IconData? emptyIcon,
    VoidCallback? onRefresh,
    String? emptySubtitle,
  }) {
    if (isEmpty) {
      return EmptyStateWidget(
        message: emptyMessage,
        subtitle: emptySubtitle,
        icon: emptyIcon ?? Icons.inbox_outlined,
        onRefresh: onRefresh,
      );
    }
    return this;
  }
}
