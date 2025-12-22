class ApiResponseModel<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String>? errors;
  final Map<String, dynamic>? meta;
  ApiResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.meta,
  });
  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponseModel<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'meta': meta,
    };
  }
}
class PaginatedResponseModel<T> {
  final bool success;
  final String message;
  final List<T> data;
  final PaginationModel? pagination;
  final List<String>? errors;
  PaginatedResponseModel({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
    this.errors,
  });
  factory PaginatedResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponseModel<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
                .map((item) => fromJsonT(item as Map<String, dynamic>))
                .toList()
          : [],
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'pagination': pagination?.toJson(),
      'errors': errors,
    };
  }
}
class PaginationModel {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int? from;
  final int? to;
  PaginationModel({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    this.from,
    this.to,
  });
  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      from: json['from'] as int?,
      to: json['to'] as int?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total': total,
      'last_page': lastPage,
      'from': from,
      'to': to,
    };
  }
  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}
