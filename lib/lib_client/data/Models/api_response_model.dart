class ApiResponseModel<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<T>? dataList;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponseModel({
    required this.success,
    this.message,
    this.data,
    this.dataList,
    this.statusCode,
    this.errors,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponseModel<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      dataList: json['data'] != null && fromJsonT != null
          ? (json['data'] as List)
              .map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList()
          : null,
      statusCode: json['statusCode'],
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': data,
      if (dataList != null) 'data': dataList,
      if (statusCode != null) 'statusCode': statusCode,
      if (errors != null) 'errors': errors,
    };
  }
}

