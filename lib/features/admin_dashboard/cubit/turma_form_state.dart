import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';

abstract class TurmaFormState extends Equatable {
  const TurmaFormState();
  @override
  List<Object?> get props => []; // Use List<Object?> para permitir nulos
}

class TurmaFormInitial extends TurmaFormState {}
class TurmaFormLoading extends TurmaFormState {}
class TurmaFormSubmitting extends TurmaFormState {}
class TurmaFormSuccess extends TurmaFormState {}
class TurmaFormFailure extends TurmaFormState {
  final String message;
  const TurmaFormFailure(this.message);
}

class TurmaFormDataReady extends TurmaFormState {
  final List<UserModel> professores;
  final List<UserModel> alunos;
  final TurmaModel? turmaExistente;

  const TurmaFormDataReady({
    required this.professores,
    required this.alunos,
    this.turmaExistente,
  });
  @override
  List<Object?> get props => [professores, alunos, turmaExistente];
}