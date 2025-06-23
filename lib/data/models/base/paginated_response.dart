// // lib/core/models/paginated_response.dart - FIXED VERSION
// class PaginatedResponse<T> {
//   final List<T> items;
//   final int totalItems;
//   final int totalPages;
//   final int currentPage;
//   final int itemsPerPage;
//   final bool hasNextPage;
//   final bool hasPreviousPage;
//
//   PaginatedResponse({
//     required this.items,
//     required this.totalItems,
//     required this.totalPages,
//     required this.currentPage,
//     required this.itemsPerPage,
//     required this.hasNextPage,
//     required this.hasPreviousPage,
//   });
//
//   factory PaginatedResponse.fromJson(
//     Map<String, dynamic> json,
//     T Function(Map<String, dynamic>) fromJsonT,
//   ) {
//     // ✅ Handle different backend response structures
//     final List<dynamic> itemsJson;
//     final int totalItems;
//     final int totalPages;
//     final int currentPage;
//
//     // Check if data contains pagination info directly
//     if (json.containsKey('orders') && json['orders'] is List) {
//       // Backend returns: { orders: [...], totalItems: ..., totalPages: ..., currentPage: ... }
//       itemsJson = json['orders'] as List<dynamic>;
//       totalItems = json['totalItems'] as int? ?? itemsJson.length;
//       totalPages = json['totalPages'] as int? ?? 1;
//       currentPage = json['currentPage'] as int? ?? 1;
//     } else if (json.containsKey('data') && json['data'] is Map) {
//       // Backend returns: { data: { orders: [...], totalItems: ... } }
//       final dataMap = json['data'] as Map<String, dynamic>;
//       itemsJson = dataMap['orders'] as List<dynamic>? ?? [];
//       totalItems = dataMap['totalItems'] as int? ?? itemsJson.length;
//       totalPages = dataMap['totalPages'] as int? ?? 1;
//       currentPage = dataMap['currentPage'] as int? ?? 1;
//     } else if (json.containsKey('data') && json['data'] is List) {
//       // Backend returns: { data: [...] }
//       itemsJson = json['data'] as List<dynamic>;
//       totalItems = json['totalItems'] as int? ?? itemsJson.length;
//       totalPages = json['totalPages'] as int? ?? 1;
//       currentPage = json['currentPage'] as int? ?? 1;
//     } else if (json is List) {
//       // Backend returns: [...]
//       itemsJson = json;
//       totalItems = itemsJson.length;
//       totalPages = 1;
//       currentPage = 1;
//     } else {
//       // Fallback
//       itemsJson = [];
//       totalItems = 0;
//       totalPages = 0;
//       currentPage = 1;
//     }
//
//     final items = itemsJson
//         .map((item) => fromJsonT(item as Map<String, dynamic>))
//         .toList();
//
//     final itemsPerPage = totalItems > 0 && totalPages > 0
//         ? (totalItems / totalPages).ceil()
//         : 10;
//
//     return PaginatedResponse<T>(
//       items: items,
//       totalItems: totalItems,
//       totalPages: totalPages,
//       currentPage: currentPage,
//       itemsPerPage: itemsPerPage,
//       hasNextPage: currentPage < totalPages,
//       hasPreviousPage: currentPage > 1,
//     );
//   }
//
//   // ✅ Create from simple list (for backward compatibility)
//   factory PaginatedResponse.fromList(
//     List<T> items, {
//     int? totalItems,
//     int page = 1,
//     int limit = 10,
//   }) {
//     final total = totalItems ?? items.length;
//     final totalPages = (total / limit).ceil();
//
//     return PaginatedResponse<T>(
//       items: items,
//       totalItems: total,
//       totalPages: totalPages,
//       currentPage: page,
//       itemsPerPage: limit,
//       hasNextPage: page < totalPages,
//       hasPreviousPage: page > 1,
//     );
//   }
//
//   Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
//     return {
//       'items': items.map((item) => toJsonT(item)).toList(),
//       'totalItems': totalItems,
//       'totalPages': totalPages,
//       'currentPage': currentPage,
//       'itemsPerPage': itemsPerPage,
//       'hasNextPage': hasNextPage,
//       'hasPreviousPage': hasPreviousPage,
//     };
//   }
//
//   // ✅ Helper methods
//   bool get isEmpty => items.isEmpty;
//   bool get isNotEmpty => items.isNotEmpty;
//   int get length => items.length;
//
//   // ✅ Pagination helpers
//   bool get isFirstPage => currentPage == 1;
//   bool get isLastPage => currentPage == totalPages;
//
//   int get nextPage => hasNextPage ? currentPage + 1 : currentPage;
//   int get previousPage => hasPreviousPage ? currentPage - 1 : currentPage;
//
//   // ✅ Range information
//   int get startIndex => ((currentPage - 1) * itemsPerPage) + 1;
//   int get endIndex => startIndex + items.length - 1;
//
//   String get rangeText {
//     if (isEmpty) return '0 of 0';
//     return '$startIndex-$endIndex of $totalItems';
//   }
//
//   @override
//   String toString() {
//     return 'PaginatedResponse{items: ${items.length}, totalItems: $totalItems, currentPage: $currentPage, totalPages: $totalPages}';
//   }
// }
