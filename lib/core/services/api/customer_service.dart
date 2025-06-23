// lib/core/services/api/customer_service.dart -> service ini sebenarnya digunakan oleh admin
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';

class CustomerApiService {
  final ApiService _apiService;

  CustomerApiService(this._apiService);

  Future<Response> getAllCustomers({Map<String, dynamic>? queryParams}) async {
    return await _apiService.get(
      ApiEndpoints.getAllCustomers,
      queryParameters: queryParams,
    );
  }

  Future<Response> getCustomerById(int customerId) async {
    return await _apiService.get(ApiEndpoints.getCustomerById(customerId));
  }

  Future<Response> createCustomer(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.createCustomer, data: data);
  }

  Future<Response> updateCustomer(
    int customerId,
    Map<String, dynamic> data,
  ) async {
    return await _apiService.put(
      ApiEndpoints.updateCustomer(customerId),
      data: data,
    );
  }

  Future<Response> deleteCustomer(int customerId) async {
    return await _apiService.delete(ApiEndpoints.deleteCustomer(customerId));
  }
}
