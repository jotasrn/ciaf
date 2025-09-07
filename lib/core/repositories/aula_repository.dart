import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:escolinha_futebol_app/core/models/aula_resumo_model.dart';
import 'package:escolinha_futebol_app/core/services/api_service.dart';

class AulaRepository {
  final ApiService _apiService;
  AulaRepository(this._apiService);

  Future<List<AulaResumoModel>> getAulasPorData(DateTime data) async {
    final formatoData = DateFormat('yyyy-MM-dd');
    final dataString = formatoData.format(data);

    try {
      final response = await _apiService.dio
          .get('/aulas/por-data', queryParameters: {'data': dataString});
      final List<dynamic> data = response.data;
      // Mapeia a lista de JSON para a lista de AulaResumoModel
      return data.map((json) => AulaResumoModel.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar as aulas do dia.');
    }
  }
}
