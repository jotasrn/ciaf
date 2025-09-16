import 'package:equatable/equatable.dart';

class SportModel extends Equatable {
  final String id;
  final String nome;

  const SportModel({required this.id, required this.nome});

  factory SportModel.fromJson(Map<String, dynamic> json) {
    return SportModel(
      id: json['_id']['\$oid'],
      nome: json['nome'],
    );
  }
  @override
  List<Object?> get props => [id, nome];
}

class CategoryBasicModel extends Equatable {
  final String id; final String nome;
  const CategoryBasicModel({required this.id, required this.nome});
  factory CategoryBasicModel.fromJson(Map<String, dynamic> json) {
    return CategoryBasicModel(id: json['_id']['\$oid'], nome: json['nome']);
  }
  @override List<Object?> get props => [id, nome];
}

class SportWithCategoriesModel extends SportModel {
  final List<CategoryBasicModel> categorias;
  const SportWithCategoriesModel({required super.id, required super.nome, required this.categorias});

  factory SportWithCategoriesModel.fromJson(Map<String, dynamic> json) {
    return SportWithCategoriesModel(
      id: json['_id']['\$oid'],
      nome: json['nome'],
      categorias: (json['categorias'] as List<dynamic>?)
          ?.map((catJson) => CategoryBasicModel.fromJson(catJson))
          .toList() ?? [],
    );
  }
}