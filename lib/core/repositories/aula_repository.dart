import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:escolinha_futebol_app/core/models/aula_resumo_model.dart';
import 'package:escolinha_futebol_app/core/models/aluno_chamada_model.dart';
import 'package:escolinha_futebol_app/core/services/api_service.dart';
import 'package:escolinha_futebol_app/core/models/aula_detail_model.dart';

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

  Future<List<AulaResumoModel>> getAulasPorTurma(String turmaId) async {
    try {
      final response = await _apiService.dio.get('/aulas/turma/$turmaId');
      final List<dynamic> data = response.data;
      return data.map((json) => AulaResumoModel.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar as aulas da turma.');
    }
  }

  Future<AulaDetailModel> getAulaDetails(String aulaId) async {
    try {
      final response = await _apiService.dio.get('/aulas/$aulaId/detalhes');
      final responseData = response.data as Map<String, dynamic>;

      final List<dynamic> alunosJson = responseData['alunos'];
      final alunos = alunosJson.map((json) => AlunoChamadaModel.fromJson(json)).toList();

      final data = DateTime.parse(responseData['data']['\$date']);

      return AulaDetailModel(data: data, alunos: alunos);
    } on DioException {
      throw Exception('Falha ao buscar detalhes da aula.');
    }
  }

  Future<void> submeterChamada(
      String aulaId, List<Map<String, String>> presencas) async {
    try {
      await _apiService.dio.post('/aulas/$aulaId/presencas', data: presencas);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['mensagem'] ?? 'Falha ao submeter chamada.');
    }
  }

  Future<void> agendarAulas(String turmaId) async {
    try {
      await _apiService.dio.post('/aulas/turma/$turmaId/agendar');
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensagem'] ?? 'Falha ao agendar aulas.');
    }
  }
}

