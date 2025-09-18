import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_detail_state.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/models/aula_resumo_model.dart';

class TurmaDetailCubit extends Cubit<TurmaDetailState> {
  final TurmaRepository _turmaRepository;
  final AulaRepository _aulaRepository;

  TurmaDetailCubit(this._turmaRepository, this._aulaRepository)
      : super(const TurmaDetailInitial());

  Future<void> fetchTurmaDetails(String turmaId) async {
    if (state is! TurmaDetailSuccess) {
      emit(const TurmaDetailLoading());
    }

    try {
      final results = await Future.wait([
        _turmaRepository.getTurmaById(turmaId),
        _aulaRepository.getAulasByTurma(turmaId),
      ]);

      final turma = results[0] as TurmaModel?;
      final aulas = results[1] as List<AulaResumoModel>;

      if (turma == null) {
        emit(const TurmaDetailFailure('Turma não encontrada.'));
        return;
      }

      emit(TurmaDetailSuccess(turma: turma, aulas: aulas));
    } catch (e) {
      emit(TurmaDetailFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> refreshTurmaDetails(String turmaId) async {
    await fetchTurmaDetails(turmaId);
  }

  Future<void> agendarAulas(String turmaId) async {
    final currentState = state;
    if (currentState is TurmaDetailSuccess) {
      try {
        await _aulaRepository.agendarAulas(turmaId);
        emit(const TurmaDetailActionSuccess('Aulas agendadas com sucesso!'));
        await refreshTurmaDetails(turmaId);
      } catch (e) {
        emit(TurmaDetailFailure(e.toString().replaceAll('Exception: ', '')));
        emit(currentState);
      }
    }
  }
}