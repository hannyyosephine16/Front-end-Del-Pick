import 'package:del_pick/data/datasources/remote/store_remote_datasource.dart';
import 'package:del_pick/data/models/store/store_model.dart';
import 'package:del_pick/data/models/base/paginated_response.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:del_pick/core/errors/exceptions.dart';
import 'package:dio/dio.dart';

class StoreRepository {
  final StoreRemoteDataSource _remoteDataSource;

  StoreRepository(this._remoteDataSource);

  Future<Result<List<StoreModel>>> getAllStores({
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _remoteDataSource.getAllStores(params: params);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;

        final stores = (data['stores'] as List? ?? data as List? ?? [])
            .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return Result.success(stores);
      } else {
        return Result.failure(response.data['message'] ?? 'Failed to fetch stores');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<List<StoreModel>>> getNearbyStores({
    required double latitude,
    required double longitude,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getNearbyStores(
        latitude: latitude,
        longitude: longitude,
        params: {'limit': limit.toString()},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;

        final stores = (data['stores'] as List? ?? data as List? ?? [])
            .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return Result.success(stores);
      } else {
        return Result.failure(response.data['message'] ?? 'Failed to fetch nearby stores');
      }
    } on DioException catch (e) {
      return Result.failure(_handleDioError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  String _handleDioError(DioException e) {
    final response = e.response;
    if (response?.data is Map<String, dynamic>) {
      return response!.data['message'] ?? 'Network error occurred';
    }
    return 'Network error occurred';
  }
}