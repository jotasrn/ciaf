import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String nome;
  final String email;
  final String perfil; // 'admin', 'professor', 'aluno'

  const UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
  });

  @override
  List<Object?> get props => [id, nome, email, perfil];
}