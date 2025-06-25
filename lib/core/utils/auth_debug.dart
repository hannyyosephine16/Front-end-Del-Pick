// lib/core/utils/auth_debug.dart - FIXED VERSION
import 'package:get/get.dart';
import 'package:del_pick/data/datasources/local/auth_local_datasource.dart';
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:flutter/foundation.dart';

class AuthDebug {
  /// Print current authentication state untuk debugging
  static Future<void> printCurrentAuthState() async {
    try {
      if (!Get.isRegistered<AuthLocalDataSource>()) {
        print('\n❌ === AUTH DEBUG ERROR ===');
        print('AuthLocalDataSource not registered in GetX');
        print('=== END AUTH DEBUG ===\n');
        return;
      }

      final authDataSource = Get.find<AuthLocalDataSource>();

      print('\n🔐 === AUTH DEBUG INFO ===');

      // Check login status using hasValidToken
      final isLoggedIn = await authDataSource.hasValidToken();
      print('Is Logged In: $isLoggedIn');

      // Check auth token
      final token = await authDataSource.getAuthToken();
      if (token != null && token.isNotEmpty) {
        print('Token Status: ✅ Available');
        print('Token Length: ${token.length}');
        print(
            'Token Preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');

        // Validate token format (JWT should have 3 parts separated by dots)
        final tokenParts = token.split('.');
        if (tokenParts.length == 3) {
          print('Token Format: ✅ Valid JWT format (3 parts)');
        } else {
          print(
              'Token Format: ❌ Invalid JWT format (${tokenParts.length} parts)');
        }

        // Check if Bearer prefix is included (shouldn't be stored with Bearer prefix)
        if (token.startsWith('Bearer ')) {
          print('Token Storage: ⚠️ WARNING - Token stored with Bearer prefix');
        } else {
          print('Token Storage: ✅ Clean token (no Bearer prefix)');
        }
      } else {
        print('Token Status: ❌ NULL OR EMPTY');
      }

      // ✅ FIXED: getUser() returns UserModel, not Map<String, dynamic>
      final user = await authDataSource.getUser();
      if (user != null) {
        print('User Status: ✅ Available');
        print('User ID: ${user.id}');
        print('User Name: ${user.name}');
        print('User Email: ${user.email}');
        print('User Role: ${user.role}');

        // Validate role for different apps
        if (user.role == 'driver') {
          print('Role Check: ✅ Valid driver role');
        } else if (user.role == 'customer') {
          print('Role Check: ✅ Valid customer role');
        } else if (user.role == 'store') {
          print('Role Check: ✅ Valid store role');
        } else {
          print('Role Check: ⚠️ WARNING - Unknown role (${user.role})');
        }
      } else {
        print('User Status: ❌ NULL');
      }

      // Check ApiService auth token
      if (Get.isRegistered<ApiService>()) {
        final apiService = Get.find<ApiService>();
        final apiToken = apiService.getAuthToken();
        if (apiToken != null) {
          print('ApiService Token: ✅ Set (${apiToken.substring(0, 20)}...)');

          // Compare tokens
          if (token == apiToken) {
            print(
                'Token Sync: ✅ AuthLocalDataSource and ApiService tokens match');
          } else {
            print('Token Sync: ⚠️ WARNING - Tokens do not match');
          }
        } else {
          print('ApiService Token: ❌ Not set in ApiService');
        }
      }

      print('=== END AUTH DEBUG ===\n');
    } catch (e) {
      print('\n❌ === AUTH DEBUG ERROR ===');
      print('Error in auth debug: $e');
      print('=== END AUTH DEBUG ===\n');
    }
  }

  /// Test API call with current auth token
  static Future<void> testAuthToken() async {
    try {
      print('\n🧪 === AUTH TOKEN TEST ===');

      if (!Get.isRegistered<ApiService>()) {
        print('❌ ApiService not registered');
        print('=== END TOKEN TEST ===\n');
        return;
      }

      final apiService = Get.find<ApiService>();

      // Test dengan endpoint auth profile
      try {
        print('Testing GET /auth/profile...');
        final response = await apiService.get('/auth/profile');

        if (response.statusCode == 200) {
          print('✅ Auth token test PASSED');
          print('Status: ${response.statusCode}');
          print('Response data available: ${response.data != null}');

          if (response.data != null && response.data['data'] != null) {
            final userData = response.data['data'];
            print('User from API: ${userData['name']} (${userData['role']})');
          }
        } else {
          print('⚠️ Auth token test FAILED');
          print('Status: ${response.statusCode}');
          print('Message: ${response.data?['message'] ?? 'Unknown error'}');
        }
      } catch (e) {
        print('❌ Auth token test ERROR: $e');

        // Parse specific errors
        if (e.toString().contains('401')) {
          print('Error type: Authentication failed - Invalid or expired token');
        } else if (e.toString().contains('403')) {
          print('Error type: Access denied - Insufficient permissions');
        } else if (e.toString().contains('404')) {
          print('Error type: Endpoint not found');
        } else {
          print('Error type: Network or other error');
        }
      }

      print('=== END TOKEN TEST ===\n');
    } catch (e) {
      print('\n❌ === TOKEN TEST ERROR ===');
      print('Error testing token: $e');
      print('=== END TOKEN TEST ===\n');
    }
  }

  /// Sync auth token to ApiService
  static Future<void> syncAuthToken() async {
    try {
      print('\n🔄 === SYNCING AUTH TOKEN ===');

      final authDataSource = Get.find<AuthLocalDataSource>();
      final apiService = Get.find<ApiService>();

      final token = await authDataSource.getAuthToken();

      if (token != null && token.isNotEmpty) {
        apiService.setAuthToken(token);
        print('✅ Auth token synced to ApiService');

        // Verify sync
        final apiToken = apiService.getAuthToken();
        if (token == apiToken) {
          print('✅ Token sync verified');
        } else {
          print('❌ Token sync failed - mismatch');
        }
      } else {
        apiService.clearAuthToken();
        print('⚠️ No token available - cleared ApiService token');
      }

      print('=== END SYNC AUTH ===\n');
    } catch (e) {
      print('\n❌ === SYNC AUTH ERROR ===');
      print('Error syncing auth token: $e');
      print('=== END SYNC AUTH ===\n');
    }
  }

  /// Clear auth data untuk fresh start
  static Future<void> clearAuthData() async {
    try {
      print('\n🔄 === CLEARING AUTH DATA ===');

      final authDataSource = Get.find<AuthLocalDataSource>();
      final apiService = Get.find<ApiService>();

      // Clear dari local storage
      await authDataSource.clearAuthData();

      // Clear dari ApiService
      apiService.clearAuthToken();

      print('✅ Auth data cleared successfully');
      print('=== END CLEAR AUTH ===\n');
    } catch (e) {
      print('\n❌ === CLEAR AUTH ERROR ===');
      print('Error clearing auth data: $e');
      print('=== END CLEAR AUTH ===\n');
    }
  }

  /// Validate auth setup untuk semua role
  static Future<bool> validateAuth({String? expectedRole}) async {
    try {
      print('\n✅ === AUTH VALIDATION ===');

      final authDataSource = Get.find<AuthLocalDataSource>();

      // Check if logged in
      final isLoggedIn = await authDataSource.hasValidToken();
      if (!isLoggedIn) {
        print('❌ Not logged in');
        return false;
      }

      // Check token
      final token = await authDataSource.getAuthToken();
      if (token == null || token.isEmpty) {
        print('❌ No auth token');
        return false;
      }

      // ✅ FIXED: Check user data using UserModel
      final user = await authDataSource.getUser();
      if (user == null) {
        print('❌ No user data');
        return false;
      }

      if (expectedRole != null && user.role != expectedRole) {
        print('❌ Invalid role: ${user.role} (expected: $expectedRole)');
        return false;
      }

      // Check ApiService token sync
      if (Get.isRegistered<ApiService>()) {
        final apiService = Get.find<ApiService>();
        final apiToken = apiService.getAuthToken();
        if (apiToken == null || apiToken != token) {
          print('⚠️ WARNING - ApiService token not synced');
          // Auto-sync
          apiService.setAuthToken(token);
          print('✅ Auto-synced token to ApiService');
        }
      }

      print('✅ Auth validation passed');
      print('User: ${user.name} (${user.role})');
      print('=== END VALIDATION ===\n');
      return true;
    } catch (e) {
      print('\n❌ === VALIDATION ERROR ===');
      print('Error validating auth: $e');
      print('=== END VALIDATION ===\n');
      return false;
    }
  }

  /// Specific validation for driver
  static Future<bool> validateDriverAuth() async {
    return validateAuth(expectedRole: 'driver');
  }

  /// Specific validation for customer
  static Future<bool> validateCustomerAuth() async {
    return validateAuth(expectedRole: 'customer');
  }

  /// Specific validation for store
  static Future<bool> validateStoreAuth() async {
    return validateAuth(expectedRole: 'store');
  }

  /// Get current API headers for debugging
  static Future<void> printApiHeaders() async {
    try {
      print('\n📡 === API HEADERS DEBUG ===');

      if (!Get.isRegistered<ApiService>()) {
        print('❌ ApiService not registered');
        print('=== END HEADERS DEBUG ===\n');
        return;
      }

      final apiService = Get.find<ApiService>();
      final headers = apiService.dio.options.headers;

      print('Current API Headers:');
      headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization') {
          // Mask token for security
          if (value.toString().startsWith('Bearer ')) {
            final token = value.toString().substring(7);
            print('$key: Bearer ${token.substring(0, 20)}...');
          } else {
            print('$key: ${value.toString().substring(0, 20)}...');
          }
        } else {
          print('$key: $value');
        }
      });

      print('=== END HEADERS DEBUG ===\n');
    } catch (e) {
      print('\n❌ === HEADERS DEBUG ERROR ===');
      print('Error getting API headers: $e');
      print('=== END HEADERS DEBUG ===\n');
    }
  }

  /// Test login with credentials
  static Future<void> testLogin(String email, String password) async {
    try {
      print('\n🧪 === LOGIN TEST ===');
      print('Testing login with email: $email');

      if (!Get.isRegistered<ApiService>()) {
        print('❌ ApiService not registered');
        return;
      }

      final apiService = Get.find<ApiService>();

      final response = await apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      print('Response Status: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null && data['token'] != null && data['user'] != null) {
          print('✅ Login test successful');
          print('Token received: ${data['token'].substring(0, 20)}...');
          print('User: ${data['user']['name']} (${data['user']['role']})');
        } else {
          print('❌ Login test failed - invalid response structure');
        }
      } else {
        print('❌ Login test failed');
      }

      print('=== END LOGIN TEST ===\n');
    } catch (e) {
      print('\n❌ === LOGIN TEST ERROR ===');
      print('Error testing login: $e');
      print('=== END LOGIN TEST ===\n');
    }
  }

  /// Print GetX registration status
  static void printGetXStatus() {
    print('\n📋 === GETX REGISTRATION STATUS ===');

    final services = [
      'ApiService',
      'AuthLocalDataSource',
      'AuthRemoteDataSource',
      'AuthProvider',
      'AuthRepository',
      'AuthController',
    ];

    for (final service in services) {
      try {
        switch (service) {
          case 'ApiService':
            final isRegistered = Get.isRegistered<ApiService>();
            print('$service: ${isRegistered ? '✅' : '❌'}');
            break;
          case 'AuthLocalDataSource':
            final isRegistered = Get.isRegistered<AuthLocalDataSource>();
            print('$service: ${isRegistered ? '✅' : '❌'}');
            break;
          // Add other services as needed
          default:
            print('$service: ⚠️ Check manually');
        }
      } catch (e) {
        print('$service: ❌ Error checking');
      }
    }

    print('=== END GETX STATUS ===\n');
  }
}
