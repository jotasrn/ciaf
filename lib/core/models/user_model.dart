import 'package:equatable/equatable.dart';

class StatusPagamento extends Equatable {
  final String status;
  const StatusPagamento({required this.status});

  factory StatusPagamento.fromJson(Map<String, dynamic>? json) {
    // Se o objeto inteiro for nulo, retorna um status padrão
    if (json == null) return const StatusPagamento(status: 'pendente');
    // Se o campo status for nulo, retorna um status padrão
    return StatusPagamento(status: json['status'] ?? 'pendente');
  }

  @override
  List<Object?> get props => [status];
}

class UserModel extends Equatable {
  final String id;
  final String nome;
  final String email;
  final String perfil;
  final bool ativo;
  final StatusPagamento statusPagamento;

  const UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
    required this.ativo,
    required this.statusPagamento,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['_id'] is String ? json['_id'] : json['_id']?['\$oid']) ?? '',
      nome: json['nome_completo'] ?? 'Nome não informado',
      email: json['email'] ?? 'E-mail não informado',
      perfil: json['perfil'] ?? 'indefinido',
      ativo: json['ativo'] ?? true,
      statusPagamento: StatusPagamento.fromJson(json['status_pagamento']),
    );
  }

  @override
  List<Object?> get props => [id, nome, email, perfil, ativo, statusPagamento];
}