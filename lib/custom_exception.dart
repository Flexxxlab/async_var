class CustomException implements Exception {
  final int status;
  final String details;

  const CustomException({required this.status, required this.details});

  @override
  String toString() {
    return 'CustomException: $details (Status Code: $status)';
  }
}
