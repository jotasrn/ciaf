import 'package:equatable/equatable.dart';

class AulaResumoModel extends Equatable {
  final String id;
  final DateTime data;
  final String status;
  final String turmaNome;
  final String esporteNome;
  final int totalAlunosNaTurma;
  final int totalPresentes;

  const AulaResumoModel({
    required this.id,
    required this.data,
    required this.status,
    required this.turmaNome,
    required this.esporteNome,
    required this.totalAlunosNaTurma,
    required this.totalPresentes,
  });

  factory AulaResumoModel.fromJson(Map<String, dynamic> json) {
    return AulaResumoModel(
      id: (json['_id'] is String ? json['_id'] : json['_id']?['\$oid']) ?? '',
      // Se a data for nula, usa uma data padrão para não quebrar o app
      data: json['data']?['\$date'] != null ? DateTime.parse(json['data']['\$date']) : DateTime(1970),
      status: json['status'] ?? 'indefinido',
      turmaNome: json['turma_nome'] ?? 'N/A',
      esporteNome: json['esporte_nome'] ?? 'N/A',
      totalAlunosNaTurma: json['total_alunos_na_turma'] ?? 0,
      totalPresentes: json['total_presentes'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, data, status, turmaNome, esporteNome, totalAlunosNaTurma, totalPresentes];
}