import 'package:equatable/equatable.dart';

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
  const DashboardSuccess({required this.totalAlunos, required this.totalTurmas, required this.totalNaoPagantes,});
  @override
  List<Object> get props => [totalAlunos, totalTurmas,totalNaoPagantes];
}
class DashboardFailure extends DashboardState {
  final String message;
  const DashboardFailure(this.message);
  @override
  List<Object> get props => [message];
}