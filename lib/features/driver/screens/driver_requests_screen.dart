// lib/features/driver/screens/driver_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/driver_request_controller.dart';
import '../widgets/order_request_card.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../app/themes/app_colors.dart';

class DriverRequestsScreen extends GetView<DriverRequestController> {
  const DriverRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permintaan Pengantaran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
          ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(
                    child: Obx(() => _buildTabWithCount(
                          'Menunggu',
                          controller.pendingRequests.length,
                        )),
                  ),
                  Tab(
                    child: Obx(() => _buildTabWithCount(
                          'Diterima',
                          controller.acceptedRequests.length,
                        )),
                  ),
                  Tab(
                    child: Obx(() => _buildTabWithCount(
                          'Selesai',
                          controller.completedRequests.length,
                        )),
                  ),
                  Tab(
                    child: Obx(() => _buildTabWithCount(
                          'Lainnya',
                          controller.rejectedRequests.length +
                              controller.expiredRequests.length,
                        )),
                  ),
                ],
              ),
            ),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                children: [
                  _buildRequestList(controller.pendingRequests,
                      isPending: true),
                  _buildRequestList(controller.acceptedRequests),
                  _buildRequestList(controller.completedRequests),
                  _buildRequestList([
                    ...controller.rejectedRequests,
                    ...controller.expiredRequests,
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabWithCount(String title, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRequestList(List requests, {bool isPending = false}) {
    return Obx(() {
      // Loading state
      if (controller.isLoading && requests.isEmpty) {
        return const LoadingWidget();
      }

      // Error state
      if (controller.errorMessage.isNotEmpty && requests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.refresh,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        );
      }

      // Empty state
      if (requests.isEmpty) {
        String emptyMessage;
        IconData emptyIcon;

        if (isPending) {
          emptyMessage = 'Belum ada permintaan pengantaran baru';
          emptyIcon = Icons.hourglass_empty;
        } else {
          emptyMessage = 'Tidak ada permintaan pengantaran';
          emptyIcon = Icons.inbox_outlined;
        }

        return EmptyStateWidget(
          message: emptyMessage,
          icon: emptyIcon,
          onRefresh: controller.refresh,
        );
      }

      // List with pull to refresh
      return RefreshIndicator(
        onRefresh: () => controller.loadDriverRequests(refresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length + (controller.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Load more indicator
            if (index == requests.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: controller.isLoadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : InkWell(
                        onTap: controller.loadMore,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Muat Lebih Banyak',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
              );
            }

            final request = requests[index];
            return OrderRequestCard(
              driverRequest: request,
              onAccept: request.canAccept
                  ? () => controller.acceptRequest(request.id)
                  : null,
              onReject: request.canReject
                  ? () => controller.rejectRequest(request.id)
                  : null,
              onViewDetail: () => controller.getRequestDetail(request.id),
              isLoading: controller.isRequestProcessing(request.id),
            );
          },
        ),
      );
    });
  }
}
