import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/aula_resumo_model.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';

abstract class TurmaDetailState extends Equatable {
  const TurmaDetailState();
  @override
  List<Object> get props => [];
}

class TurmaDetailInitial extends TurmaDetailState {}
class TurmaDetailLoading extends TurmaDetailState {}
class TurmaDetailSuccess extends TurmaDetailState {
  final TurmaModel turma;
  final List<AulaResumoModel> aulas;
  const TurmaDetailSuccess({required this.turma, required this.aulas});
  @override
  List<Object> get props => [turma, aulas];
}
class TurmaDetailFailure extends TurmaDetailState {
  final String message;
  const TurmaDetailFailure(this.message);
}

class TurmaDetailActionSuccess extends TurmaDetailState {
  final String message;
  const TurmaDetailActionSuccess(this.message);
  @override
  List<Object> get props => [message];
}