// lib/core/repositories/user_repository.dart

import 'package:dio/dio.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/core/services/api_service.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository(this._apiService);

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _apiService.dio.get('/usuarios/');
      final List<dynamic> data = response.data;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Falha ao buscar usuários: ${e.message}');
    }
  }
}