import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:get/get.dart' as getx;

class StoreProvider {
  final ApiService _apiService = getx.Get.find<ApiService>();

  Future<Response> getAllStores({Map<String, dynamic>? params}) async {
    try {
      print('StoreProvider: Making API call to ${ApiEndpoints.getAllStores}');
      print('StoreProvider: Params: $params');

      final response = await _apiService.get(
        ApiEndpoints.getAllStores,
        queryParameters: params,
      );

      print('StoreProvider: API Response Status: ${response.statusCode}');
      print('StoreProvider: API Response Headers: ${response.headers}');
      print(
          'StoreProvider: API Response Data Type: ${response.data.runtimeType}');
      print('StoreProvider: API Response Data: ${response.data}');

      // TAMBAHAN: Validasi response structure
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        print('StoreProvider: Response is Map with keys: ${data.keys}');

        if (data['data'] != null) {
          print('StoreProvider: data field type: ${data['data'].runtimeType}');
          if (data['data'] is Map && data['data']['stores'] != null) {
            print(
                'StoreProvider: stores field type: ${data['data']['stores'].runtimeType}');
            print(
                'StoreProvider: stores length: ${data['data']['stores'].length}');
          }
        }
      }

      return response;
    } catch (e) {
      print('StoreProvider: Error in getAllStores: $e');
      print('StoreProvider: Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<Response> getNearbyStores({
    required double latitude,
    required double longitude,
    Map<String, dynamic>? params,
  }) async {
    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        ...?params,
      };

      print('StoreProvider: Making API call for nearby stores');
      print('StoreProvider: Query params: $queryParams');

      final response = await _apiService.get(
        ApiEndpoints.getAllStores,
        queryParameters: queryParams,
      );

      print(
          'StoreProvider: Nearby API Response Status: ${response.statusCode}');
      print('StoreProvider: Nearby API Response Data: ${response.data}');

      return response;
    } catch (e) {
      print('StoreProvider: Error in getNearbyStores: $e');
      rethrow;
    }
  }

  Future<Response> getStoreDetail(int storeId) async {
    return await _apiService.get(ApiEndpoints.getStoreById(storeId));
  }
}
