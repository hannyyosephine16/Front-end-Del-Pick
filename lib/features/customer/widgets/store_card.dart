import 'package:flutter/material.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/core/widgets/network_image_widget.dart';

import '../../shared/widgets/netwrok_image_widget.dart';

class StoreCard extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onTap;
  final bool showDistance;
  final bool isCompact;

  const StoreCard({
    super.key,
    required this.store,
    required this.onTap,
    this.showDistance = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Image
            Container(
              height: isCompact ? 120 : 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: NetworkImageWidget(
                  imageUrl: store.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Icon(
                      Icons.store,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

            // Store Details
            Padding(
              padding: EdgeInsets.all(isCompact ? 8 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Name and Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
                          style: isCompact
                              ? AppTextStyles.bodyLarge
                              : AppTextStyles.h6,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: store.isOpen
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          store.isOpen ? 'Open' : 'Closed',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: store.isOpen
                                  ? AppColors.success
                                  : AppColors.error),
                        ),
                      )
                    ],
                  ),

                  if (!isCompact) ...[
                    const SizedBox(height: 4),

                    // Store Address
                    Text(
                      store.address,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  SizedBox(height: isCompact ? 4 : 8),

                  // Rating, Distance, and Operating Hours
                  Row(
                    children: [
                      // Rating
                      if (store.rating != null) ...[
                        const Icon(
                          Icons.star,
                          color: AppColors.ratingStar,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          store.displayRating,
                          style: AppTextStyles.bodySmall,
                        ),
                        if (store.reviewCount != null && !isCompact) ...[
                          const SizedBox(width: 2),
                          Text(
                            '(${store.reviewCount})',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(width: 12),
                      ],

                      // Distance
                      if (showDistance && store.distance != null) ...[
                        const Icon(
                          Icons.location_on,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          store.displayDistance,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Operating Hours (if available and not compact)
                      if (!isCompact &&
                          store.openTime != null &&
                          store.closeTime != null)
                        Text(
                          '${store.openTime} - ${store.closeTime}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),

                  // Description (if available and not compact)
                  if (!isCompact &&
                      store.description != null &&
                      store.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      store.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
