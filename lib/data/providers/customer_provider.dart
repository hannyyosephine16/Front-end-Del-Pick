// lib/data/providers/customer_provider.dart - FIXED
import 'package:dio/dio.dart';
import 'package:del_pick/core/services/api/api_service.dart';
import 'package:del_pick/core/constants/api_endpoints.dart';
import 'package:get/get.dart' as getx;

class CustomerProvider {
  final ApiService _apiService = getx.Get.find<ApiService>();

  // GET /customers (admin only)
  Future<Response> getAllCustomers({Map<String, dynamic>? params}) async {
    return await _apiService.get(
      ApiEndpoints.getAllCustomers,
      queryParameters: params,
    );
  }

  // GET /customers/:id (admin only)
  Future<Response> getCustomerById(int customerId) async {
    return await _apiService.get(ApiEndpoints.getCustomerById(customerId));
  }

  //POST /customers (admin only)
  Future<Response> createCustomer(Map<String, dynamic> data) async {
    return await _apiService.post(ApiEndpoints.createCustomer, data: data);
  }

  //PUT /customers/:id (admin only)
  Future<Response> updateCustomer(
    int customerId,
    Map<String, dynamic> data,
  ) async {
    return await _apiService.put(
      ApiEndpoints.updateCustomer(customerId),
      data: data,
    );
  }

  // DELETE /customers/:id (admin only)
  Future<Response> deleteCustomer(int customerId) async {
    return await _apiService.delete(ApiEndpoints.deleteCustomer(customerId));
  }
}
