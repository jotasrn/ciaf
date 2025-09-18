import 'package:equatable/equatable.dart';
// Certifique-se de que este arquivo existe e está com o conteúdo correto.
import 'package:escolinha_futebol_app/core/utils/safe_parsers.dart';

class StatusPagamento extends Equatable {
  final String status;
  final DateTime? dataVencimento;
  final DateTime? dataUltimoPagamento;

  const StatusPagamento({
    required this.status,
    this.dataVencimento,
    this.dataUltimoPagamento,
  });

  factory StatusPagamento.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      // Retorna um valor padrão seguro se o objeto de pagamento for nulo.
      return const StatusPagamento(status: 'pendente');
    }
    return StatusPagamento(
      status: json['status'] ?? 'pendente',
      dataVencimento: safeParseDate(json['data_vencimento']),
      dataUltimoPagamento: safeParseDate(json['data_ultimo_pagamento']),
    );
  }

  @override
  List<Object?> get props => [status, dataVencimento, dataUltimoPagamento];
}

class UserModel extends Equatable {
  final String id;
  final String nomeCompleto; // Corrigido para 'nomeCompleto' para bater com o JSON
  final String email;
  final String perfil;
  final bool ativo;
  final StatusPagamento statusPagamento;
  final DateTime? dataNascimento;
  final DateTime? dataMatricula;
  final Map<String, dynamic>? contatoResponsavel;

  const UserModel({
    required this.id,
    required this.nomeCompleto,
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
      id: safeGetId(json['_id']),
      nomeCompleto: json['nome_completo'] ?? 'Nome não informado',
      email: json['email'] ?? 'E-mail não informado',
      perfil: json['perfil'] ?? 'indefinido',
      ativo: json['ativo'] ?? true,
      statusPagamento: StatusPagamento.fromJson(json['status_pagamento'] as Map<String, dynamic>?),
      dataNascimento: safeParseDate(json['data_nascimento']),
      dataMatricula: safeParseDate(json['data_matricula']),
      contatoResponsavel: json['contato_responsavel'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [id, nomeCompleto, email, perfil, ativo, statusPagamento, dataNascimento, dataMatricula, contatoResponsavel];
}