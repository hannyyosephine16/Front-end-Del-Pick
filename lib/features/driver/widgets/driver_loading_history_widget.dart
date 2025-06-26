// lib/core/widgets/driver_loading_widget.dart
import 'package:flutter/material.dart';
import 'package:del_pick/app/themes/app_colors.dart';
import 'package:del_pick/app/themes/app_text_styles.dart';
import 'package:del_pick/app/themes/app_dimensions.dart';

class DriverLoadingWidget extends StatelessWidget {
  final String? message;
  final bool showProgress;
  final DriverLoadingType type;

  const DriverLoadingWidget({
    super.key,
    this.message,
    this.showProgress = true,
    this.type = DriverLoadingType.general,
  });

  // Named constructor untuk history loading
  const DriverLoadingWidget.history({
    super.key,
    this.message = 'Memuat riwayat pesanan...',
    this.showProgress = true,
  }) : type = DriverLoadingType.history;

  // Named constructor untuk orders loading
  const DriverLoadingWidget.orders({
    super.key,
    this.message = 'Memuat pesanan...',
    this.showProgress = true,
  }) : type = DriverLoadingType.orders;

  // Named constructor untuk requests loading
  const DriverLoadingWidget.requests({
    super.key,
    this.message = 'Memuat permintaan...',
    this.showProgress = true,
  }) : type = DriverLoadingType.requests;

  // Named constructor untuk dashboard loading
  const DriverLoadingWidget.dashboard({
    super.key,
    this.message = 'Memuat dashboard...',
    this.showProgress = true,
  }) : type = DriverLoadingType.dashboard;

  // Named constructor untuk tracking loading
  const DriverLoadingWidget.tracking({
    super.key,
    this.message = 'Memuat data tracking...',
    this.showProgress = true,
  }) : type = DriverLoadingType.tracking;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case DriverLoadingType.history:
        return _buildHistoryLoading();
      case DriverLoadingType.orders:
        return _buildOrdersLoading();
      case DriverLoadingType.requests:
        return _buildRequestsLoading();
      case DriverLoadingType.dashboard:
        return _buildDashboardLoading();
      case DriverLoadingType.tracking:
        return _buildTrackingLoading();
      default:
        return _buildGeneralLoading();
    }
  }

  Widget _buildHistoryLoading() {
    return Column(
      children: [
        // Summary stats loading
        _buildStatsShimmer(),

        const SizedBox(height: AppDimensions.spacingLG),

        // List loading
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLG,
              vertical: AppDimensions.paddingSM,
            ),
            itemCount: 5,
            itemBuilder: (context, index) => _buildHistoryCardShimmer(),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      itemCount: 3,
      itemBuilder: (context, index) => _buildOrderCardShimmer(),
    );
  }

  Widget _buildRequestsLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      itemCount: 4,
      itemBuilder: (context, index) => _buildRequestCardShimmer(),
    );
  }

  Widget _buildDashboardLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card loading
          _buildStatusCardShimmer(),

          const SizedBox(height: AppDimensions.spacingXL),

          // Stats loading
          _buildStatsShimmer(),

          const SizedBox(height: AppDimensions.spacingXL),

          // Recent orders loading
          _buildShimmerBox(height: 20, width: 150),
          const SizedBox(height: AppDimensions.spacingMD),

          ...List.generate(
              3,
              (index) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppDimensions.spacingMD),
                    child: _buildOrderCardShimmer(),
                  )),
        ],
      ),
    );
  }

  Widget _buildTrackingLoading() {
    return Column(
      children: [
        // Map placeholder
        Container(
          height: 300,
          width: double.infinity,
          margin: const EdgeInsets.all(AppDimensions.paddingLG),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppDimensions.spacingMD),
                Text(
                  'Memuat peta...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tracking info loading
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              children: [
                _buildTrackingInfoShimmer(),
                const SizedBox(height: AppDimensions.spacingLG),
                _buildTrackingTimelineShimmer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.spacingLG),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLG),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < 3 ? AppDimensions.spacingSM : 0,
              ),
              child: _buildStatItemShimmer(),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatItemShimmer() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildShimmerBox(height: 24, width: 24, isCircle: true),
          const SizedBox(height: AppDimensions.spacingSM),
          _buildShimmerBox(height: 16, width: double.infinity),
          const SizedBox(height: AppDimensions.spacingXS),
          _buildShimmerBox(height: 12, width: 60),
        ],
      ),
    );
  }

  Widget _buildHistoryCardShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmerBox(height: 20, width: 80),
              const Spacer(),
              _buildShimmerBox(height: 16, width: 60),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          _buildShimmerBox(height: 16, width: double.infinity),
          const SizedBox(height: AppDimensions.spacingXS),
          _buildShimmerBox(height: 14, width: 200),
          const SizedBox(height: AppDimensions.spacingMD),
          Row(
            children: [
              _buildShimmerBox(height: 16, width: 100),
              const Spacer(),
              _buildShimmerBox(height: 16, width: 80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCardShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmerBox(height: 18, width: 100),
              const Spacer(),
              _buildShimmerBox(height: 24, width: 80),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          _buildShimmerBox(height: 16, width: double.infinity),
          const SizedBox(height: AppDimensions.spacingXS),
          _buildShimmerBox(height: 14, width: 150),
          const SizedBox(height: AppDimensions.spacingMD),
          Row(
            children: [
              _buildShimmerBox(height: 14, width: 120),
              const Spacer(),
              _buildShimmerBox(height: 14, width: 80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCardShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(height: 18, width: 120),
          const SizedBox(height: AppDimensions.spacingMD),
          _buildShimmerBox(height: 16, width: double.infinity),
          const SizedBox(height: AppDimensions.spacingXS),
          _buildShimmerBox(height: 14, width: 200),
          const SizedBox(height: AppDimensions.spacingLG),
          Row(
            children: [
              Expanded(
                child: _buildShimmerBox(height: 36, width: double.infinity),
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: _buildShimmerBox(height: 36, width: double.infinity),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        children: [
          _buildShimmerBox(height: 48, width: 48, isCircle: true),
          const SizedBox(width: AppDimensions.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(height: 18, width: 120),
                const SizedBox(height: AppDimensions.spacingXS),
                _buildShimmerBox(height: 14, width: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingInfoShimmer() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildShimmerBox(height: 16, width: 80),
              const Spacer(),
              _buildShimmerBox(height: 16, width: 100),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          _buildShimmerBox(height: 14, width: double.infinity),
          const SizedBox(height: AppDimensions.spacingXS),
          _buildShimmerBox(height: 14, width: 150),
        ],
      ),
    );
  }

  Widget _buildTrackingTimelineShimmer() {
    return Column(
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
          child: Row(
            children: [
              _buildShimmerBox(height: 12, width: 12, isCircle: true),
              const SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(height: 14, width: 120),
                    const SizedBox(height: AppDimensions.spacingXS),
                    _buildShimmerBox(height: 12, width: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildShimmerBox({
    required double height,
    required double width,
    bool isCircle = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      height: height,
      width: width == double.infinity ? null : width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: isCircle
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: const _ShimmerEffect(),
    );
  }
}

class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect();

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutSine,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}

enum DriverLoadingType {
  general,
  history,
  orders,
  requests,
  dashboard,
  tracking,
}
