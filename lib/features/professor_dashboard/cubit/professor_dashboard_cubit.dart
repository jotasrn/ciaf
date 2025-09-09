import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/professor_dashboard_state.dart';

class ProfessorDashboardCubit extends Cubit<ProfessorDashboardState> {
  final TurmaRepository _turmaRepository;
  ProfessorDashboardCubit(this._turmaRepository) : super(ProfessorDashboardInitial());

  Future<void> fetchMinhasTurmas() async {
    emit(ProfessorDashboardLoading());
    try {
      final turmas = await _turmaRepository.getMinhasTurmas();
      emit(ProfessorDashboardSuccess(turmas));
    } catch (e) {
      emit(ProfessorDashboardFailure(e.toString()));
    }
  }
}