import 'package:equatable/equatable.dart';

// Modelo base para Esporte
class SportModel extends Equatable {
  final String id;
  final String nome;

  const SportModel({required this.id, required this.nome});

  factory SportModel.fromJson(Map<String, dynamic> json) {
    return SportModel(
      id: (json['_id'] is String ? json['_id'] : json['_id']?['\$oid']) ?? '',
      nome: json['nome'] ?? 'Sem Nome',
    );
  }
  @override
  List<Object?> get props => [id, nome];
}

// Modelo auxiliar para a categoria dentro do esporte
class CategoryBasicModel extends Equatable {
  final String id;
  final String nome;
  const CategoryBasicModel({required this.id, required this.nome});

  factory CategoryBasicModel.fromJson(Map<String, dynamic> json) {
    return CategoryBasicModel(
      id: (json['_id'] is String ? json['_id'] : json['_id']?['\$oid']) ?? '',
      nome: json['nome'] ?? 'Sem nome',
    );
  }
  @override
  List<Object?> get props => [id, nome];
}

// Modelo completo que a API /esportes/com-categorias retorna
class SportWithCategoriesModel extends SportModel {
  final List<CategoryBasicModel> categorias;
  const SportWithCategoriesModel({
    required super.id,
    required super.nome,
    required this.categorias,
  });

  factory SportWithCategoriesModel.fromJson(Map<String, dynamic> json) {
    return SportWithCategoriesModel(
      id: (json['_id'] is String ? json['_id'] : json['_id']?['\$oid']) ?? '',
      nome: json['nome'] ?? 'Sem Nome',
      categorias: (json['categorias'] as List<dynamic>?)
          ?.map((catJson) => CategoryBasicModel.fromJson(catJson))
          .toList() ?? [],
    );
  }
}