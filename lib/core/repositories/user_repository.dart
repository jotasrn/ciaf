import 'package:dio/dio.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/core/services/api_service.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository(this._apiService);

  Future<List<UserModel>> getUsers({Map<String, String>? filters}) async {
    try {
      final response = await _apiService.dio.get(
        '/usuarios/',
        queryParameters: filters,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Falha ao buscar usuários: ${e.message}');
    }
  }

  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    try {
      // Adiciona campos que o backend espera
      userData['data_nascimento'] =
      '1900-01-01'; // TODO: Adicionar campo de data no form

      final response = await _apiService.dio.post('/usuarios/', data: userData);
      // O backend não retorna o usuário criado, então retornamos um modelo local
      // O ideal seria o backend retornar o usuário recém-criado
      return UserModel.fromJson(
          userData..['_id'] = response.data['usuario_id']);
    } on DioException catch (e) {
      final message = e.response?.data['mensagem'] ?? 'Falha ao criar usuário.';
      throw Exception(message);
    }
  }

  Future<UserModel> updateUser(
      String userId, Map<String, dynamic> userData) async {
    try {
      await _apiService.dio.put('/usuarios/$userId', data: userData);
      // Como a API não retorna o usuário atualizado, buscamos novamente ou atualizamos localmente
      // Por simplicidade, vamos assumir a atualização local
      return UserModel.fromJson(userData..['_id'] = userId);
    } on DioException catch (e) {
      final message =
          e.response?.data['mensagem'] ?? 'Falha ao atualizar usuário.';
      throw Exception(message);
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.dio.delete('/usuarios/$userId');
    } on DioException catch (e) {
      final message =
          e.response?.data['mensagem'] ?? 'Falha ao deletar usuário.';
      throw Exception(message);
    }
  }

  Future<List<UserModel>> getProfessores() async {
    return getUsers(filters: {'perfil': 'professor'});
  }

  Future<List<UserModel>> getAlunos() async {
    return getUsers(filters: {'perfil': 'aluno'});
  }
}

