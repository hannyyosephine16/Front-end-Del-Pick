// lib/features/driver/controllers/driver_request_controller.dart
import 'package:get/get.dart';
import '../../../data/repositories/driver_request_repository.dart';
import '../../../data/models/driver/driver_request_model.dart';
import '../../../core/utils/result.dart';

class DriverRequestController extends GetxController {
  final DriverRequestRepository _repository;

  DriverRequestController(this._repository);

  // Observable variables
  final _driverRequests = <DriverRequestModel>[].obs;
  final _isLoading = false.obs;
  final _isLoadingMore = false.obs;
  final _currentPage = 1.obs;
  final _totalPages = 1.obs;
  final _hasMore = true.obs;
  final _errorMessage = ''.obs;
  final _isProcessingRequest = <int, bool>{}.obs;

  // Getters
  List<DriverRequestModel> get driverRequests => _driverRequests;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  bool get hasMore => _hasMore.value;
  String get errorMessage => _errorMessage.value;

  // Filter berdasarkan status (sesuai backend response)
  List<DriverRequestModel> get pendingRequests =>
      _driverRequests.where((req) => req.status == 'pending').toList();

  List<DriverRequestModel> get acceptedRequests =>
      _driverRequests.where((req) => req.status == 'accepted').toList();

  List<DriverRequestModel> get rejectedRequests =>
      _driverRequests.where((req) => req.status == 'rejected').toList();

  List<DriverRequestModel> get completedRequests =>
      _driverRequests.where((req) => req.status == 'completed').toList();

  List<DriverRequestModel> get expiredRequests =>
      _driverRequests.where((req) => req.status == 'expired').toList();

  @override
  void onInit() {
    super.onInit();
    loadDriverRequests();
  }

  Future<void> loadDriverRequests({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _driverRequests.clear();
      _hasMore.value = true;
      _errorMessage.value = '';
    }

    if (_isLoading.value || (!_hasMore.value && !refresh)) return;

    refresh ? _isLoading.value = true : _isLoadingMore.value = true;

    try {
      final result = await _repository.getDriverRequests(
        page: _currentPage.value,
        limit: 10,
      );

      result.fold(
        (error) {
          _errorMessage.value = error;
          Get.snackbar(
            'Error',
            error,
            snackPosition: SnackPosition.TOP,
          );
        },
        (response) {
          _totalPages.value = response.data.totalPages;

          if (refresh) {
            _driverRequests.assignAll(response.data.requests);
          } else {
            _driverRequests.addAll(response.data.requests);
          }

          _currentPage.value++;
          _hasMore.value = _currentPage.value <= _totalPages.value;
          _errorMessage.value = '';
        },
      );
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
      _isLoadingMore.value = false;
    }
  }

  Future<void> respondToRequest(int requestId, String action) async {
    if (_isProcessingRequest[requestId] == true) return;

    _isProcessingRequest[requestId] = true;

    try {
      final result =
          await _repository.respondToDriverRequest(requestId, action);

      result.fold(
        (error) {
          Get.snackbar(
            'Error',
            error,
            snackPosition: SnackPosition.TOP,
          );
        },
        (updatedRequest) {
          // Update local data
          final index =
              _driverRequests.indexWhere((req) => req.id == requestId);
          if (index != -1) {
            _driverRequests[index] = updatedRequest;
          }

          final actionText = action == 'accept' ? 'diterima' : 'ditolak';
          Get.snackbar(
            'Berhasil',
            'Permintaan pengantaran berhasil $actionText',
            snackPosition: SnackPosition.TOP,
          );
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isProcessingRequest[requestId] = false;
    }
  }

  Future<void> acceptRequest(int requestId) async {
    await respondToRequest(requestId, 'accept');
  }

  Future<void> rejectRequest(int requestId) async {
    await respondToRequest(requestId, 'reject');
  }

  Future<void> getRequestDetail(int requestId) async {
    try {
      final result = await _repository.getDriverRequestDetail(requestId);

      result.fold(
        (error) {
          Get.snackbar(
            'Error',
            error,
            snackPosition: SnackPosition.TOP,
          );
        },
        (request) {
          // Navigate to detail page or show detail dialog
          Get.toNamed('/driver-request-detail', arguments: request);
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  bool isRequestProcessing(int requestId) {
    return _isProcessingRequest[requestId] ?? false;
  }

  void refresh() {
    loadDriverRequests(refresh: true);
  }

  void loadMore() {
    if (_hasMore.value && !_isLoadingMore.value) {
      loadDriverRequests();
    }
  }

  void clearError() {
    _errorMessage.value = '';
  }

  @override
  void onClose() {
    _driverRequests.clear();
    _isProcessingRequest.clear();
    super.onClose();
  }
}
