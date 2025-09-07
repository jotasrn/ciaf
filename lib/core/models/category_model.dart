import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String nome;
  final String esporteId;

  const CategoryModel({
    required this.id,
    required this.nome,
    required this.esporteId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']['\$oid'],
      nome: json['nome'],
      esporteId: json['esporte_id']['\$oid'],
    );
  }

  @override
  List<Object?> get props => [id, nome, esporteId];
}
