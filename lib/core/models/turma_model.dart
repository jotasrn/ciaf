import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';

// Modelo auxiliar para o professor simplificado dentro da Turma
class ProfessorSimplificadoModel extends Equatable {
  final String id;
  final String nome;
  const ProfessorSimplificadoModel({required this.id, required this.nome});

  factory ProfessorSimplificadoModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProfessorSimplificadoModel(id: '', nome: 'N/A');
    return ProfessorSimplificadoModel(
      id: json['_id']['\$oid'],
      nome: json['nome_completo'],
    );
  }
  @override
  List<Object?> get props => [id, nome];
}

class TurmaModel extends Equatable {
  final String id;
  final String nome;
  final String categoria;
  final ProfessorSimplificadoModel professor;
  final List<UserModel> alunos;
  final List<Map<String, dynamic>> horarios;

  const TurmaModel({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.professor,
    required this.alunos,
    required this.horarios,
  });

  factory TurmaModel.fromJson(Map<String, dynamic> json) {
    return TurmaModel(
      id: json['_id']['\$oid'],
      nome: json['nome'],
      categoria: json['categoria'] ?? '',
      professor: ProfessorSimplificadoModel.fromJson(json['professor']),
      alunos: (json['alunos'] as List<dynamic>?)
          ?.map((alunoJson) => UserModel.fromJson(alunoJson))
          .toList() ?? [],
      horarios: (json['horarios'] as List<dynamic>?)
          ?.map((h) => h as Map<String, dynamic>)
          .toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [id, nome, categoria, professor, alunos, horarios];
}