// lib/features/driver/widgets/driver_order_card.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:del_pick/data/models/order/order_model.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class DriverOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final Function(String)? onActionPressed;
  final bool showActions;

  const DriverOrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onActionPressed,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppDimensions.spacingMD),
                _buildOrderInfo(),
                const SizedBox(height: AppDimensions.spacingMD),
                _buildCustomerInfo(),
                const SizedBox(height: AppDimensions.spacingMD),
                _buildDeliveryInfo(),
                if (showActions) ...[
                  const SizedBox(height: AppDimensions.spacingLG),
                  _buildActionButtons(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.code,
                style: AppTextStyles.h6.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXS),
              Text(
                order.formattedDate,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSM,
            vertical: AppDimensions.paddingXS,
          ),
          decoration: BoxDecoration(
            color: AppColors.getOrderStatusBackgroundColor(order.orderStatus),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          ),
          child: Text(
            order.statusDisplayName,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.getOrderStatusColor(order.orderStatus),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant,
                size: AppDimensions.iconSM,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.spacingXS),
              Expanded(
                child: Text(
                  order.storeName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag,
                    size: AppDimensions.iconSM,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacingXS),
                  Text(
                    '${order.totalItems} items',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                order.formattedTotal,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingSM),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
          child: Icon(
            Icons.person,
            size: AppDimensions.iconSM,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.customer?.name ?? 'Customer',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXS),
              Text(
                order.customer?.phone ?? 'No phone',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (order.orderStatus == 'on_delivery' ||
            order.orderStatus == 'preparing')
          IconButton(
            icon: Icon(
              Icons.phone,
              color: AppColors.success,
              size: AppDimensions.iconMD,
            ),
            onPressed: () => onActionPressed?.call('contact'),
          ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: AppDimensions.iconSM,
          color: AppColors.error,
        ),
        const SizedBox(width: AppDimensions.spacingXS),
        Expanded(
          child: Text(
            // ✅ FIXED: Use the correct getter
            order.deliveryAddress,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final actions = _getAvailableActions(order.orderStatus);

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;

        return Expanded(
          child: Container(
            margin: index > 0
                ? const EdgeInsets.only(left: AppDimensions.spacingSM)
                : EdgeInsets.zero,
            child: ElevatedButton.icon(
              onPressed: () => onActionPressed?.call(action['key']!),
              icon: Icon(
                action['icon'] as IconData,
                size: AppDimensions.iconSM,
              ),
              label: Text(
                action['label']!,
                style: AppTextStyles.labelSmall,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: action['color'] as Color,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingSM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _getAvailableActions(String status) {
    switch (status) {
      case 'preparing':
        return [
          {
            'key': 'start_delivery',
            'label': 'Mulai Kirim',
            'icon': Icons.delivery_dining,
            'color': AppColors.primary,
          },
          {
            'key': 'navigate',
            'label': 'Navigasi',
            'icon': Icons.navigation,
            'color': AppColors.info,
          },
        ];
      case 'on_delivery':
        return [
          {
            'key': 'complete_delivery',
            'label': 'Selesai',
            'icon': Icons.check_circle,
            'color': AppColors.success,
          },
          {
            'key': 'navigate',
            'label': 'Navigasi',
            'icon': Icons.navigation,
            'color': AppColors.info,
          },
        ];
      case 'delivered':
      case 'cancelled':
        return [
          {
            'key': 'track',
            'label': 'Detail',
            'icon': Icons.info,
            'color': AppColors.textSecondary,
          },
        ];
      default:
        return [];
    }
  }
}
// // lib/features/driver/widgets/driver_order_card.dart
// import 'package:flutter/material.dart';
// import 'package:del_pick/data/models/order/order_model.dart';
// import 'package:del_pick/app/themes/app_colors.dart';
// import 'package:del_pick/app/themes/app_text_styles.dart';
// import 'package:del_pick/app/themes/app_dimensions.dart';
//
// class DriverOrderCard extends StatelessWidget {
//   final OrderModel order;
//   final VoidCallback? onTap;
//   final Function(String)? onActionPressed;
//   final bool showActions;
//
//   const DriverOrderCard({
//     super.key,
//     required this.order,
//     this.onTap,
//     this.onActionPressed,
//     this.showActions = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadow.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
//           child: Padding(
//             padding: const EdgeInsets.all(AppDimensions.paddingLG),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(),
//                 const SizedBox(height: AppDimensions.spacingMD),
//                 _buildOrderInfo(),
//                 const SizedBox(height: AppDimensions.spacingMD),
//                 _buildCustomerInfo(),
//                 const SizedBox(height: AppDimensions.spacingMD),
//                 _buildDeliveryInfo(),
//                 if (showActions) ...[
//                   const SizedBox(height: AppDimensions.spacingLG),
//                   _buildActionButtons(),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 order.code,
//                 style: AppTextStyles.h6.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: AppDimensions.spacingXS),
//               Text(
//                 order.formattedDate,
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(
//             horizontal: AppDimensions.paddingSM,
//             vertical: AppDimensions.paddingXS,
//           ),
//           decoration: BoxDecoration(
//             // FIXED: Menggunakan method yang konsisten dari AppColors
//             color: AppColors.getOrderStatusBackgroundColor(order.orderStatus),
//             borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
//           ),
//           child: Text(
//             order.statusDisplayName,
//             style: AppTextStyles.labelSmall.copyWith(
//               // FIXED: Menggunakan method yang konsisten dari AppColors
//               color: AppColors.getOrderStatusColor(order.orderStatus),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildOrderInfo() {
//     return Container(
//       padding: const EdgeInsets.all(AppDimensions.paddingMD),
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.restaurant,
//                 size: AppDimensions.iconSM,
//                 color: AppColors.textSecondary,
//               ),
//               const SizedBox(width: AppDimensions.spacingXS),
//               Expanded(
//                 child: Text(
//                   order.storeName,
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AppDimensions.spacingSM),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.shopping_bag,
//                     size: AppDimensions.iconSM,
//                     color: AppColors.textSecondary,
//                   ),
//                   const SizedBox(width: AppDimensions.spacingXS),
//                   Text(
//                     '${order.totalItems} items',
//                     style: AppTextStyles.bodySmall.copyWith(
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//               Text(
//                 order.formattedTotal,
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   color: AppColors.success,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCustomerInfo() {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(AppDimensions.paddingSM),
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
//           ),
//           child: Icon(
//             Icons.person,
//             size: AppDimensions.iconSM,
//             color: AppColors.primary,
//           ),
//         ),
//         const SizedBox(width: AppDimensions.spacingMD),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 order.customer?.name ?? 'Customer',
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: AppDimensions.spacingXS),
//               Text(
//                 order.customer?.phone ?? 'No phone',
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (order.orderStatus == 'on_delivery' ||
//             order.orderStatus == 'preparing')
//           IconButton(
//             icon: Icon(
//               Icons.phone,
//               color: AppColors.success,
//               size: AppDimensions.iconMD,
//             ),
//             onPressed: () => onActionPressed?.call('contact'),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildDeliveryInfo() {
//     return Row(
//       children: [
//         Icon(
//           Icons.location_on,
//           size: AppDimensions.iconSM,
//           color: AppColors.error,
//         ),
//         const SizedBox(width: AppDimensions.spacingXS),
//         Expanded(
//           child: Text(
//             order.deliveryAddress,
//             style: AppTextStyles.bodySmall.copyWith(
//               color: AppColors.textSecondary,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButtons() {
//     final actions = _getAvailableActions(order.orderStatus);
//
//     if (actions.isEmpty) {
//       return const SizedBox.shrink();
//     }
//
//     return Row(
//       children: actions.asMap().entries.map((entry) {
//         final index = entry.key;
//         final action = entry.value;
//
//         return Expanded(
//           child: Container(
//             margin: index > 0
//                 ? const EdgeInsets.only(left: AppDimensions.spacingSM)
//                 : EdgeInsets.zero,
//             child: ElevatedButton.icon(
//               onPressed: () => onActionPressed?.call(action['key']!),
//               icon: Icon(
//                 action['icon'] as IconData,
//                 size: AppDimensions.iconSM,
//               ),
//               label: Text(
//                 action['label']!,
//                 style: AppTextStyles.labelSmall,
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: action['color'] as Color,
//                 foregroundColor: AppColors.textOnPrimary,
//                 padding: const EdgeInsets.symmetric(
//                   vertical: AppDimensions.paddingSM,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   List<Map<String, dynamic>> _getAvailableActions(String status) {
//     switch (status) {
//       case 'preparing':
//         return [
//           {
//             'key': 'start_delivery',
//             'label': 'Mulai Kirim',
//             'icon': Icons.delivery_dining,
//             'color': AppColors.primary,
//           },
//           {
//             'key': 'navigate',
//             'label': 'Navigasi',
//             'icon': Icons.navigation,
//             'color': AppColors.info,
//           },
//         ];
//       case 'on_delivery':
//         return [
//           {
//             'key': 'complete_delivery',
//             'label': 'Selesai',
//             'icon': Icons.check_circle,
//             'color': AppColors.success,
//           },
//           {
//             'key': 'navigate',
//             'label': 'Navigasi',
//             'icon': Icons.navigation,
//             'color': AppColors.info,
//           },
//         ];
//       case 'delivered':
//       case 'cancelled':
//         return [
//           {
//             'key': 'track',
//             'label': 'Detail',
//             'icon': Icons.info,
//             'color': AppColors.textSecondary,
//           },
//         ];
//       default:
//         return [];
//     }
//   }
// }
