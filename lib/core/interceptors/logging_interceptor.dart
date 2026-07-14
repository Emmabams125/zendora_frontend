import 'package:dio/dio.dart';
import 'package:zendora_app/core/constants/utils/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.api("➡️ ${options.method} ${options.uri}");
    AppLogger.api("Headers: ${options.headers}");
    AppLogger.api("Data: ${options.data}");
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.api("✅ ${response.statusCode} ${response.data}");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error("❌ ${err.type} - ${err.message}", error: err);
    super.onError(err, handler);
  }
}
