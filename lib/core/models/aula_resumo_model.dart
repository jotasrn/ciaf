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
      id: json['_id']['\$oid'], // O ID vem como um objeto BSON
      data: DateTime.parse(json['data']['\$date']), // A data também
      status: json['status'],
      turmaNome: json['turma_nome'],
      esporteNome: json['esporte_nome'],
      totalAlunosNaTurma: json['total_alunos_na_turma'],
      totalPresentes: json['total_presentes'],
    );
  }

  @override
  List<Object?> get props => [id, data, status, turmaNome, esporteNome, totalAlunosNaTurma, totalPresentes];
}