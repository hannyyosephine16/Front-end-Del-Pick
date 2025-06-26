// lib/data/models/auth/login_response_model.dart - SIMPLIFIED
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:flutter/foundation.dart';

class LoginResponseModel {
  final String token;
  final UserModel user;
  final DriverModel? driver;
  final StoreModel? store;

  LoginResponseModel({
    required this.token,
    required this.user,
    this.driver,
    this.store,
  });

  // ✅ DIRECT factory untuk handle backend response
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      if (kDebugMode) {
        debugPrint('🔍 LoginResponseModel.fromJson');
        debugPrint('📝 Input keys: ${json.keys.toList()}');
      }

      // ✅ Get token - handle both string and null
      final token = json['token']?.toString() ?? '';
      if (token.isEmpty) {
        throw const FormatException('Token is required but missing or empty');
      }

      // ✅ Get user data - required
      final userData = json['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw const FormatException('User data is required but missing');
      }

      final user = UserModel.fromJson(userData);

      if (kDebugMode) {
        debugPrint('✅ Token and user parsed successfully');
        debugPrint('📝 User role: ${user.role}');
        debugPrint('📝 Driver data available: ${json['driver'] != null}');
        debugPrint('📝 Store data available: ${json['store'] != null}');
      }

      // ✅ Parse optional driver data - only if user role is driver
      DriverModel? driver;
      if (user.role == 'driver' && json['driver'] != null) {
        try {
          final driverData = json['driver'] as Map<String, dynamic>;
          driver = DriverModel.fromJson(driverData);
          if (kDebugMode) {
            debugPrint('✅ Driver data parsed successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Failed to parse driver data: $e');
          }
          // Don't throw, just set to null
          driver = null;
        }
      }

      // ✅ Parse optional store data - only if user role is store
      StoreModel? store;
      if (user.role == 'store' && json['store'] != null) {
        try {
          final storeData = json['store'] as Map<String, dynamic>;
          store = StoreModel.fromJson(storeData);
          if (kDebugMode) {
            debugPrint('✅ Store data parsed successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Failed to parse store data: $e');
          }
          // Don't throw, just set to null
          store = null;
        }
      }

      final result = LoginResponseModel(
        token: token,
        user: user,
        driver: driver,
        store: store,
      );

      if (kDebugMode) {
        debugPrint('✅ LoginResponseModel created successfully');
        debugPrint('📝 Has driver: ${result.hasDriver}');
        debugPrint('📝 Has store: ${result.hasStore}');
        debugPrint('📝 Role validation: ${result.isValidForRole}');
      }

      return result;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error in LoginResponseModel.fromJson: $e');
        debugPrint('📝 StackTrace: $stackTrace');
        debugPrint('📝 Input data: $json');
      }
      throw FormatException('Failed to parse LoginResponseModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'token': token,
      'user': user.toJson(),
    };

    if (driver != null) {
      result['driver'] = driver!.toJson();
    }

    if (store != null) {
      result['store'] = store!.toJson();
    }

    return result;
  }

  // ✅ Helper getters
  bool get hasDriver => driver != null;
  bool get hasStore => store != null;

  String get userRole => user.role;
  bool get isCustomer => user.role == 'customer';
  bool get isDriver => user.role == 'driver';
  bool get isStore => user.role == 'store';

  // ✅ Validate that the login response has required data for the user's role
  bool get isValidForRole {
    switch (user.role) {
      case 'customer':
        return true; // Customer doesn't need additional data
      case 'driver':
        return true; // Driver data is optional in some cases
      case 'store':
        return true; // Store data is optional in some cases
      default:
        return false;
    }
  }

  String get displayName {
    if (isStore && hasStore) return store!.name;
    return user.name;
  }

  @override
  String toString() {
    return 'LoginResponseModel(token: ${token.substring(0, 20)}..., user: ${user.name}, role: ${user.role})';
  }
}
// // // lib/data/models/auth/login_response_model.dart - FINAL FIX
// // import 'package:del_pick/data/models/auth/user_model.dart';
// // import 'package:del_pick/data/models/driver/driver_model.dart';
// // import 'package:del_pick/data/models/store/store_model.dart';
// // import 'package:del_pick/core/utils/parsing_helper.dart';
// // import 'package:flutter/foundation.dart';
// //
// // class LoginResponseModel {
// //   final String token;
// //   final UserModel user;
// //   final DriverModel? driver;
// //   final StoreModel? store;
// //
// //   LoginResponseModel({
// //     required this.token,
// //     required this.user,
// //     this.driver,
// //     this.store,
// //   });
// //
// //   // ✅ ROBUST Factory untuk backend DelPick response format
// //   factory LoginResponseModel.fromBackendResponse(Map<String, dynamic> json) {
// //     try {
// //       if (kDebugMode) {
// //         debugPrint('🔍 LoginResponseModel.fromBackendResponse');
// //         debugPrint('📝 Input keys: ${json.keys.toList()}');
// //       }
// //
// //       // Ambil token dengan safe parsing
// //       final token = ParsingHelper.parseStringWithDefault(json['token'], '');
// //       if (token.isEmpty) {
// //         throw const FormatException('Token is required but missing');
// //       }
// //
// //       // Ambil user data dengan safe parsing
// //       final userData = json['user'] as Map<String, dynamic>?;
// //       if (userData == null) {
// //         throw const FormatException('User data is required but missing');
// //       }
// //
// //       final user = UserModel.fromJson(userData);
// //
// //       if (kDebugMode) {
// //         debugPrint('✅ Token and user parsed successfully');
// //         debugPrint('📝 User role: ${user.role}');
// //       }
// //
// //       // Parse optional driver data
// //       DriverModel? driver;
// //       if (json.containsKey('driver') && json['driver'] != null) {
// //         try {
// //           final driverData = json['driver'] as Map<String, dynamic>;
// //           driver = DriverModel.fromJson(driverData);
// //           if (kDebugMode) {
// //             debugPrint('✅ Driver data parsed successfully');
// //           }
// //         } catch (e) {
// //           if (kDebugMode) {
// //             debugPrint('⚠️ Failed to parse driver data: $e');
// //           }
// //           // Don't throw, just set to null
// //           driver = null;
// //         }
// //       }
// //
// //       // Parse optional store data
// //       StoreModel? store;
// //       if (json.containsKey('store') && json['store'] != null) {
// //         try {
// //           final storeData = json['store'] as Map<String, dynamic>;
// //           store = StoreModel.fromJson(storeData);
// //           if (kDebugMode) {
// //             debugPrint('✅ Store data parsed successfully');
// //           }
// //         } catch (e) {
// //           if (kDebugMode) {
// //             debugPrint('⚠️ Failed to parse store data: $e');
// //           }
// //           // Don't throw, just set to null
// //           store = null;
// //         }
// //       }
// //
// //       final result = LoginResponseModel(
// //         token: token,
// //         user: user,
// //         driver: driver,
// //         store: store,
// //       );
// //
// //       if (kDebugMode) {
// //         debugPrint('✅ LoginResponseModel created successfully');
// //         debugPrint('📝 Has driver: ${result.hasDriver}');
// //         debugPrint('📝 Has store: ${result.hasStore}');
// //       }
// //
// //       return result;
// //     } catch (e, stackTrace) {
// //       if (kDebugMode) {
// //         debugPrint('❌ Error in LoginResponseModel.fromBackendResponse: $e');
// //         debugPrint('📝 StackTrace: $stackTrace');
// //         debugPrint('📝 Input data: $json');
// //       }
// //       throw FormatException('Failed to parse LoginResponseModel: $e');
// //     }
// //   }
// //
// //   // ✅ Alternative factory untuk kompatibilitas
// //   factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
// //     return LoginResponseModel.fromBackendResponse(json);
// //   }
// //
// //   // ✅ SAFE toJson dengan null checks
// //   Map<String, dynamic> toJson() {
// //     final result = <String, dynamic>{
// //       'token': token,
// //       'user': user.toJson(),
// //     };
// //
// //     if (driver != null) {
// //       result['driver'] = driver!.toJson();
// //     }
// //
// //     if (store != null) {
// //       result['store'] = store!.toJson();
// //     }
// //
// //     return result;
// //   }
// //
// //   // ✅ Helper getters
// //   bool get hasDriver => driver != null;
// //   bool get hasStore => store != null;
// //
// //   String get userRole => user.role;
// //   bool get isCustomer => user.role == 'customer';
// //   bool get isDriver => user.role == 'driver';
// //   bool get isStore => user.role == 'store';
// //
// //   /// Returns the appropriate role-specific data
// //   Map<String, dynamic>? get roleSpecificData {
// //     if (isDriver && hasDriver) return driver!.toJson();
// //     if (isStore && hasStore) return store!.toJson();
// //     return null;
// //   }
// //
// //   /// Returns display name based on role
// //   String get displayName {
// //     if (isStore && hasStore) return store!.name;
// //     return user.name;
// //   }
// //
// //   /// Returns phone number from role-specific data if available
// //   String? get phone {
// //     if (isStore && hasStore) return store!.phone;
// //     if (isDriver) return user.phone; // Driver phone is in user data
// //     return user.phone;
// //   }
// //
// //   /// Returns phone number with fallback to empty string
// //   String get phoneOrEmpty => phone ?? '';
// //
// //   /// Returns phone number with custom fallback
// //   String phoneWithFallback(String fallback) => phone ?? fallback;
// //
// //   /// Validate that the login response has required data for the user's role
// //   bool get isValidForRole {
// //     switch (user.role) {
// //       case 'customer':
// //         return true; // Customer doesn't need additional data
// //       case 'driver':
// //         return hasDriver; // Driver needs driver data
// //       case 'store':
// //         return hasStore; // Store needs store data
// //       default:
// //         return false;
// //     }
// //   }
// //
// //   /// Get role-specific ID
// //   int? get roleSpecificId {
// //     if (isDriver && hasDriver) return driver!.id;
// //     if (isStore && hasStore) return store!.id;
// //     return null;
// //   }
// //
// //   /// Copy with method for updates
// //   LoginResponseModel copyWith({
// //     String? token,
// //     UserModel? user,
// //     DriverModel? driver,
// //     StoreModel? store,
// //   }) {
// //     return LoginResponseModel(
// //       token: token ?? this.token,
// //       user: user ?? this.user,
// //       driver: driver ?? this.driver,
// //       store: store ?? this.store,
// //     );
// //   }
// //
// //   @override
// //   String toString() {
// //     return 'LoginResponseModel(token: ${token.substring(0, 20)}..., user: ${user.name}, role: ${user.role})';
// //   }
// //
// //   @override
// //   bool operator ==(Object other) =>
// //       identical(this, other) ||
// //       other is LoginResponseModel &&
// //           runtimeType == other.runtimeType &&
// //           token == other.token &&
// //           user == other.user &&
// //           driver == other.driver &&
// //           store == other.store;
// //
// //   @override
// //   int get hashCode =>
// //       token.hashCode ^ user.hashCode ^ driver.hashCode ^ store.hashCode;
// // }
// // lib/data/models/auth/login_response_model.dart - FINAL FIX
// import 'package:del_pick/data/models/auth/user_model.dart';
// import 'package:del_pick/data/models/driver/driver_model.dart';
// import 'package:del_pick/data/models/store/store_model.dart';
// import 'package:del_pick/core/utils/parsing_helper.dart';
// import 'package:flutter/foundation.dart';
//
// class LoginResponseModel {
//   final String token;
//   final UserModel user;
//   final DriverModel? driver;
//   final StoreModel? store;
//
//   LoginResponseModel({
//     required this.token,
//     required this.user,
//     this.driver,
//     this.store,
//   });
//
//   // ✅ ROBUST Factory untuk backend DelPick response format
//   factory LoginResponseModel.fromBackendResponse(Map<String, dynamic> json) {
//     try {
//       if (kDebugMode) {
//         debugPrint('🔍 LoginResponseModel.fromBackendResponse');
//         debugPrint('📝 Input keys: ${json.keys.toList()}');
//       }
//
//       // Ambil token dengan safe parsing
//       final token = json['token']?.toString() ?? '';
//       if (token.isEmpty) {
//         throw const FormatException('Token is required but missing');
//       }
//
//       // Ambil user data dengan safe parsing
//       final userData = json['user'] as Map<String, dynamic>?;
//       if (userData == null) {
//         throw const FormatException('User data is required but missing');
//       }
//
//       final user = UserModel.fromJson(userData);
//
//       if (kDebugMode) {
//         debugPrint('✅ Token and user parsed successfully');
//         debugPrint('📝 User role: ${user.role}');
//       }
//
//       // Parse optional driver data
//       DriverModel? driver;
//       if (json.containsKey('driver') && json['driver'] != null) {
//         try {
//           final driverData = json['driver'] as Map<String, dynamic>;
//           driver = DriverModel.fromJson(driverData);
//           if (kDebugMode) {
//             debugPrint('✅ Driver data parsed successfully');
//           }
//         } catch (e) {
//           if (kDebugMode) {
//             debugPrint('⚠️ Failed to parse driver data: $e');
//           }
//           // Don't throw, just set to null
//           driver = null;
//         }
//       }
//
//       // Parse optional store data
//       StoreModel? store;
//       if (json.containsKey('store') && json['store'] != null) {
//         try {
//           final storeData = json['store'] as Map<String, dynamic>;
//           store = StoreModel.fromJson(storeData);
//           if (kDebugMode) {
//             debugPrint('✅ Store data parsed successfully');
//           }
//         } catch (e) {
//           if (kDebugMode) {
//             debugPrint('⚠️ Failed to parse store data: $e');
//           }
//           // Don't throw, just set to null
//           store = null;
//         }
//       }
//
//       final result = LoginResponseModel(
//         token: token,
//         user: user,
//         driver: driver,
//         store: store,
//       );
//
//       if (kDebugMode) {
//         debugPrint('✅ LoginResponseModel created successfully');
//         debugPrint('📝 Has driver: ${result.hasDriver}');
//         debugPrint('📝 Has store: ${result.hasStore}');
//       }
//
//       return result;
//     } catch (e, stackTrace) {
//       if (kDebugMode) {
//         debugPrint('❌ Error in LoginResponseModel.fromBackendResponse: $e');
//         debugPrint('📝 StackTrace: $stackTrace');
//         debugPrint('📝 Input data: $json');
//       }
//       throw FormatException('Failed to parse LoginResponseModel: $e');
//     }
//   }
//
//   // ✅ Alternative factory untuk kompatibilitas
//   factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
//     return LoginResponseModel.fromBackendResponse(json);
//   }
//
//   // ✅ SAFE toJson dengan null checks
//   Map<String, dynamic> toJson() {
//     final result = <String, dynamic>{
//       'token': token,
//       'user': user.toJson(),
//     };
//
//     if (driver != null) {
//       result['driver'] = driver!.toJson();
//     }
//
//     if (store != null) {
//       result['store'] = store!.toJson();
//     }
//
//     return result;
//   }
//
//   // ✅ Helper getters
//   bool get hasDriver => driver != null;
//   bool get hasStore => store != null;
//
//   String get userRole => user.role;
//   bool get isCustomer => user.role == 'customer';
//   bool get isDriver => user.role == 'driver';
//   bool get isStore => user.role == 'store';
//
//   /// Returns the appropriate role-specific data
//   Map<String, dynamic>? get roleSpecificData {
//     if (isDriver && hasDriver) return driver!.toJson();
//     if (isStore && hasStore) return store!.toJson();
//     return null;
//   }
//
//   /// Returns display name based on role
//   String get displayName {
//     if (isStore && hasStore) return store!.name;
//     return user.name;
//   }
//
//   /// Returns phone number from role-specific data if available
//   String? get phone {
//     if (isStore && hasStore) return store!.phone;
//     if (isDriver) return user.phone; // Driver phone is in user data
//     return user.phone;
//   }
//
//   /// Returns phone number with fallback to empty string
//   String get phoneOrEmpty => phone ?? '';
//
//   /// Returns phone number with custom fallback
//   String phoneWithFallback(String fallback) => phone ?? fallback;
//
//   /// Validate that the login response has required data for the user's role
//   bool get isValidForRole {
//     switch (user.role) {
//       case 'customer':
//         return true; // Customer doesn't need additional data
//       case 'driver':
//         return hasDriver; // Driver needs driver data
//       case 'store':
//         return hasStore; // Store needs store data
//       default:
//         return false;
//     }
//   }
//
//   /// Get role-specific ID
//   int? get roleSpecificId {
//     if (isDriver && hasDriver) return driver!.id;
//     if (isStore && hasStore) return store!.id;
//     return null;
//   }
//
//   /// Copy with method for updates
//   LoginResponseModel copyWith({
//     String? token,
//     UserModel? user,
//     DriverModel? driver,
//     StoreModel? store,
//   }) {
//     return LoginResponseModel(
//       token: token ?? this.token,
//       user: user ?? this.user,
//       driver: driver ?? this.driver,
//       store: store ?? this.store,
//     );
//   }
//
//   @override
//   String toString() {
//     return 'LoginResponseModel(token: ${token.substring(0, 20)}..., user: ${user.name}, role: ${user.role})';
//   }
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is LoginResponseModel &&
//           runtimeType == other.runtimeType &&
//           token == other.token &&
//           user == other.user &&
//           driver == other.driver &&
//           store == other.store;
//
//   @override
//   int get hashCode =>
//       token.hashCode ^ user.hashCode ^ driver.hashCode ^ store.hashCode;
// }
