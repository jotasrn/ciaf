import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/aluno_chamada_model.dart';

abstract class ChamadaState extends Equatable {
  const ChamadaState();

  @override
  List<Object?> get props => [];
}

class ChamadaInitial extends ChamadaState {
  const ChamadaInitial();
}

class ChamadaLoading extends ChamadaState {
  const ChamadaLoading();
}

class ChamadaSuccess extends ChamadaState {
  final List<AlunoChamadaModel> alunos;
  final DateTime aulaData;

  const ChamadaSuccess({required this.alunos, required this.aulaData});

  @override
  List<Object?> get props => [alunos, aulaData];
}

class ChamadaSubmitting extends ChamadaSuccess {
  const ChamadaSubmitting({required super.alunos, required super.aulaData});
}

class ChamadaSubmitSuccess extends ChamadaState {
  const ChamadaSubmitSuccess();
}

class ChamadaFailure extends ChamadaState {
  final String message;
  const ChamadaFailure(this.message);

  @override
  List<Object?> get props => [message];
}
