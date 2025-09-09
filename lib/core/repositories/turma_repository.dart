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

  Future<void> updateCategoria({required String id, required String nome}) async {
    try {
      await _apiService.dio.put('/categorias/$id', data: {'nome': nome});
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensagem'] ?? 'Falha ao atualizar categoria.');
    }
  }

  Future<void> deleteCategoria({required String id}) async {
    try {
      await _apiService.dio.delete('/categorias/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensagem'] ?? 'Falha ao deletar categoria.');
    }
  }

  Future<void> deleteTurma({required String id}) async {
    try {
      await _apiService.dio.delete('/turmas/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensagem'] ?? 'Falha ao deletar turma.');
    }
  }

  Future<void> createTurma(Map<String, dynamic> turmaData) async {
    try {
      await _apiService.dio.post('/turmas/', data: turmaData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensagem'] ?? 'Falha ao criar turma.');
    }
  }

  Future<void> updateTurma(String id, Map<String, dynamic> turmaData) async {
    try {
      await _apiService.dio.put('/turmas/$id', data: turmaData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensagem'] ?? 'Falha ao atualizar turma.');
    }
  }

  Future<TurmaModel> getTurmaById(String turmaId) async {
    try {
      final response = await _apiService.dio.get('/turmas/$turmaId');
      return TurmaModel.fromJson(response.data);
    } on DioException {
      throw Exception('Falha ao buscar detalhes da turma.');
    }
  }

  Future<List<TurmaModel>> getTodasTurmas() async {
    try {
      // Chama a rota /api/turmas/ sem nenhum filtro
      final response = await _apiService.dio.get('/turmas/');
      final List<dynamic> data = response.data;
      // Nosso TurmaModel.fromJson já está preparado para lidar com os dados populados
      return data.map((json) => TurmaModel.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar todas as turmas.');
    }
  }

  Future<List<TurmaModel>> getMinhasTurmas() async {
    try {
      // Rota segura que criamos no backend
      final response = await _apiService.dio.get('/turmas/professor/me');
      final List<dynamic> data = response.data;
      return data.map((json) => TurmaModel.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar suas turmas.');
    }
  }
}
