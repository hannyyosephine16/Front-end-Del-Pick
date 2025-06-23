// // lib/data/repositories/driver_repository.dart - FIXED VERSION WITH MISSING METHODS
// import 'package:del_pick/data/providers/driver_provider.dart';
// import 'package:del_pick/data/models/driver/driver_model.dart';
// import 'package:del_pick/data/models/driver/driver_request_model.dart';
// import 'package:del_pick/core/utils/result.dart';
// import 'package:del_pick/core/constants/driver_status_constants.dart';
// import 'package:del_pick/features/auth/controllers/auth_controller.dart';
//
// class DriverRepository {
//   final DriverProvider _driverProvider;
//
//   DriverRepository(this._driverProvider);
//
//   // ✅ FIXED: updateDriverStatus dengan signature yang benar
//   Future<Result<Map<String, dynamic>>> updateDriverStatus(
//     Map<String, dynamic> data,
//   ) async {
//     try {
//       print('DriverRepository: Updating driver status with data: $data');
//
//       // ✅ SIMPLE SOLUTION: Get driver ID dari AuthController
//       final authController = Get.find<AuthController>();
//       final driverData = authController.driverData;
//
//       if (driverData == null || driverData['id'] == null) {
//         return Result.failure('Driver ID not found. Please login again.');
//       }
//
//       final driverId = driverData['id'] as int;
//       print('DriverRepository: Using driver ID: $driverId');
//
//       // ✅ Call provider with both parameters as expected
//       final result = await _driverProvider.updateDriverStatus(driverId, data);
//
//       if (result.isSuccess) {
//         print('DriverRepository: Status updated successfully');
//         return Result.success(result.data ?? {});
//       } else {
//         print('DriverRepository: Status update failed: ${result.errorMessage}');
//         return Result.failure(result.errorMessage ?? 'Failed to update status');
//       }
//     } catch (e) {
//       print('DriverRepository: Exception in updateDriverStatus: $e');
//
//       // ✅ FALLBACK: Try to get driver ID from profile API if AuthController fails
//       try {
//         final profileResult = await getDriverProfile();
//         if (profileResult.isSuccess && profileResult.data != null) {
//           final profileData = profileResult.data!;
//
//           int? driverId;
//           if (profileData.containsKey('driver') &&
//               profileData['driver']['id'] != null) {
//             driverId = profileData['driver']['id'] as int;
//           } else if (profileData.containsKey('data') &&
//               profileData['data']['driver'] != null &&
//               profileData['data']['driver']['id'] != null) {
//             driverId = profileData['data']['driver']['id'] as int;
//           }
//
//           if (driverId != null) {
//             print(
//                 'DriverRepository: Retrying with driver ID from profile: $driverId');
//             final retryResult =
//                 await _driverProvider.updateDriverStatus(driverId, data);
//
//             if (retryResult.isSuccess) {
//               return Result.success(retryResult.data ?? {});
//             } else {
//               return Result.failure(
//                   retryResult.errorMessage ?? 'Failed to update status');
//             }
//           }
//         }
//       } catch (fallbackError) {
//         print('DriverRepository: Fallback also failed: $fallbackError');
//       }
//
//       return Result.failure('Failed to update driver status: ${e.toString()}');
//     }
//   }
//   // Future<Result<Map<String, dynamic>>> updateDriverStatus(
//   //   Map<String, dynamic> data,
//   // )
//   // async {
//   //   try {
//   //     print('DriverRepository: Updating driver status with data: $data');
//   //
//   //     // Call provider method yang sesuai dengan backend
//   //     // Backend endpoint: PATCH /drivers/:id/status
//   //     final result = await _driverProvider.updateDriverStatus(data);
//   //
//   //     if (result.isSuccess) {
//   //       print('DriverRepository: Status updated successfully');
//   //       return Result.success(result.data ?? {});
//   //     } else {
//   //       print('DriverRepository: Status update failed: ${result.errorMessage}');
//   //       return Result.failure(result.errorMessage ?? 'Failed to update status');
//   //     }
//   //   } catch (e) {
//   //     print('DriverRepository: Exception in updateDriverStatus: $e');
//   //     return Result.failure('Failed to update driver status: ${e.toString()}');
//   //   }
//   // }
//
//   // ✅ ADD: isValidStatusTransition method
//   bool isValidStatusTransition(String currentStatus, String targetStatus) {
//     // Use DriverStatusConstants untuk validasi
//     return DriverStatusConstants.canTransitionDriverStatus(
//         currentStatus, targetStatus);
//   }
//
//   Future<Result<Map<String, dynamic>>> updateDriverLocation(
//     int driverId,
//     double latitude,
//     double longitude,
//   ) async {
//     return await _driverProvider.updateDriverLocation(
//         driverId, latitude, longitude);
//   }
//
//   Future<Result<Map<String, dynamic>>> getDriverProfile() async {
//     return await _driverProvider.getDriverProfile();
//   }
//
//   Future<Result<Map<String, dynamic>>> updateDriverProfile(
//     Map<String, dynamic> data,
//   ) async {
//     try {
//       final result = await _driverProvider.updateDriverProfile(data);
//
//       if (result.isSuccess && result.data != null) {
//         return Result.success(result.data!);
//       } else {
//         return Result.failure(
//             result.errorMessage ?? 'Failed to update driver profile');
//       }
//     } catch (e) {
//       return Result.failure(e.toString());
//     }
//   }
//
//   Future<Result<List<DriverRequestModel>>> getDriverRequests({
//     Map<String, dynamic>? params,
//   }) async {
//     try {
//       final result = await _driverProvider.getDriverRequests(params: params);
//
//       if (result.isSuccess && result.data != null) {
//         final data = result.data!['data']?['requests'] as List? ??
//             result.data!['requests'] as List? ??
//             [];
//         final requests =
//             data.map((json) => DriverRequestModel.fromJson(json)).toList();
//         return Result.success(requests);
//       } else {
//         return Result.failure(
//             result.errorMessage ?? 'Failed to fetch driver requests');
//       }
//     } catch (e) {
//       return Result.failure(e.toString());
//     }
//   }
//
//   Future<Result<DriverRequestModel>> getDriverRequestById(int requestId) async {
//     try {
//       final result = await _driverProvider.getDriverRequestById(requestId);
//
//       if (result.isSuccess && result.data != null) {
//         final requestData =
//             result.data!['data'] as Map<String, dynamic>? ?? result.data!;
//         final request = DriverRequestModel.fromJson(requestData);
//         return Result.success(request);
//       } else {
//         return Result.failure(
//             result.errorMessage ?? 'Driver request not found');
//       }
//     } catch (e) {
//       return Result.failure(e.toString());
//     }
//   }
//
//   Future<Result<DriverRequestModel>> respondToDriverRequest(
//     int requestId,
//     String action,
//   ) async {
//     try {
//       final result =
//           await _driverProvider.respondToDriverRequest(requestId, action);
//
//       if (result.isSuccess && result.data != null) {
//         final requestData =
//             result.data!['data'] as Map<String, dynamic>? ?? result.data!;
//         final request = DriverRequestModel.fromJson(requestData);
//         return Result.success(request);
//       } else {
//         return Result.failure(
//             result.errorMessage ?? 'Failed to respond to driver request');
//       }
//     } catch (e) {
//       return Result.failure(e.toString());
//     }
//   }
//
//   // ✅ ADD: Additional helper methods
//   List<String> getValidStatusTransitions(String currentStatus) {
//     return DriverStatusConstants.getAvailableDriverStatusTransitions(
//         currentStatus);
//   }
//
//   bool canChangeStatusTo(String currentStatus, String targetStatus) {
//     return isValidStatusTransition(currentStatus, targetStatus);
//   }
//
//   String getStatusDisplayName(String status) {
//     return DriverStatusConstants.getDriverStatusName(status);
//   }
// }
// lib/data/repositories/driver_repository.dart - WITH GET PACKAGE (FIXED FOR YOUR AUTH CONTROLLER)
import 'package:get/get.dart';
import 'package:del_pick/data/providers/driver_provider.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/data/models/driver/driver_request_model.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:del_pick/core/constants/driver_status_constants.dart';
import 'package:del_pick/features/auth/controllers/auth_controller.dart';

class DriverRepository {
  final DriverProvider _driverProvider;

  DriverRepository(this._driverProvider);

  // ✅ SOLUTION WITH YOUR AUTH CONTROLLER: updateDriverStatus menggunakan Get.find
  Future<Result<Map<String, dynamic>>> updateDriverStatus(
    Map<String, dynamic> data,
  ) async {
    try {
      print('DriverRepository: Updating driver status with data: $data');

      // ✅ METHOD 1: Try to get from AuthController (your existing controller)
      int? driverId = await _getDriverIdFromAuth();

      // ✅ METHOD 2: Fallback to profile API if AuthController fails
      if (driverId == null) {
        driverId = await _getDriverIdFromProfile();
      }

      if (driverId == null) {
        return Result.failure('Driver ID not found. Please login again.');
      }

      print('DriverRepository: Using driver ID: $driverId');

      // ✅ Call provider with correct signature
      final result = await _driverProvider.updateDriverStatus(driverId, data);

      if (result.isSuccess) {
        print('DriverRepository: Status updated successfully');
        return Result.success(result.data ?? {});
      } else {
        print('DriverRepository: Status update failed: ${result.errorMessage}');
        return Result.failure(result.errorMessage ?? 'Failed to update status');
      }
    } catch (e) {
      print('DriverRepository: Exception in updateDriverStatus: $e');
      return Result.failure('Failed to update driver status: ${e.toString()}');
    }
  }

  // ✅ METHOD 1: Get driver ID dari YOUR AuthController
  Future<int?> _getDriverIdFromAuth() async {
    try {
      // ✅ Check if AuthController is registered
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();

        // ✅ Use your existing driverData getter
        final driverData = authController.driverData;
        if (driverData != null && driverData['id'] != null) {
          final driverId = driverData['id'] as int;
          print(
              'DriverRepository: Found driver ID from AuthController: $driverId');
          return driverId;
        }

        // ✅ Alternative: Check if user is driver and try rawUserData
        if (authController.isDriver && authController.rawUserData != null) {
          final rawData = authController.rawUserData!;

          // Check if driver data exists in rawUserData
          if (rawData.containsKey('driver') && rawData['driver'] != null) {
            final driver = rawData['driver'] as Map<String, dynamic>;
            if (driver['id'] != null) {
              final driverId = driver['id'] as int;
              print(
                  'DriverRepository: Found driver ID from rawUserData: $driverId');
              return driverId;
            }
          }
        }

        print(
            'DriverRepository: AuthController exists but no driver data found');
        return null; // Will fallback to profile API
      } else {
        print(
            'DriverRepository: AuthController not registered, trying profile API...');
        return null; // Will fallback to profile API
      }
    } catch (e) {
      print(
          'DriverRepository: Error getting driver ID from AuthController: $e');
      return null; // Will fallback to profile API
    }
  }

  // ✅ METHOD 2: Get driver ID dari profile API (fallback)
  Future<int?> _getDriverIdFromProfile() async {
    try {
      print('DriverRepository: Getting driver ID from profile API...');

      final profileResult = await getDriverProfile();
      if (profileResult.isSuccess && profileResult.data != null) {
        final profileData = profileResult.data!;

        // ✅ Try different response structures from backend
        // Structure 1: { "driver": { "id": 123 } }
        if (profileData.containsKey('driver') &&
            profileData['driver'] is Map<String, dynamic> &&
            profileData['driver']['id'] != null) {
          final driverId = profileData['driver']['id'] as int;
          print('DriverRepository: Found driver ID in driver field: $driverId');
          return driverId;
        }

        // Structure 2: { "data": { "driver": { "id": 123 } } }
        if (profileData.containsKey('data') &&
            profileData['data'] is Map<String, dynamic>) {
          final data = profileData['data'] as Map<String, dynamic>;
          if (data.containsKey('driver') &&
              data['driver'] is Map<String, dynamic> &&
              data['driver']['id'] != null) {
            final driverId = data['driver']['id'] as int;
            print(
                'DriverRepository: Found driver ID in data.driver field: $driverId');
            return driverId;
          }
        }

        // Structure 3: Response dari login yang tersimpan di AuthController
        if (profileData.containsKey('user') &&
            profileData['user'] is Map<String, dynamic>) {
          final userData = profileData['user'] as Map<String, dynamic>;
          if (userData.containsKey('driver') &&
              userData['driver'] is Map<String, dynamic> &&
              userData['driver']['id'] != null) {
            final driverId = userData['driver']['id'] as int;
            print(
                'DriverRepository: Found driver ID in user.driver field: $driverId');
            return driverId;
          }
        }

        print('DriverRepository: Could not find driver ID in profile response');
        print('DriverRepository: Profile structure: $profileData');
        return null;
      } else {
        print(
            'DriverRepository: Failed to get profile: ${profileResult.errorMessage}');
        return null;
      }
    } catch (e) {
      print('DriverRepository: Error getting driver ID from profile: $e');
      return null;
    }
  }

  // ✅ ADD: isValidStatusTransition method
  bool isValidStatusTransition(String currentStatus, String targetStatus) {
    return DriverStatusConstants.canTransitionDriverStatus(
        currentStatus, targetStatus);
  }

  Future<Result<Map<String, dynamic>>> updateDriverLocation(
    int driverId,
    double latitude,
    double longitude,
  ) async {
    return await _driverProvider.updateDriverLocation(
        driverId, latitude, longitude);
  }

  Future<Result<Map<String, dynamic>>> getDriverProfile() async {
    return await _driverProvider.getDriverProfile();
  }

  Future<Result<Map<String, dynamic>>> updateDriverProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _driverProvider.updateDriverProfile(data);

      if (result.isSuccess && result.data != null) {
        return Result.success(result.data!);
      } else {
        return Result.failure(
            result.errorMessage ?? 'Failed to update driver profile');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<List<DriverRequestModel>>> getDriverRequests({
    Map<String, dynamic>? params,
  }) async {
    try {
      final result = await _driverProvider.getDriverRequests(params: params);

      if (result.isSuccess && result.data != null) {
        final data = result.data!['data']?['requests'] as List? ??
            result.data!['requests'] as List? ??
            [];
        final requests =
            data.map((json) => DriverRequestModel.fromJson(json)).toList();
        return Result.success(requests);
      } else {
        return Result.failure(
            result.errorMessage ?? 'Failed to fetch driver requests');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<DriverRequestModel>> getDriverRequestById(int requestId) async {
    try {
      final result = await _driverProvider.getDriverRequestById(requestId);

      if (result.isSuccess && result.data != null) {
        final requestData =
            result.data!['data'] as Map<String, dynamic>? ?? result.data!;
        final request = DriverRequestModel.fromJson(requestData);
        return Result.success(request);
      } else {
        return Result.failure(
            result.errorMessage ?? 'Driver request not found');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<DriverRequestModel>> respondToDriverRequest(
    int requestId,
    String action,
  ) async {
    try {
      final result =
          await _driverProvider.respondToDriverRequest(requestId, action);

      if (result.isSuccess && result.data != null) {
        final requestData =
            result.data!['data'] as Map<String, dynamic>? ?? result.data!;
        final request = DriverRequestModel.fromJson(requestData);
        return Result.success(request);
      } else {
        return Result.failure(
            result.errorMessage ?? 'Failed to respond to driver request');
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ✅ ADD: Additional helper methods
  List<String> getValidStatusTransitions(String currentStatus) {
    return DriverStatusConstants.getAvailableDriverStatusTransitions(
        currentStatus);
  }

  bool canChangeStatusTo(String currentStatus, String targetStatus) {
    return isValidStatusTransition(currentStatus, targetStatus);
  }

  String getStatusDisplayName(String status) {
    return DriverStatusConstants.getDriverStatusName(status);
  }

  // ✅ BONUS: Method untuk update location yang otomatis cari driver ID
  Future<Result<Map<String, dynamic>>> updateCurrentDriverLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      // Try AuthController first, then profile API
      int? driverId = await _getDriverIdFromAuth();
      driverId ??= await _getDriverIdFromProfile();

      if (driverId == null) {
        return Result.failure(
            'Driver ID not found. Please ensure you are logged in as a driver.');
      }

      return await updateDriverLocation(driverId, latitude, longitude);
    } catch (e) {
      return Result.failure('Failed to update location: ${e.toString()}');
    }
  }

  // ✅ HELPER: Method untuk debugging - cek apa AuthController punya driver data
  void debugDriverData() {
    try {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        print('=== DRIVER DATA DEBUG ===');
        print('Is Driver: ${authController.isDriver}');
        print('Driver Data: ${authController.driverData}');
        print('Raw User Data: ${authController.rawUserData}');
        print('========================');
      } else {
        print('AuthController not registered');
      }
    } catch (e) {
      print('Error debugging driver data: $e');
    }
  }
}

// class DriverRepository {
//   final DriverProvider _driverProvider;
//
//   DriverRepository(this._driverProvider);
//
//   // ✅ SOLUTION WITH GET: updateDriverStatus menggunakan Get.find
//   Future<Result<Map<String, dynamic>>> updateDriverStatus(
//     Map<String, dynamic> data,
//   ) async {
//     try {
//       print('DriverRepository: Updating driver status with data: $data');
//
//       // ✅ METHOD 1: Try to get from AuthController (if available)
//       int? driverId = await _getDriverIdFromAuth();
//
//       // ✅ METHOD 2: Fallback to profile API if AuthController fails
//       if (driverId == null) {
//         driverId = await _getDriverIdFromProfile();
//       }
//
//       if (driverId == null) {
//         return Result.failure('Driver ID not found. Please login again.');
//       }
//
//       print('DriverRepository: Using driver ID: $driverId');
//
//       // ✅ Call provider with correct signature
//       final result = await _driverProvider.updateDriverStatus(driverId, data);
//
//       if (result.isSuccess) {
//         print('DriverRepository: Status updated successfully');
//         return Result.success(result.data ?? {});
//       } else {
//         print('DriverRepository: Status update failed: ${result.errorMessage}');
//         return Result.failure(result.errorMessage ?? 'Failed to update status');
//       }
//     } catch (e) {
//       print('DriverRepository: Exception in updateDriverStatus: $e');
//       return Result.failure('Failed to update driver status: ${e.toString()}');
//     }
//   }
//
//   // ✅ METHOD 1: Get driver ID dari AuthController (menggunakan Get.find)
//   Future<int?> _getDriverIdFromAuth() async {
//     try {
//       // ✅ Check if AuthController is registered
//       if (Get.isRegistered<AuthController>()) {
//         final authController = Get.find<AuthController>();
//
//         // ✅ Try to get driver data from AuthController
//         final driverData = authController.driverData;
//         if (driverData != null && driverData['id'] != null) {
//           final driverId = driverData['id'] as int;
//           print(
//               'DriverRepository: Found driver ID from AuthController: $driverId');
//           return driverId;
//         }
//
//         // ✅ Alternative: Try to get from currentUser if driver data not available
//         final currentUser = authController.currentUser;
//         if (currentUser != null) {
//           // If user has driver role, try to get driver ID from other sources
//           print(
//               'DriverRepository: User found but no driver data, trying profile API...');
//           return null; // Will fallback to profile API
//         }
//       } else {
//         print(
//             'DriverRepository: AuthController not registered, trying profile API...');
//         return null; // Will fallback to profile API
//       }
//     } catch (e) {
//       print(
//           'DriverRepository: Error getting driver ID from AuthController: $e');
//       return null; // Will fallback to profile API
//     }
//
//     return null;
//   }
//
//   // ✅ METHOD 2: Get driver ID dari profile API (fallback)
//   Future<int?> _getDriverIdFromProfile() async {
//     try {
//       print('DriverRepository: Getting driver ID from profile API...');
//
//       final profileResult = await getDriverProfile();
//       if (profileResult.isSuccess && profileResult.data != null) {
//         final profileData = profileResult.data!;
//
//         // ✅ Try different response structures
//         // Structure 1: { "driver": { "id": 123 } }
//         if (profileData.containsKey('driver') &&
//             profileData['driver'] is Map<String, dynamic> &&
//             profileData['driver']['id'] != null) {
//           final driverId = profileData['driver']['id'] as int;
//           print('DriverRepository: Found driver ID in driver field: $driverId');
//           return driverId;
//         }
//
//         // Structure 2: { "data": { "driver": { "id": 123 } } }
//         if (profileData.containsKey('data') &&
//             profileData['data'] is Map<String, dynamic>) {
//           final data = profileData['data'] as Map<String, dynamic>;
//           if (data.containsKey('driver') &&
//               data['driver'] is Map<String, dynamic> &&
//               data['driver']['id'] != null) {
//             final driverId = data['driver']['id'] as int;
//             print(
//                 'DriverRepository: Found driver ID in data.driver field: $driverId');
//             return driverId;
//           }
//         }
//
//         print('DriverRepository: Could not find driver ID in profile response');
//         return null;
//       } else {
//         print(
//             'DriverRepository: Failed to get profile: ${profileResult.errorMessage}');
//         return null;
//       }
//     } catch (e) {
//       print('DriverRepository: Error getting driver ID from profile: $e');
//       return null;
//     }
//   }
//
//   // ✅ ADD: isValidStatusTransition method
//   bool isValidStatusTransition(String currentStatus, String targetStatus) {
//     return DriverStatusConstants.canTransitionDriverStatus(
//         currentStatus, targetStatus);
//   }
//
//   Future<Result<Map<String, dynamic>>> updateDriverLocation(
//     int driverId,
//     double latitude,
//     double longitude,
//   ) async {
//     return await _driverProvider.updateDriverLocation(
//         driverId, latitude, longitude);
//   }
//
//   Future<Result<Map<String, dynamic>>> getDriverProfile() async {
//     return await _driverProvider.getDriverProfile();
//   }
//
//   Future<Result<Map<String, dynamic>>> updateDriverProfile(
//     Map<String, dynamic> data,
//   ) async {
//     try {
//       final result = await _driverProvider.updateDriverProfile(data);
//
//       if (result.isSuccess && result.data != null) {
//         return Result.success(result.data!);
//       } else {
//         return Result.failure(
//             result.errorMessage ?? 'Failed to update driver profile');
//       }
//     } catch (e) {
//       return Result.failure(e.toString());
//     }
//   }
//
//   Future<Result<List<DriverRequestModel>>> getDriverRequests({
//     Map<String, dynamic>? params,
//   }) async {
//     try {
//       final result = await _driverProvider.getDriverRequests(params: params);
//
//       if (result.isSuccess && result.data != null) {
//         final data = result.data!['data']?['requests'] as List? ??
//             result.data!['requests'] as List? ??
//             [];
//         final requests =
//             data.map((json) => DriverRequestModel.fromJson(json)).toList();
//         return Result.success(requests);
//       } else {
//         return Result.failure(
//             result.errorMessage ?? 'Failed to fetch driver requests');
//       }
//     } catch (e) {
//       return Result.failure(e.toString());
//     }
//   }
//
//   Future<Result<DriverRequestModel>> getDriverRequestById(int requestId) async {
//     try {
//       final result = await _driverProvider.getDriverRequestById(requestId);
//
//       if (result.isSuccess && result.data != null) {
//         final requestData =
//             result.data!['data'] as Map<String, dynamic>? ?? result.data!;
//         final request = DriverRequestModel.fromJson(requestData);
//         return Result.success(request);
//       } else {
//         return Result.failure(
//             result.errorMessage ?? 'Driver request not found');
//       }
//     } catch (e) {
//       return Result.failure(e.toString());
//     }
//   }
//
//   Future<Result<DriverRequestModel>> respondToDriverRequest(
//     int requestId,
//     String action,
//   ) async {
//     try {
//       final result =
//           await _driverProvider.respondToDriverRequest(requestId, action);
//
//       if (result.isSuccess && result.data != null) {
//         final requestData =
//             result.data!['data'] as Map<String, dynamic>? ?? result.data!;
//         final request = DriverRequestModel.fromJson(requestData);
//         return Result.success(request);
//       } else {
//         return Result.failure(
//             result.errorMessage ?? 'Failed to respond to driver request');
//       }
//     } catch (e) {
//       return Result.failure(e.toString());
//     }
//   }
//
//   // ✅ ADD: Additional helper methods
//   List<String> getValidStatusTransitions(String currentStatus) {
//     return DriverStatusConstants.getAvailableDriverStatusTransitions(
//         currentStatus);
//   }
//
//   bool canChangeStatusTo(String currentStatus, String targetStatus) {
//     return isValidStatusTransition(currentStatus, targetStatus);
//   }
//
//   String getStatusDisplayName(String status) {
//     return DriverStatusConstants.getDriverStatusName(status);
//   }
//
//   // ✅ BONUS: Method untuk update location yang otomatis cari driver ID
//   Future<Result<Map<String, dynamic>>> updateCurrentDriverLocation(
//     double latitude,
//     double longitude,
//   ) async {
//     try {
//       // Try AuthController first, then profile API
//       int? driverId = await _getDriverIdFromAuth();
//       driverId ??= await _getDriverIdFromProfile();
//
//       if (driverId == null) {
//         return Result.failure(
//             'Driver ID not found. Please ensure you are logged in as a driver.');
//       }
//
//       return await updateDriverLocation(driverId, latitude, longitude);
//     } catch (e) {
//       return Result.failure('Failed to update location: ${e.toString()}');
//     }
//   }
// }
