import 'dart:developer' as dev;
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:zendora_app/app/app_config.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/app/routes_names.dart';
import 'package:zendora_app/core/constants/enums/http_method.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/services/storage_service/storage_service.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {"Content-Type": "application/json"},
    ),
  );

  final StorageService _storage = locator<StorageService>();

  Future<Either<AppError, T>> makeRequest<T>({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    required T Function(dynamic json) fromJson,
  }) async {
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final fullUrl = _dio.options.baseUrl + url;

    // 🔐 AUTO TOKEN (NO MANUAL PASSING ANYMORE)
    final token = _storage.getToken();

    dev.log(
      '🚀 API REQUEST [$requestId]: ${method.name.toUpperCase()} $fullUrl',
      name: 'API',
    );

    if (data != null) {
      dev.log('📤 REQUEST DATA [$requestId]: $data', name: 'API');
    }

    if (queryParams != null) {
      dev.log('🔍 QUERY PARAMS [$requestId]: $queryParams', name: 'API');
    }

    if (token != null) {
      dev.log('🔑 AUTH TOKEN ATTACHED [$requestId]', name: 'API');
    }

    try {
      final options = Options(
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      Response response;

      switch (method) {
        case HttpMethod.get:
          response = await _dio.get(
            url,
            queryParameters: queryParams,
            options: options,
          );
          break;

        case HttpMethod.post:
          response = await _dio.post(url, data: data, options: options);
          break;

        case HttpMethod.put:
          response = await _dio.put(url, data: data, options: options);
          break;

        case HttpMethod.patch:
          response = await _dio.patch(url, data: data, options: options);
          break;

        case HttpMethod.delete:
          response = await _dio.delete(url, data: data, options: options);
          break;
      }

      dev.log(
        '✅ API RESPONSE [$requestId]: ${response.statusCode}',
        name: 'API',
      );

      dev.log('📥 RESPONSE DATA [$requestId]: ${response.data}', name: 'API');

      return Right(fromJson(response.data));
    } on DioException catch (e) {
      dev.log(
        '❌ DIO ERROR [$requestId]: ${e.type} - ${e.message}',
        name: 'API',
        error: e,
      );

      if (e.response != null) {
        dev.log(
          '📊 ERROR RESPONSE [$requestId]: ${e.response?.statusCode} - ${e.response?.data}',
          name: 'API',
        );
      }

      String? responseMessage;
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response?.data as Map<String, dynamic>;
        responseMessage = (data['message'] ?? data['error']) as String?;
      } else if (e.response?.data is String) {
        responseMessage = e.response?.data as String;
      }

      if (e.response?.statusCode == 401) {
        dev.log('🔒 SESSION EXPIRED [$requestId]: clearing token', name: 'API');
        await _storage.clearToken();
        Get.offAllNamed(Routes.login);
      }

      return Left(
        AppError(
          errorType: AppErrorType.network,
          message:
              responseMessage ?? e.message ?? "Network error occurred",
        ),
      );
    } on SocketException catch (e) {
      dev.log(
        '🔌 SOCKET ERROR [$requestId]: ${e.message}',
        name: 'API',
        error: e,
      );

      return Left(
        AppError(errorType: AppErrorType.network, message: e.message),
      );
    } catch (e) {
      dev.log('💥 GENERAL ERROR [$requestId]: $e', name: 'API', error: e);

      return Left(AppError(errorType: AppErrorType.api, message: e.toString()));
    }
  }

  Future<Either<AppError, T>> uploadFile<T>({
    required String url,
    required FormData formData,
    required T Function(dynamic json) fromJson,
  }) async {
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final fullUrl = _dio.options.baseUrl + url;
    final token = _storage.getToken();

    dev.log('🚀 UPLOAD [$requestId]: POST $fullUrl', name: 'API');

    try {
      final options = Options(
        headers: {if (token != null) "Authorization": "Bearer $token"},
      );

      final response = await _dio.post(url, data: formData, options: options);

      dev.log('✅ UPLOAD RESPONSE [$requestId]: ${response.statusCode}', name: 'API');

      return Right(fromJson(response.data));
    } on DioException catch (e) {
      dev.log('❌ UPLOAD ERROR [$requestId]: ${e.type} - ${e.message}', name: 'API', error: e);

      String? responseMessage;
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response?.data as Map<String, dynamic>;
        responseMessage = (data['message'] ?? data['error']) as String?;
      } else if (e.response?.data is String) {
        responseMessage = e.response?.data as String;
      }

      if (e.response?.statusCode == 401) {
        await _storage.clearToken();
        Get.offAllNamed(Routes.login);
      }

      return Left(
        AppError(
          errorType: AppErrorType.network,
          message: responseMessage ?? e.message ?? "Network error occurred",
        ),
      );
    } catch (e) {
      dev.log('💥 UPLOAD GENERAL ERROR [$requestId]: $e', name: 'API', error: e);

      return Left(AppError(errorType: AppErrorType.api, message: e.toString()));
    }
  }
}
