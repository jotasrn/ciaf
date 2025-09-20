import 'package:bloc/bloc.dart';
import 'package:escolinha_futebol_app/core/models/aluno_chamada_model.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/chamada_state.dart';

class ChamadaCubit extends Cubit<ChamadaState> {
  final AulaRepository _aulaRepository;

  ChamadaCubit(this._aulaRepository) : super(const ChamadaInitial());

  Future<void> fetchAlunos(String aulaId) async {
    emit(const ChamadaLoading());
    try {
      final aulaDetails = await _aulaRepository.getAulaDetails(aulaId);
      emit(ChamadaSuccess(
        alunos: aulaDetails.alunos,
        aulaData: aulaDetails.data,
      ));
    } catch (e) {
      emit(ChamadaFailure(e.toString()));
    }
  }

  void marcarPresenca(String alunoId, StatusPresenca status) {
    final currentState = state;
    if (currentState is ChamadaSuccess) {
      final updatedAlunos = currentState.alunos.map((aluno) {
        if (aluno.id == alunoId) {
          return aluno.copyWith(status: status);
        }
        return aluno;
      }).toList();
      emit(ChamadaSuccess(
          alunos: updatedAlunos, aulaData: currentState.aulaData));
    }
  }

  Future<void> submeterChamada(String aulaId) async {
    final currentState = state;
    if (currentState is ChamadaSuccess) {
      emit(ChamadaSubmitting(
          alunos: currentState.alunos, aulaData: currentState.aulaData));
      try {
        final presencas = currentState.alunos
            .map((aluno) => {
          'aluno_id': aluno.id,
          'status': aluno.status.toString().split('.').last,
        })
            .toList();
        await _aulaRepository.submeterChamada(aulaId, presencas);
        emit(const ChamadaSubmitSuccess());
      } catch (e) {
        emit(ChamadaFailure(e.toString()));
      }
    }
  }

  Future<void> editarPresencaAluno({
    required String aulaId,
    required String alunoId,
    required StatusPresenca novoStatus,
  }) async {
    final currentState = state;
    if (currentState is ChamadaSuccess) {
      try {
        await _aulaRepository.marcarPresenca(
          aulaId: aulaId,
          alunoId: alunoId,
          status: novoStatus,
        );

        final alunosAtualizados = currentState.alunos.map((aluno) {
          if (aluno.id == alunoId) {
            return aluno.copyWith(status: novoStatus);
          }
          return aluno;
        }).toList();

        emit(ChamadaSuccess(
            alunos: alunosAtualizados, aulaData: currentState.aulaData));
      } catch (e) {
        emit(ChamadaFailure('Falha ao salvar: ${e.toString().replaceAll('Exception: ', '')}'));
      }
    }
  }
}

