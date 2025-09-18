// lib/core/repositories/auth_repository.dart

import 'package:dio/dio.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/core/services/api_service.dart';
import 'package:escolinha_futebol_app/core/services/local_storage_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  AuthRepository(this._apiService, this._localStorageService);

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

      final token = response.data['access_token'];
      await _localStorageService.saveAuthToken(token);
      return _userFromToken(token, email: email);

    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('E-mail ou senha inválidos.');
      }
      throw Exception('Erro de rede. Tente novamente.');
    }
  }

  Future<void> logout() async {
    await _localStorageService.deleteAuthToken();
  }

  UserModel _userFromToken(String token, {String? email}) {
    final Map<String, dynamic> payload = Jwt.parseJwt(token);
    return UserModel(
      id: payload['sub'],
      nomeCompleto: payload['nome_completo'],
      email: email ?? 'email.nao.fornecido',
      perfil: payload['perfil'],
      ativo: true,
      statusPagamento: const StatusPagamento(status: 'pendente'),
    );
  }
}