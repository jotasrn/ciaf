// lib/core/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:escolinha_futebol_app/core/services/local_storage_service.dart';

class ApiService {
  final Dio _dio;
  final LocalStorageService _localStorageService;

  static const String _baseUrl = 'http://192.168.1.13:5000/api';
  //static const String _baseUrl = 'https://orangepizero3.taild57440.ts.net/api';

  ApiService(this._localStorageService)
      : _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {
      'ngrok-skip-browser-warning': 'true',
      'Accept': 'application/json',
    },
  )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _localStorageService.getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Garante que o cabeçalho do ngrok esteja presente mesmo no interceptor
          options.headers['ngrok-skip-browser-warning'] = 'true';
          return handler.next(options);
        },
      ),
    );
  }

  Dio get dio => _dio;
}