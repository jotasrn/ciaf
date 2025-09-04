import 'package:dio/dio.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/core/services/api_service.dart';
import 'package:escolinha_futebol_app/core/services/local_storage_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  AuthRepository(this._apiService, this._localStorageService);

  // Função para verificar se existe um token válido ao iniciar o app
  Future<UserModel?> tryAutoLogin() async {
    final token = await _localStorageService.getAuthToken();
    if (token == null || Jwt.isExpired(token)) {
      await _localStorageService.deleteAuthToken();
      return null;
    }
    return _userFromToken(token);
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/login',
        data: {'email': email, 'senha': password},
      );

      // PRINT 1: O que a API realmente nos enviou?
      print('DEBUG: Resposta da API recebida: ${response.data}');

      final token = response.data['access_token'];
      if (token == null) {
        throw Exception('Token não encontrado na resposta da API.');
      }

      // PRINT 2: Conseguimos extrair o token?
      print('DEBUG: Token extraído com sucesso.');

      await _localStorageService.saveAuthToken(token);

      // PRINT 3: O que tem dentro do token decodificado?
      final Map<String, dynamic> payload = Jwt.parseJwt(token);
      print('DEBUG: Payload do token decodificado: $payload');

      return _userFromToken(token, email: email);

    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('E-mail ou senha inválidos.');
      }
      throw Exception('Erro de rede. Tente novamente.');
    } catch (e) {
      // PRINT 4: Algum outro erro inesperado aconteceu aqui?
      print('DEBUG: ERRO INESPERADO NO REPOSITÓRIO: $e');
      throw Exception('Ocorreu um erro inesperado.');
    }
  }


  Future<void> logout() async {
    await _localStorageService.deleteAuthToken();
  }

  UserModel _userFromToken(String token, {String? email}) {
    final Map<String, dynamic> payload = Jwt.parseJwt(token);
    return UserModel(
      id: payload['sub'],
      nome: payload['nome_completo'],
      // O email não vem no 'sub', então usamos o passado no login ou um fallback
      email: email ?? 'email.nao.fornecido',
      perfil: payload['perfil'],
    );
  }
}
