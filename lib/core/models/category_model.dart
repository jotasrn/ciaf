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
    // Função auxiliar para extrair o ID de forma segura
    String safeGetId(dynamic idField) {
      if (idField is String) return idField;
      if (idField is Map) return idField['\$oid'] ?? '';
      return '';
    }

    return CategoryModel(
      id: safeGetId(json['_id']),
      nome: json['nome'] ?? 'Sem nome',
      esporteId: safeGetId(json['esporte_id']),
      esporteNome: json['esporte_nome'],
    );
  }

  @override
  List<Object?> get props => [id, nome, esporteId, esporteNome];
}