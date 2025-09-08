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