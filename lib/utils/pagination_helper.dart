/// Pagination helper utilities for paginating large lists
/// 
/// This module provides reusable pagination logic for efficiently loading
/// paginated data (like leaderboards and lesson lists) with 20 items per page.

/// Model for pagination state
class PaginationState<T> {
  /// Current page number (1-based)
  final int currentPage;

  /// Total number of items available
  final int total;

  /// Items per page
  final int itemsPerPage;

  /// Current page items
  final List<T> items;

  /// Whether data is currently loading
  final bool isLoading;

  /// Error message if any
  final String? error;

  /// Whether there are more pages to load
  bool get hasNextPage => currentPage < totalPages;

  /// Total number of pages
  int get totalPages => (total / itemsPerPage).ceil();

  /// First item index on current page (1-based)
  int get firstItemIndex => (currentPage - 1) * itemsPerPage + 1;

  /// Last item index on current page (1-based)
  int get lastItemIndex => firstItemIndex + items.length - 1;

  const PaginationState({
    required this.currentPage,
    required this.total,
    this.itemsPerPage = 20,
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  /// Create a copy with updated fields
  PaginationState<T> copyWith({
    int? currentPage,
    int? total,
    int? itemsPerPage,
    List<T>? items,
    bool? isLoading,
    String? error,
  }) {
    return PaginationState<T>(
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Pagination cache for reducing duplicate requests
class PaginationCache<T> {
  /// Cache of pages already loaded
  final Map<int, List<T>> _cache = {};

  /// Get cached page
  List<T>? getPage(int pageNumber) => _cache[pageNumber];

  /// Store page in cache
  void cachePage(int pageNumber, List<T> items) {
    _cache[pageNumber] = items;
  }

  /// Clear cache
  void clear() {
    _cache.clear();
  }

  /// Check if page is cached
  bool hasPage(int pageNumber) => _cache.containsKey(pageNumber);
}

/// Helper class for managing pagination
class PaginationHelper {
  /// Standard page size
  static const defaultPageSize = 20;

  /// Maximum page size to prevent abuse
  static const maxPageSize = 100;

  /// Validate page number
  static int validatePageNumber(int page) {
    return page < 1 ? 1 : page;
  }

  /// Validate page size
  static int validatePageSize(int size) {
    if (size < 1) return defaultPageSize;
    if (size > maxPageSize) return maxPageSize;
    return size;
  }

  /// Calculate offset (0-based) for a page
  static int calculateOffset(int page, int pageSize) {
    return (validatePageNumber(page) - 1) * validatePageSize(pageSize);
  }

  /// Calculate page number from offset
  static int pageFromOffset(int offset, int pageSize) {
    return (offset ~/ validatePageSize(pageSize)) + 1;
  }

  /// Get total pages for a given total items and page size
  static int calculateTotalPages(int totalItems, int pageSize) {
    if (totalItems == 0) return 1;
    return (totalItems / validatePageSize(pageSize)).ceil();
  }
}
