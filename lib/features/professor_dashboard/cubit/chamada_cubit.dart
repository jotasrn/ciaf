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
      final alunos = await _aulaRepository.getAlunosParaChamada(aulaId);
      emit(ChamadaSuccess(alunos: alunos));
    } catch (e) {
      emit(ChamadaFailure(message: e.toString().replaceAll('Exception: ', '')));
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
        // ✅ CORREÇÃO: Chama o método que agora existe no repositório.
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

        // ✅ CORREÇÃO: Usa o construtor nomeado correto.
        emit(ChamadaSuccess(alunos: alunosAtualizados));
      } catch (e) {
        // ✅ CORREÇÃO: Usa o construtor nomeado correto.
        emit(ChamadaFailure(
            message:
                'Falha ao salvar: ${e.toString().replaceAll('Exception: ', '')}'));
      }
    }
  }
}
