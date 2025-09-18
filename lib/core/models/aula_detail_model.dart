import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/aluno_chamada_model.dart';

class AulaDetailModel extends Equatable {
  final DateTime data;
  final List<AlunoChamadaModel> alunos;
  final String status; // ✅ CAMPO ADICIONADO

  const AulaDetailModel({
    required this.data,
    required this.alunos,
    required this.status, // ✅ CAMPO ADICIONADO
  });

  @override
  List<Object?> get props => [data, alunos, status];
}
