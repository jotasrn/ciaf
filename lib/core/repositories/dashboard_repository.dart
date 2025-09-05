import 'package:dio/dio.dart';
import 'package:escolinha_futebol_app/core/services/api_service.dart';

class DashboardRepository {
  final ApiService _apiService;
  DashboardRepository(this._apiService);

  Future<Map<String, int>> getSummaryData() async {
    try {
      final response = await _apiService.dio.get('/dashboard/summary');
      final data = response.data as Map<String, dynamic>;
      // Converte os valores para int
      return data.map((key, value) => MapEntry(key, value as int));
    } on DioException {
      throw Exception('Falha ao buscar dados do dashboard.');
    }
  }
}