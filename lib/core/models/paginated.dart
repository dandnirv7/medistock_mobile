class Paginated<T> {
  Paginated({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final items = (json['data'] as List<dynamic>? ?? [])
        .map((e) => fromJsonT(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>?;
    return Paginated<T>(
      items: items,
      page: (meta?['page'] as num?)?.toInt() ?? 1,
      limit: (meta?['limit'] as num?)?.toInt() ?? items.length,
      total: (meta?['total'] as num?)?.toInt() ?? items.length,
      totalPages: (meta?['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  factory Paginated.empty() => Paginated<T>(
        items: <T>[],
        page: 1,
        limit: 10,
        total: 0,
        totalPages: 0,
      );
}
