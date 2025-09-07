import 'package:dio/dio.dart';
import 'package:escolinha_futebol_app/core/models/category_model.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/services/api_service.dart';

class TurmaRepository {
  final ApiService _apiService;
  TurmaRepository(this._apiService);

  Future<List<CategoryModel>> getCategorias(String esporteId) async {
    try {
      final response = await _apiService.dio.get('/categorias/$esporteId');
      final List<dynamic> data = response.data;
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar categorias.');
    }
  }

  Future<void> createCategoria({
    required String nome,
    required String esporteId,
  }) async {
    try {
      await _apiService.dio.post('/categorias/', data: {
        'nome': nome,
        'esporte_id': esporteId,
      });
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['mensagem'] ?? 'Falha ao criar categoria.');
    }
  }

  Future<List<TurmaModel>> getTurmasFiltradas({
    required String esporteId,
    required String categoria,
  }) async {
    try {
      final response = await _apiService.dio.get('/turmas/', queryParameters: {
        'esporte_id': esporteId,
        'categoria': categoria,
      });
      final List<dynamic> data = response.data;
      return data.map((json) => TurmaModel.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar turmas.');
    }
  }
}
