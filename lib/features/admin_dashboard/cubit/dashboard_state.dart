import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/aula_resumo_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardSuccess extends DashboardState {
  final int totalAlunos;
  final int totalTurmas;
  final int totalNaoPagantes;
  final List<AulaResumoModel> aulasDoDia;

  const DashboardSuccess({
    required this.totalAlunos,
    required this.totalTurmas,
    required this.totalNaoPagantes,
    required this.aulasDoDia,
  });

  @override
  List<Object> get props => [totalAlunos, totalTurmas, totalNaoPagantes, aulasDoDia];
}

class DashboardFailure extends DashboardState {
  final String message;
  const DashboardFailure(this.message);
  @override
  List<Object> get props => [message];
}