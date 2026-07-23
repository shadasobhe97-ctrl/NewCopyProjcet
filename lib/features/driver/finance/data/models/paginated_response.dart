class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int perPage;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
  });

  bool get hasMore => currentPage < lastPage;
  int get nextPage => currentPage + 1;
}
