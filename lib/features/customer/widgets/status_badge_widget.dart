// core/widgets/status_badge.dart
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/core/constants/order_status_constants.dart';
import 'package:del_pick/core/constants/driver_status_constants.dart';
import 'package:del_pick/core/constants/store_status_constants.dart';

enum StatusBadgeType {
  order,
  driver,
  store,
  delivery,
}

class StatusBadge extends StatelessWidget {
  final String status;
  final StatusBadgeType type;
  final bool isSmall;

  const StatusBadge({
    Key? key,
    required this.status,
    required this.type,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
        border: Border.all(
          color: statusInfo.color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statusInfo.icon != null) ...[
            Icon(
              statusInfo.icon,
              size: isSmall ? 12 : 14,
              color: statusInfo.color,
            ),
            SizedBox(width: isSmall ? 2 : 4),
          ],
          Text(
            statusInfo.displayText,
            style:
                (isSmall ? AppTextStyles.labelSmall : AppTextStyles.labelMedium)
                    .copyWith(
              color: statusInfo.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  StatusInfo _getStatusInfo() {
    switch (type) {
      case StatusBadgeType.order:
        return _getOrderStatusInfo();
      case StatusBadgeType.driver:
        return _getDriverStatusInfo();
      case StatusBadgeType.store:
        return _getStoreStatusInfo();
      case StatusBadgeType.delivery:
        return _getDeliveryStatusInfo();
    }
  }

  StatusInfo _getOrderStatusInfo() {
    switch (status.toLowerCase()) {
      case OrderStatusConstants.pending:
        return StatusInfo(
          displayText: 'Pending',
          color: AppColors.warning,
          icon: Icons.schedule,
        );
      case OrderStatusConstants.confirmed:
        return StatusInfo(
          displayText: 'Confirmed',
          color: AppColors.info,
          icon: Icons.check_circle_outline,
        );
      case OrderStatusConstants.preparing:
        return StatusInfo(
          displayText: 'Preparing',
          color: AppColors.secondary,
          icon: Icons.restaurant,
        );
      case OrderStatusConstants.readyForPickup:
        return StatusInfo(
          displayText: 'Ready',
          color: AppColors.primary,
          icon: Icons.shopping_bag,
        );
      case OrderStatusConstants.onDelivery:
        return StatusInfo(
          displayText: 'On Delivery',
          color: AppColors.accent,
          icon: Icons.local_shipping,
        );
      case OrderStatusConstants.delivered:
        return StatusInfo(
          displayText: 'Delivered',
          color: AppColors.success,
          icon: Icons.check_circle,
        );
      case OrderStatusConstants.cancelled:
        return StatusInfo(
          displayText: 'Cancelled',
          color: AppColors.error,
          icon: Icons.cancel,
        );
      case OrderStatusConstants.rejected:
        return StatusInfo(
          displayText: 'Rejected',
          color: AppColors.error,
          icon: Icons.block,
        );
      default:
        return StatusInfo(
          displayText: status.toUpperCase(),
          color: AppColors.textOnSecondary,
          icon: Icons.help_outline,
        );
    }
  }

  StatusInfo _getDriverStatusInfo() {
    switch (status.toLowerCase()) {
      case DriverStatusConstants.driverActive:
        return StatusInfo(
          displayText: 'Active',
          color: AppColors.success,
          icon: Icons.check_circle,
        );
      case DriverStatusConstants.driverInactive:
        return StatusInfo(
          displayText: 'Inactive',
          color: AppColors.textOnSecondary,
          icon: Icons.radio_button_unchecked,
        );
      case DriverStatusConstants.driverBusy:
        return StatusInfo(
          displayText: 'Busy',
          color: AppColors.warning,
          icon: Icons.local_shipping,
        );
      default:
        return StatusInfo(
          displayText: status.toUpperCase(),
          color: AppColors.warning,
          icon: Icons.help_outline,
        );
    }
  }

  StatusInfo _getStoreStatusInfo() {
    switch (status.toLowerCase()) {
      case StoreStatusConstants.active:
        return StatusInfo(
          displayText: 'Open',
          color: AppColors.success,
          icon: Icons.store,
        );
      case StoreStatusConstants.inactive:
        return StatusInfo(
          displayText: 'Closed',
          color: AppColors.error,
          icon: Icons.store,
        );
      case StoreStatusConstants.closed:
        return StatusInfo(
          displayText: 'Closed',
          color: AppColors.error,
          icon: Icons.store,
        );
      default:
        return StatusInfo(
          displayText: status.toUpperCase(),
          color: AppColors.textOnSecondary,
          icon: Icons.store,
        );
    }
  }

  StatusInfo _getDeliveryStatusInfo() {
    switch (status.toLowerCase()) {
      case 'pending':
        return StatusInfo(
          displayText: 'Pending',
          color: AppColors.warning,
          icon: Icons.schedule,
        );
      case 'picked_up':
        return StatusInfo(
          displayText: 'Picked Up',
          color: AppColors.primary,
          icon: Icons.shopping_bag,
        );
      case 'on_way':
        return StatusInfo(
          displayText: 'On Way',
          color: AppColors.accent,
          icon: Icons.local_shipping,
        );
      case 'delivered':
        return StatusInfo(
          displayText: 'Delivered',
          color: AppColors.success,
          icon: Icons.check_circle,
        );
      case 'rejected':
        return StatusInfo(
          displayText: 'Rejected',
          color: AppColors.error,
          icon: Icons.block,
        );
      default:
        return StatusInfo(
          displayText: status.toUpperCase(),
          color: AppColors.textOnSecondary,
          icon: Icons.help_outline,
        );
    }
  }
}

class StatusInfo {
  final String displayText;
  final Color color;
  final IconData? icon;

  StatusInfo({
    required this.displayText,
    required this.color,
    this.icon,
  });
}

// Extension untuk kemudahan penggunaan
extension StatusBadgeExtension on String {
  Widget toOrderStatusBadge({bool isSmall = false}) {
    return StatusBadge(
      status: this,
      type: StatusBadgeType.order,
      isSmall: isSmall,
    );
  }

  Widget toDriverStatusBadge({bool isSmall = false}) {
    return StatusBadge(
      status: this,
      type: StatusBadgeType.driver,
      isSmall: isSmall,
    );
  }

  Widget toStoreStatusBadge({bool isSmall = false}) {
    return StatusBadge(
      status: this,
      type: StatusBadgeType.store,
      isSmall: isSmall,
    );
  }

  Widget toDeliveryStatusBadge({bool isSmall = false}) {
    return StatusBadge(
      status: this,
      type: StatusBadgeType.delivery,
      isSmall: isSmall,
    );
  }
}
