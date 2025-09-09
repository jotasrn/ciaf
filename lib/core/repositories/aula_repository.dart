import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:escolinha_futebol_app/core/models/aula_resumo_model.dart';
import 'package:escolinha_futebol_app/core/models/aluno_chamada_model.dart';
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

  Future<List<AulaResumoModel>> getAulasPorTurma(String turmaId) async {
    try {
      final response = await _apiService.dio.get('/aulas/turma/$turmaId');
      final List<dynamic> data = response.data;
      return data.map((json) => AulaResumoModel.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar as aulas da turma.');
    }
  }

  Future<List<AlunoChamadaModel>> getAlunosDaAula(String aulaId) async {
    try {
      final response = await _apiService.dio.get('/aulas/$aulaId/detalhes');
      final List<dynamic> alunosJson = response.data['alunos'];
      return alunosJson.map((json) => AlunoChamadaModel.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar alunos da aula.');
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

