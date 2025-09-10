import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/aluno_chamada_model.dart';

abstract class ChamadaState extends Equatable {
  const ChamadaState();
  @override
  List<Object> get props => [];
}

class ChamadaInitial extends ChamadaState {}

class ChamadaLoading extends ChamadaState {}

class ChamadaSuccess extends ChamadaState {
  final List<AlunoChamadaModel> alunos;
  final DateTime aulaData;
  const ChamadaSuccess(this.alunos, this.aulaData);
  @override
  List<Object> get props => [alunos, aulaData];
}

class ChamadaFailure extends ChamadaState {
  final String message;
  const ChamadaFailure(this.message);
}

class ChamadaSubmitting extends ChamadaState {}

class ChamadaSubmitSuccess extends ChamadaState {}