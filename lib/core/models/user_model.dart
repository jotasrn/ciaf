import 'package:equatable/equatable.dart';

class StatusPagamento extends Equatable {
  final String status;
  const StatusPagamento({required this.status});

  factory StatusPagamento.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StatusPagamento(status: 'pendente');
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
  final DateTime? dataNascimento;
  final DateTime? dataMatricula;
  final Map<String, dynamic>? contatoResponsavel;

  const UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
    required this.ativo,
    required this.statusPagamento,
    this.dataNascimento,
    this.dataMatricula,
    this.contatoResponsavel,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // CORREÇÃO: Lê o ID de dentro do objeto $oid ou como string
      id: (json['_id'] is String ? json['_id'] : json['_id']?['\$oid']) ?? '',
      nome: json['nome_completo'] ?? 'Nome não informado',
      email: json['email'] ?? 'E-mail não informado',
      perfil: json['perfil'] ?? 'indefinido',
      ativo: json['ativo'] ?? true,
      statusPagamento: StatusPagamento.fromJson(json['status_pagamento']),
      // Garante que a conversão de data seja segura
      dataNascimento: json['data_nascimento'] != null ? DateTime.tryParse(json['data_nascimento']) : null,
      dataMatricula: json['data_matricula'] != null ? DateTime.tryParse(json['data_matricula']) : null,
      contatoResponsavel: json['contato_responsavel'],
    );
  }

  @override
  List<Object?> get props => [id, nome, email, perfil, ativo, statusPagamento, dataNascimento, dataMatricula, contatoResponsavel];
}