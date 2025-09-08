import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_state.dart';

class TurmaManagementCubit extends Cubit<TurmaManagementState> {
  final TurmaRepository _turmaRepository;

  TurmaManagementCubit(this._turmaRepository) : super(TurmaManagementInitial());

  Future<void> fetchTurmas({
    required String esporteId,
    required String categoria,
  }) async {
    emit(TurmaManagementLoading());
    try {
      final turmas = await _turmaRepository.getTurmasFiltradas(
        esporteId: esporteId,
        categoria: categoria,
      );
      emit(TurmaManagementSuccess(turmas));
    } catch (e) {
      emit(TurmaManagementFailure(e.toString()));
    }
  }

  Future<void> deleteTurma({
    required String id,
    required String esporteId,
    required String categoria,
  }) async {
    try {
      await _turmaRepository.deleteTurma(id: id);
      fetchTurmas(esporteId: esporteId, categoria: categoria);
    } catch (e) {
      print('Erro ao deletar turma: $e');
    }
  }
}
