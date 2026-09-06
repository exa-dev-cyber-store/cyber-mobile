class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String message = 'Success', int statusCode = 200}) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode, T? data}) {
    return ApiResponse(
      success: false,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }
}

class PaginatedResult<T> {
  final List<T> items;
  final int total;
  final int page;

  PaginatedResult({
    required this.items,
    required this.total,
    this.page = 1,
  });

  bool get hasMore => items.length < total;
}
