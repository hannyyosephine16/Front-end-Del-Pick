// lib/data/repositories/driver_repository.dart - FIXED
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

  /// Update driver status - FIXED: Accept String parameter and return DriverModel
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

      // ✅ FIXED: Parse response structure properly
      final profileData = profileResponse.data as Map<String, dynamic>;
      final userData = profileData['data'] as Map<String, dynamic>;

      // Handle nested driver data structure
      Map<String, dynamic> driverData;
      if (userData.containsKey('driver') && userData['driver'] != null) {
        driverData = userData['driver'] as Map<String, dynamic>;
      } else {
        return Result.failure('Driver data not found in profile');
      }

      final driverId = driverData['id'] as int;

      // Update driver status
      final response = await _remoteDataSource.updateDriverStatus(
        driverId,
        {'status': status},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final updatedDriverData = responseData['data'] as Map<String, dynamic>;
        final driver = DriverModel.fromJson(updatedDriverData);

        // Update local storage
        await _localDataSource.updateDriverStatus(status);

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

  /// Update driver location - Returns Result<void> to match usage in tracking controller
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

      // ✅ FIXED: Parse response structure properly
      final profileData = profileResponse.data as Map<String, dynamic>;
      final userData = profileData['data'] as Map<String, dynamic>;

      Map<String, dynamic> driverData;
      if (userData.containsKey('driver') && userData['driver'] != null) {
        driverData = userData['driver'] as Map<String, dynamic>;
      } else {
        return Result.failure('Driver data not found in profile');
      }

      final driverId = driverData['id'] as int;

      // Update driver location
      final response = await _remoteDataSource.updateDriverLocation(
        driverId,
        {'latitude': latitude, 'longitude': longitude},
      );

      if (response.statusCode == 200) {
        // ✅ FIXED: Don't call deprecated updateDriverLocation method
        // Location updates are now handled by tracking system separately
        print('✅ Driver location updated on server (not stored locally)');
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

  /// Get driver profile - FIXED: Return DriverModel directly from parsed response
  Future<Result<DriverModel>> getDriverProfile() async {
    try {
      final response = await _remoteDataSource.getDriverProfile();

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['data'] as Map<String, dynamic>;

        // ✅ FIXED: Handle nested driver data structure
        if (userData.containsKey('driver') && userData['driver'] != null) {
          final driverData = userData['driver'] as Map<String, dynamic>;
          final driver = DriverModel.fromJson(driverData);
          return Result.success(driver);
        } else {
          return Result.failure('Driver data not found in response');
        }
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

  /// Update driver profile - FIXED: Return DriverModel directly
  Future<Result<DriverModel>> updateDriverProfile(
      Map<String, dynamic> data) async {
    try {
      final response = await _remoteDataSource.updateDriverProfile(data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // ✅ FIXED: Handle response structure properly
        Map<String, dynamic> driverData;

        // Try different response structures
        if (responseData.containsKey('data')) {
          final dataSection = responseData['data'] as Map<String, dynamic>;
          if (dataSection.containsKey('driver')) {
            driverData = dataSection['driver'] as Map<String, dynamic>;
          } else {
            // Data might be the driver object directly
            driverData = dataSection;
          }
        } else if (responseData.containsKey('driver')) {
          driverData = responseData['driver'] as Map<String, dynamic>;
        } else {
          // Response might be driver data directly
          driverData = responseData;
        }

        final driver = DriverModel.fromJson(driverData);

        // Update local storage with updated driver data
        await _localDataSource.saveDriverData(driverData);

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
