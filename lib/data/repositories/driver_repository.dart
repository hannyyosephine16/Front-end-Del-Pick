import 'package:del_pick/data/datasources/remote/driver_remote_datasource.dart';
import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/data/models/driver/driver_request_model.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:del_pick/core/constants/driver_status_constants.dart';
import 'package:dio/dio.dart';

class DriverRepository {
  final DriverRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  DriverRepository(this._remoteDataSource, this._localDataSource);

  Future<Result<DriverModel>> updateDriverStatus(String status) async {
    try {
      // Get current user to extract driver ID
      final currentUser = await _localDataSource.getUser();
      if (currentUser == null || !currentUser.isDriver) {
        return Result.failure('Driver not found');
      }

      // Get driver profile to get driver ID
      final profileResponse = await _remoteDataSource.getDriverProfile();
      if (profileResponse.statusCode != 200) {
        return Result.failure('Failed to get driver profile');
      }

      final profileData = profileResponse.data as Map<String, dynamic>;
      final driverData = profileData['data'] as Map<String, dynamic>;
      final driverId = driverData['driver']['id'] as int;

      // Update driver status
      final response = await _remoteDataSource.updateDriverStatus(
        driverId,
        {'status': status},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final driver =
            DriverModel.fromJson(responseData['data'] as Map<String, dynamic>);
        return Result.success(driver);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to update driver status');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> updateDriverLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      // Get current user to extract driver ID
      final currentUser = await _localDataSource.getUser();
      if (currentUser == null || !currentUser.isDriver) {
        return Result.failure('Driver not found');
      }

      // Get driver profile to get driver ID
      final profileResponse = await _remoteDataSource.getDriverProfile();
      if (profileResponse.statusCode != 200) {
        return Result.failure('Failed to get driver profile');
      }

      final profileData = profileResponse.data as Map<String, dynamic>;
      final driverData = profileData['data'] as Map<String, dynamic>;
      final driverId = driverData['driver']['id'] as int;

      // Update driver location
      final response = await _remoteDataSource.updateDriverLocation(
        driverId,
        {'latitude': latitude, 'longitude': longitude},
      );

      if (response.statusCode == 200) {
        return Result.success(null);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to update driver location');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<List<DriverRequestModel>>> getDriverRequests({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response =
          await _remoteDataSource.getDriverRequests(params: params);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;

        final requests = (data['requests'] as List)
            .map((json) =>
                DriverRequestModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return Result.success(requests);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to fetch driver requests');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<DriverRequestModel>> getDriverRequestById(int requestId) async {
    try {
      final response = await _remoteDataSource.getDriverRequestById(requestId);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final request = DriverRequestModel.fromJson(
            responseData['data'] as Map<String, dynamic>);
        return Result.success(request);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Driver request not found');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<DriverRequestModel>> respondToDriverRequest(
    int requestId,
    String action,
  ) async {
    try {
      final response = await _remoteDataSource.respondToDriverRequest(
        requestId,
        {'action': action},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final request = DriverRequestModel.fromJson(
            responseData['data'] as Map<String, dynamic>);
        return Result.success(request);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to respond to driver request');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<DriverModel>> getDriverProfile() async {
    try {
      final response = await _remoteDataSource.getDriverProfile();

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final driver = DriverModel.fromJson(
            responseData['data']['driver'] as Map<String, dynamic>);
        return Result.success(driver);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to get driver profile');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<DriverModel>> updateDriverProfile(
      Map<String, dynamic> data) async {
    try {
      final response = await _remoteDataSource.updateDriverProfile(data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final driver = DriverModel.fromJson(
            responseData['data']['driver'] as Map<String, dynamic>);
        return Result.success(driver);
      } else {
        return Result.failure(
            response.data['message'] ?? 'Failed to update driver profile');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // Helper methods
  bool isValidStatusTransition(String currentStatus, String targetStatus) {
    return DriverStatusConstants.canTransitionDriverStatus(
        currentStatus, targetStatus);
  }

  List<String> getValidStatusTransitions(String currentStatus) {
    return DriverStatusConstants.getAvailableDriverStatusTransitions(
        currentStatus);
  }

  String getStatusDisplayName(String status) {
    return DriverStatusConstants.getDriverStatusName(status);
  }

  String _handleDioError(DioException e) {
    final response = e.response;
    if (response?.data is Map<String, dynamic>) {
      return response!.data['message'] ?? 'Network error occurred';
    }
    return 'Network error occurred';
  }
}
