import 'package:equatable/equatable.dart';

class StatusPagamento extends Equatable {
  final String status;
  final DateTime? dataVencimento;

  const StatusPagamento({required this.status, this.dataVencimento});

  factory StatusPagamento.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StatusPagamento(status: 'pendente');
    return StatusPagamento(
      status: json['status'] ?? 'pendente',
      dataVencimento: json['data_vencimento'] != null
          ? DateTime.tryParse(json['data_vencimento']['\$date'])
          : null,
    );
  }

  @override
  List<Object?> get props => [status, dataVencimento];
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
    String safeGetId(dynamic idField) {
      if (idField is String) return idField;
      if (idField is Map) return idField['\$oid'] ?? '';
      return '';
    }

    DateTime? safeParseDate(dynamic dateField) {
      if (dateField is String) return DateTime.tryParse(dateField);
      if (dateField is Map && dateField.containsKey('\$date')) {
        return DateTime.tryParse(dateField['\$date']);
      }
      return null;
    }

    return UserModel(
      id: safeGetId(json['_id']),
      nome: json['nome_completo'] ?? 'Nome não informado',
      email: json['email'] ?? 'E-mail não informado',
      perfil: json['perfil'] ?? 'indefinido',
      ativo: json['ativo'] ?? true,
      statusPagamento: StatusPagamento.fromJson(json['status_pagamento']),
      dataNascimento: safeParseDate(json['data_nascimento']),
      dataMatricula: safeParseDate(json['data_matricula']),
      contatoResponsavel: json['contato_responsavel'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [id, nome, email, perfil, ativo, statusPagamento, dataNascimento, dataMatricula, contatoResponsavel];
}