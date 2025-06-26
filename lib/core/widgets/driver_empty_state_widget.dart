// lib/features/driver/widgets/driver_empty_state_widget.dart
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class DriverEmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Widget? customAction;
  final EdgeInsetsGeometry? padding;

  const DriverEmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.customAction,
    this.padding,
  });

  // Factory constructors untuk common empty states
  factory DriverEmptyStateWidget.noOrders({
    VoidCallback? onRefresh,
  }) {
    return DriverEmptyStateWidget(
      icon: Icons.inbox_outlined,
      title: 'Tidak ada pesanan',
      message:
          'Belum ada pesanan yang masuk.\nAktifkan status untuk menerima pesanan.',
      actionLabel: 'Refresh',
      onActionPressed: onRefresh,
    );
  }

  factory DriverEmptyStateWidget.noActiveOrders({
    VoidCallback? onRefresh,
    bool isOnline = true,
  }) {
    return DriverEmptyStateWidget(
      icon: Icons.hourglass_empty,
      title: 'Tidak ada pesanan aktif',
      message: isOnline
          ? 'Menunggu pesanan masuk...'
          : 'Aktifkan status untuk menerima pesanan',
      actionLabel: 'Refresh',
      onActionPressed: onRefresh,
    );
  }

  factory DriverEmptyStateWidget.noHistory({
    VoidCallback? onRefresh,
  }) {
    return DriverEmptyStateWidget(
      icon: Icons.history,
      title: 'Belum Ada Riwayat',
      message:
          'Riwayat pesanan akan muncul di sini\nsetelah Anda menyelesaikan pengiriman.',
      actionLabel: 'Refresh',
      onActionPressed: onRefresh,
    );
  }

  factory DriverEmptyStateWidget.noRequests({
    VoidCallback? onRefresh,
  }) {
    return DriverEmptyStateWidget(
      icon: Icons.notifications_none,
      title: 'Belum ada permintaan',
      message: 'Permintaan pengantaran akan muncul di sini.',
      actionLabel: 'Refresh',
      onActionPressed: onRefresh,
    );
  }

  factory DriverEmptyStateWidget.noEarnings({
    VoidCallback? onRefresh,
  }) {
    return DriverEmptyStateWidget(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Belum ada pendapatan',
      message: 'Mulai mengantar pesanan untuk mendapatkan pendapatan.',
      actionLabel: 'Lihat Pesanan',
      onActionPressed: onRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXL),

            // Title
            Text(
              title,
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.spacingSM),

            // Message
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.spacingXXL),

            // Action button or custom action
            if (customAction != null)
              customAction!
            else if (actionLabel != null && onActionPressed != null)
              _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: onActionPressed,
      icon: const Icon(Icons.refresh),
      label: Text(actionLabel!),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXL,
          vertical: AppDimensions.paddingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
      ),
    );
  }
}

// Loading State Widget
class DriverLoadingStateWidget extends StatelessWidget {
  final String message;
  final bool showMessage;
  final EdgeInsetsGeometry? padding;

  const DriverLoadingStateWidget({
    super.key,
    this.message = 'Memuat data...',
    this.showMessage = true,
    this.padding,
  });

  // Factory constructors untuk common loading states
  factory DriverLoadingStateWidget.orders() {
    return const DriverLoadingStateWidget(
      message: 'Memuat pesanan...',
    );
  }

  factory DriverLoadingStateWidget.requests() {
    return const DriverLoadingStateWidget(
      message: 'Memuat permintaan...',
    );
  }

  factory DriverLoadingStateWidget.earnings() {
    return const DriverLoadingStateWidget(
      message: 'Memuat data pendapatan...',
    );
  }

  factory DriverLoadingStateWidget.history() {
    return const DriverLoadingStateWidget(
      message: 'Memuat riwayat...',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            if (showMessage) ...[
              const SizedBox(height: AppDimensions.spacingLG),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Error State Widget
class DriverErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final IconData icon;

  const DriverErrorStateWidget({
    super.key,
    this.title = 'Terjadi Kesalahan',
    required this.message,
    this.actionLabel = 'Coba Lagi',
    this.onActionPressed,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.error.withOpacity(0.7),
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            Text(
              title,
              style: AppTextStyles.h6.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingSM),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null) ...[
              const SizedBox(height: AppDimensions.spacingXXL),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingXL,
                    vertical: AppDimensions.paddingMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
