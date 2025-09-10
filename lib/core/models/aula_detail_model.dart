import 'package:escolinha_futebol_app/core/models/aluno_chamada_model.dart';

class AulaDetailModel {
  final DateTime data;
  final List<AlunoChamadaModel> alunos;

  const AulaDetailModel({required this.data, required this.alunos});
}