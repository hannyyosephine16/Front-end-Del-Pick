// core/widgets/network_image_widget.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:del_pick/app/config/api_config.dart';
import 'package:del_pick/app/themes/app_colors.dart';

class NetworkImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool showShimmer;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;
  final Duration? fadeInDuration;
  final Duration? fadeOutDuration;
  final Map<String, String>? headers;

  const NetworkImageWidget({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
    this.borderRadius,
    this.showShimmer = true,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeOutDuration = const Duration(milliseconds: 100),
    this.headers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Jika imageUrl null atau kosong, tampilkan placeholder
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    // Build URL lengkap jika imageUrl adalah path relatif
    final String fullImageUrl = _buildFullImageUrl(imageUrl!);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: fullImageUrl,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: fadeInDuration!,
        fadeOutDuration: fadeOutDuration!,
        httpHeaders: _buildHeaders(),
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        memCacheWidth: width?.toInt(),
        memCacheHeight: height?.toInt(),
        maxWidthDiskCache: 1000,
        maxHeightDiskCache: 1000,
      ),
    );
  }

  String _buildFullImageUrl(String imageUrl) {
    // Jika URL sudah lengkap (http/https), gunakan langsung
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // Jika path relatif, gabungkan dengan base URL
    final String baseUrl = ApiConfig.baseUrl;
    final String cleanImageUrl =
        imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
    final String cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    return '$cleanBaseUrl/$cleanImageUrl';
  }

  Map<String, String> _buildHeaders() {
    final Map<String, String> defaultHeaders = {
      'Accept': 'image/*',
      'Cache-Control': 'max-age=3600',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers!);
    }

    return defaultHeaders;
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return SizedBox(
        width: width,
        height: height,
        child: placeholder,
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.image,
        size: 50,
        color: AppColors.shadowLight,
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    if (placeholder != null) {
      return showShimmer ? _wrapWithShimmer(placeholder!) : placeholder!;
    }

    final Widget defaultPlaceholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );

    return showShimmer
        ? _wrapWithShimmer(defaultPlaceholder)
        : defaultPlaceholder;
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return SizedBox(
        width: width,
        height: height,
        child: errorWidget,
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.broken_image,
        size: 50,
        color: AppColors.error,
      ),
    );
  }

  Widget _wrapWithShimmer(Widget child) {
    return Shimmer.fromColors(
      baseColor: shimmerBaseColor ?? AppColors.primary.withOpacity(0.3),
      highlightColor:
          shimmerHighlightColor ?? AppColors.primary.withOpacity(0.1),
      child: child,
    );
  }
}

// Specialized widgets untuk use case tertentu
class StoreImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const StoreImageWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NetworkImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      borderRadius: borderRadius,
      fit: BoxFit.cover,
      placeholder: Container(
        color: AppColors.primary.withOpacity(0.1),
        child: const Icon(
          Icons.store,
          size: 80,
          color: AppColors.primary,
        ),
      ),
      errorWidget: Container(
        color: AppColors.error.withOpacity(0.1),
        child: const Icon(
          Icons.store_mall_directory,
          size: 80,
          color: AppColors.error,
        ),
      ),
    );
  }
}

class MenuItemImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const MenuItemImageWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NetworkImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      borderRadius: borderRadius,
      fit: BoxFit.cover,
      placeholder: Container(
        color: AppColors.secondary.withOpacity(0.1),
        child: const Icon(
          Icons.restaurant_menu,
          size: 50,
          color: AppColors.secondary,
        ),
      ),
      errorWidget: Container(
        color: AppColors.error.withOpacity(0.1),
        child: const Icon(
          Icons.no_meals,
          size: 50,
          color: AppColors.error,
        ),
      ),
    );
  }
}

class UserAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? initials;

  const UserAvatarWidget({
    Key? key,
    required this.imageUrl,
    this.size = 40,
    this.initials,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      child: ClipOval(
        child: NetworkImageWidget(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(size / 2),
          placeholder: initials != null
              ? Center(
                  child: Text(
                    initials!,
                    style: TextStyle(
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : Icon(
                  Icons.person,
                  size: size * 0.6,
                  color: AppColors.primary,
                ),
          errorWidget: Icon(
            Icons.person,
            size: size * 0.6,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}

// Extension untuk memudahkan penggunaan
extension NetworkImageWidgetExtension on String? {
  Widget toNetworkImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return NetworkImageWidget(
      imageUrl: this,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  Widget toStoreImage({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return StoreImageWidget(
      imageUrl: this,
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  Widget toMenuItemImage({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return MenuItemImageWidget(
      imageUrl: this,
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  Widget toUserAvatar({
    double size = 40,
    String? initials,
  }) {
    return UserAvatarWidget(
      imageUrl: this,
      size: size,
      initials: initials,
    );
  }
}
