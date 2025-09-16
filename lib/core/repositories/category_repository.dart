import 'package:dio/dio.dart';
import 'package:escolinha_futebol_app/core/models/category_model.dart';
import 'package:escolinha_futebol_app/core/services/api_service.dart';

class CategoryRepository {
  final ApiService _apiService;
  CategoryRepository(this._apiService);

  /// Busca todas as categorias de todos os esportes.
  Future<List<CategoryModel>> getTodasCategorias() async {
    try {
      final response = await _apiService.dio.get('/categorias/');
      final List<dynamic> data = response.data;
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar as categorias.');
    }
  }

  /// Cria uma nova categoria.
  Future<void> createCategoria({required String nome, required String esporteId}) async {
    try {
      await _apiService.dio.post('/categorias/', data: {
        'nome': nome,
        'esporte_id': esporteId,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensagem'] ?? 'Falha ao criar categoria.');
    }
  }

  /// Atualiza o nome de uma categoria.
  Future<void> updateCategoria({required String id, required String nome}) async {
    try {
      await _apiService.dio.put('/categorias/$id', data: {'nome': nome});
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensagem'] ?? 'Falha ao atualizar categoria.');
    }
  }

  /// Deleta uma categoria.
  Future<void> deleteCategoria({required String id}) async {
    try {
      await _apiService.dio.delete('/categorias/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensagem'] ?? 'Falha ao deletar categoria.');
    }
  }
}