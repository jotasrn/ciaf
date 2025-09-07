import 'package:equatable/equatable.dart';

class TurmaModel extends Equatable {
  final String id;
  final String nome;
  final String categoria;
  // Adicione outros campos como nome do professor se precisar

  const TurmaModel(
      {required this.id, required this.nome, required this.categoria});

  factory TurmaModel.fromJson(Map<String, dynamic> json) {
    return TurmaModel(
      id: json['_id']['\$oid'],
      nome: json['nome'],
      categoria: json['categoria'],
    );
  }

  @override
  List<Object?> get props => [id, nome, categoria];
}
