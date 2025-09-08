import 'package:dio/dio.dart';
import 'package:escolinha_futebol_app/core/models/sport_model.dart';
import 'package:escolinha_futebol_app/core/services/api_service.dart';

class SportRepository {
  final ApiService _apiService;
  SportRepository(this._apiService);

  Future<List<SportModel>> getSports() async {
    try {
      final response = await _apiService.dio.get('/esportes/');
      final List<dynamic> data = response.data;
      return data.map((json) => SportModel.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar esportes.');
    }
  }

  Future<void> createSport({required String nome}) async {
    try {
      await _apiService.dio.post('/esportes/', data: {'nome': nome});
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensagem'] ?? 'Falha ao criar esporte.');
    }
  }

  Future<void> updateSport({required String id, required String nome}) async {
    try {
      await _apiService.dio.put('/esportes/$id', data: {'nome': nome});
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensagem'] ?? 'Falha ao atualizar esporte.');
    }
  }

  Future<void> deleteSport({required String id}) async {
    try {
      await _apiService.dio.delete('/esportes/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensagem'] ?? 'Falha ao deletar esporte.');
    }
  }
}