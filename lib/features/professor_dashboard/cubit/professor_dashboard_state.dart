import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';

abstract class ProfessorDashboardState extends Equatable {
  const ProfessorDashboardState();
  @override
  List<Object> get props => [];
}
class ProfessorDashboardInitial extends ProfessorDashboardState {}
class ProfessorDashboardLoading extends ProfessorDashboardState {}
class ProfessorDashboardSuccess extends ProfessorDashboardState {
  final List<TurmaModel> turmas;
  const ProfessorDashboardSuccess(this.turmas);
}
class ProfessorDashboardFailure extends ProfessorDashboardState {
  final String message;
  const ProfessorDashboardFailure(this.message);
}