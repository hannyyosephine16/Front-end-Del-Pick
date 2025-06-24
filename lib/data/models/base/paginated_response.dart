import 'package:dio/dio.dart';
import 'package:del_pick/core/utils/parsing_helper.dart';
import 'package:del_pick/core/utils/response_parser.dart';

/// ✅ UPDATED: PaginatedResponse yang menggunakan ResponseParser
class PaginatedResponse<T> {
  final List<T> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;

  PaginatedResponse({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  /// ✅ UPDATED: Menggunakan ResponseParser untuk parsing yang konsisten
  factory PaginatedResponse.fromResponse(
    Response response,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final parsed = ResponseParser.parseSuccessResponse(response);
    final data = parsed['data'];
    final pagination = ResponseParser.extractPaginationInfo(parsed);

    List<T> items = [];
    int totalItems = 0;
    int totalPages = 1;
    int currentPage = 1;

    // Handle pagination info
    if (pagination != null) {
      totalItems = pagination.totalItems ?? 0;
      totalPages = pagination.totalPages ?? 1;
      currentPage = pagination.currentPage ?? 1;
    }

    // Parse items
    if (data is List) {
      // Direct array
      items = data.map<T>((item) {
        if (item is Map<String, dynamic>) {
          return fromJsonT(item);
        }
        throw FormatException('Invalid item format in list');
      }).toList();

      // If no pagination info, use array length
      if (pagination == null) {
        totalItems = items.length;
      }
    } else if (data is Map<String, dynamic>) {
      // Single item
      items = [fromJsonT(data)];
      if (pagination == null) {
        totalItems = 1;
      }
    }

    return PaginatedResponse<T>(
      items: items,
      totalItems: totalItems,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  /// ✅ Legacy factory for backward compatibility
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
    String itemsKey,
  ) {
    List<dynamic> itemsData = [];
    int totalItems = 0;
    int totalPages = 1;
    int currentPage = 1;

    // Handle different backend response structures safely
    if (json.containsKey('data')) {
      final data = json['data'];

      if (data is Map<String, dynamic>) {
        // Case 1: { data: { orders: [...], totalItems: ..., totalPages: ..., currentPage: ... } }
        if (data.containsKey(itemsKey) && data[itemsKey] is List) {
          itemsData = data[itemsKey] as List<dynamic>;
          totalItems = ParsingHelper.parseIntWithDefault(
              data['totalItems'], itemsData.length);
          totalPages = ParsingHelper.parseIntWithDefault(data['totalPages'], 1);
          currentPage =
              ParsingHelper.parseIntWithDefault(data['currentPage'], 1);
        }
        // Case 2: { data: { totalItems: ..., orders: [...] } } - Different order
        else if (data.containsKey('totalItems')) {
          // Look for any list in the data
          for (final key in data.keys) {
            if (data[key] is List) {
              itemsData = data[key] as List<dynamic>;
              break;
            }
          }
          totalItems = ParsingHelper.parseIntWithDefault(
              data['totalItems'], itemsData.length);
          totalPages = ParsingHelper.parseIntWithDefault(data['totalPages'], 1);
          currentPage =
              ParsingHelper.parseIntWithDefault(data['currentPage'], 1);
        }
        // Case 3: { data: some_object } - No pagination, treat as single item
        else {
          itemsData = [data];
          totalItems = 1;
          totalPages = 1;
          currentPage = 1;
        }
      } else if (data is List) {
        // Case 4: { data: [...] } - Direct array
        itemsData = data;
        totalItems = itemsData.length;
        totalPages = 1;
        currentPage = 1;
      }
    }
    // Case 5: Root level pagination (for backward compatibility)
    else if (json.containsKey(itemsKey) && json[itemsKey] is List) {
      itemsData = json[itemsKey] as List<dynamic>;
      totalItems = ParsingHelper.parseIntWithDefault(
          json['totalItems'], itemsData.length);
      totalPages = ParsingHelper.parseIntWithDefault(json['totalPages'], 1);
      currentPage = ParsingHelper.parseIntWithDefault(json['currentPage'], 1);
    }

    // Safe item parsing with error handling
    final List<T> parsedItems = [];
    for (final item in itemsData) {
      if (item is Map<String, dynamic>) {
        try {
          parsedItems.add(fromJsonT(item));
        } catch (e) {
          // Skip invalid items but log the error
          print('Warning: Failed to parse item: $e');
        }
      }
    }

    return PaginatedResponse<T>(
      items: parsedItems,
      totalItems: totalItems,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  /// Factory method for simple list responses (no pagination)
  factory PaginatedResponse.fromList(
    List<T> items, {
    int? totalItems,
    int page = 1,
    int limit = 10,
  }) {
    final total = totalItems ?? items.length;
    final totalPages = limit > 0 ? (total / limit).ceil() : 1;

    return PaginatedResponse<T>(
      items: items,
      totalItems: total,
      totalPages: totalPages,
      currentPage: page,
    );
  }

  /// Factory method for empty response
  factory PaginatedResponse.empty() {
    return PaginatedResponse<T>(
      items: [],
      totalItems: 0,
      totalPages: 0,
      currentPage: 1,
    );
  }

  // Helper methods
  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;

  // Pagination info
  bool get isFirstPage => currentPage == 1;
  bool get isLastPage => currentPage >= totalPages;
  int get nextPage => hasNextPage ? currentPage + 1 : currentPage;
  int get previousPage => hasPreviousPage ? currentPage - 1 : currentPage;

  // Range information
  int get startIndex => totalItems > 0
      ? ((currentPage - 1) * (totalItems / totalPages).ceil()) + 1
      : 0;
  int get endIndex => startIndex > 0 ? startIndex + items.length - 1 : 0;

  String get rangeText {
    if (isEmpty) return '0 of 0';
    return '$startIndex-$endIndex of $totalItems';
  }

  // Convert to JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': items.map((item) => toJsonT(item)).toList(),
      'totalItems': totalItems,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  @override
  String toString() {
    return 'PaginatedResponse(items: ${items.length}, total: $totalItems, page: $currentPage/$totalPages)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginatedResponse<T> &&
          runtimeType == other.runtimeType &&
          items == other.items &&
          totalItems == other.totalItems &&
          totalPages == other.totalPages &&
          currentPage == other.currentPage;

  @override
  int get hashCode =>
      items.hashCode ^
      totalItems.hashCode ^
      totalPages.hashCode ^
      currentPage.hashCode;
}

// ===============================================
// USAGE EXAMPLES dengan ResponseParser Integration
// ===============================================

/*
✅ UPDATED USAGE EXAMPLES:

// 1. ApiResponseModel dengan ResponseParser (RECOMMENDED)
final apiResponse = ApiResponseModel.fromResponse(
  dioResponse,
  (data) => UserModel.fromJson(data as Map<String, dynamic>)
);

if (apiResponse.isSuccess) {
  final user = apiResponse.data; // UserModel
  final message = apiResponse.message; // "Login berhasil"
}

// 2. PaginatedResponse dengan ResponseParser (RECOMMENDED)
final ordersResponse = PaginatedResponse.fromResponse(
  dioResponse,
  (json) => OrderModel.fromJson(json),
);

// 3. Error handling dengan ResponseParser
try {
  final response = await dio.get('/orders');
  final result = PaginatedResponse.fromResponse(response, OrderModel.fromJson);
} on DioException catch (e) {
  final errorResponse = ApiResponseModel<dynamic>.fromError(e);
  print(errorResponse.errorMessage); // User-friendly error message
}

// 4. Manual parsing (jika perlu kontrol lebih)
final parsed = ResponseParser.parseSuccessResponse(response);
final data = ResponseParser.extractData<List>(parsed);
final pagination = ResponseParser.extractPaginationInfo(parsed);
*/
