// lib/data/repositories/review_repository.dart
import 'package:del_pick/data/providers/review_provider.dart';
import 'package:del_pick/core/utils/result.dart';
import 'package:dio/dio.dart';
import '../../core/errors/error_handler.dart';

class ReviewRepository {
  final ReviewProvider _reviewProvider;

  ReviewRepository(this._reviewProvider);

  Future<Result<void>> createReview(
      int orderId, Map<String, dynamic> data) async {
    try {
      final response = await _reviewProvider.createReview(orderId, data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Result.success(null);
      } else {
        return Result.failure(
          response.data['message'] ?? 'Failed to create review',
        );
      }
    } on DioException catch (e) {
      final failure = ErrorHandler.handleException(e);
      return Result.failure(ErrorHandler.getErrorMessage(failure));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
