import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';

abstract class TurmaManagementState extends Equatable {
  const TurmaManagementState();
  @override
  List<Object> get props => [];
}

class TurmaManagementInitial extends TurmaManagementState {}

class TurmaManagementLoading extends TurmaManagementState {}

class TurmaManagementSuccess extends TurmaManagementState {
  final List<TurmaModel> turmas;
  const TurmaManagementSuccess(this.turmas);
  @override
  List<Object> get props => [turmas];
}

class TurmaManagementFailure extends TurmaManagementState {
  final String message;
  const TurmaManagementFailure(this.message);
  @override
  List<Object> get props => [message];
}
