import 'package:shelf/shelf.dart';

class Pagination {
  final int page;
  final int perPage;

  Pagination({required this.page, required this.perPage});

  factory Pagination.fromRequest(Request request) {
    final params = request.url.queryParameters;
    var page = int.tryParse(params['page'] ?? '') ?? 1;
    var perPage = int.tryParse(params['perPage'] ?? '') ?? 20;

    if (page < 1) page = 1;
    if (perPage < 1) perPage = 1;
    if (perPage > 100) perPage = 100;

    return Pagination(page: page, perPage: perPage);
  }

  int get offset => (page - 1) * perPage;

  String get limitClause => 'LIMIT $perPage OFFSET $offset';
}
