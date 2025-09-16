import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String nome;
  final String esporteId;
  final String? esporteNome;

  const CategoryModel({
    required this.id,
    required this.nome,
    required this.esporteId,
    this.esporteNome,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['_id'] is String ? json['_id'] : json['_id']?['\$oid']) ?? '',
      nome: json['nome'] ?? 'Sem nome',
      esporteId: (json['esporte_id'] is String ? json['esporte_id'] : json['esporte_id']?['\$oid']) ?? '',
      // Lê o nome do esporte que vem do aggregate do backend
      esporteNome: json['esporte_nome'],
    );
  }

  @override
  List<Object?> get props => [id, nome, esporteId, esporteNome];
}
