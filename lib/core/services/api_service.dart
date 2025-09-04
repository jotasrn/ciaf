import 'package:dio/dio.dart';
import 'package:escolinha_futebol_app/core/services/local_storage_service.dart';

class ApiService {
  final Dio _dio;
  final LocalStorageService _localStorageService;

  // Para testar via web use 'http://127.0.0.1:5000/api'
  // Para testar via emulador Android use 'http://10.0.2.2:5000/api'
  static const String _baseUrl = 'http://127.0.0.1:5000/api';

  ApiService(this._localStorageService) : _dio = Dio(BaseOptions(baseUrl: _baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _localStorageService.getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // Getter para expor a instância do Dio, se necessário
  Dio get dio => _dio;
}