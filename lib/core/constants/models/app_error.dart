class AppError {
  final AppErrorType errorType;
  final String message;
  final bool? deviceRegistered;

  const AppError({required this.errorType, required this.message, this.deviceRegistered});
}

enum AppErrorType { api, network }