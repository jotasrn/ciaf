import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';

class ProfessorSimplificadoModel extends Equatable {
  final String id;
  final String nome;
  const ProfessorSimplificadoModel({required this.id, required this.nome});

  factory ProfessorSimplificadoModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProfessorSimplificadoModel(id: '', nome: 'Professor não atribuído');
    return ProfessorSimplificadoModel(
      id: (json['_id'] is String ? json['_id'] : json['_id']?['\$oid']) ?? '',
      nome: json['nome_completo'] ?? 'Nome não informado',
    );
  }
  @override
  List<Object?> get props => [id, nome];
}

class EsporteSimplificadoModel extends Equatable {
  final String id;
  final String nome;
  const EsporteSimplificadoModel({required this.id, required this.nome});

  factory EsporteSimplificadoModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EsporteSimplificadoModel(id: '', nome: 'N/A');
    return EsporteSimplificadoModel(
      id: (json['_id'] is String ? json['_id'] : json['_id']?['\$oid']) ?? '',
      nome: json['nome'] ?? 'Nome não informado',
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
  final EsporteSimplificadoModel esporte;

  const TurmaModel({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.professor,
    required this.alunos,
    required this.horarios,
    required this.esporte,
  });

  factory TurmaModel.fromJson(Map<String, dynamic> json) {
    return TurmaModel(
      id: (json['_id'] is String ? json['_id'] : json['_id']?['\$oid']) ?? '',
      nome: json['nome'] ?? 'Turma sem nome',
      categoria: json['categoria'] ?? 'Sem categoria',
      professor: ProfessorSimplificadoModel.fromJson(json['professor']),
      alunos: (json['alunos'] as List<dynamic>?)
          ?.map((alunoJson) => UserModel.fromJson(alunoJson))
          .toList() ?? [],
      horarios: (json['horarios'] as List<dynamic>?)
          ?.map((h) => h as Map<String, dynamic>)
          .toList() ?? [],
      esporte: EsporteSimplificadoModel.fromJson(json['esporte']),
    );
  }

  @override
  List<Object?> get props => [id, nome, categoria, professor, alunos, horarios, esporte];
}