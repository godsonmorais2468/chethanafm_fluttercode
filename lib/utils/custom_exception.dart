class CustomException implements Exception {
  final String message;
  final dynamic additionalData;

  CustomException(this.message, [this.additionalData]);

  @override
  String toString() {
    return 'CustomException: $message';
  }
}
