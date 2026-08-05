class DbResult<T> {
  final T? data;
  final String? errorMessage;
  final bool isSuccess;

  DbResult._({this.data, this.errorMessage, required this.isSuccess});

  factory DbResult.success({required T data}) {
    return DbResult._(data: data, isSuccess: true);
  }

  factory DbResult.failure({required String message}) {
    return DbResult._(errorMessage: message, isSuccess: false);
  }
}
