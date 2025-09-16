import 'package:dio/dio.dart';
import 'package:escolinha_futebol_app/core/services/local_storage_service.dart';

class ApiService {
  final Dio _dio;
  final LocalStorageService _localStorageService;

  // URL permanente e correta do seu servidor via Tailscale Funnel
  static const String _baseUrl = 'http://127.0.0.1:5000/api';
  //static const String _baseUrl = 'https://orangepizero3.taild57440.ts.net/api';

  ApiService(this._localStorageService)
      : _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {
      // Este cabeçalho do ngrok não é mais necessário com o Tailscale
      'Accept': 'application/json',
    },
  )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Busca o token salvo localmente
          final token = await _localStorageService.getAuthToken();
          if (token != null) {
            // Adiciona o token de autorização a todas as requisições
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // Getter para expor a instância do Dio para os repositórios
  Dio get dio => _dio;
}