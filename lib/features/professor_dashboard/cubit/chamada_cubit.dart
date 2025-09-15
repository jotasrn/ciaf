import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/chamada_state.dart';
import 'package:escolinha_futebol_app/core/models/aluno_chamada_model.dart';

class ChamadaCubit extends Cubit<ChamadaState> {
  final AulaRepository _aulaRepository;
  ChamadaCubit(this._aulaRepository) : super(ChamadaInitial());

  Future<void> fetchAlunos(String aulaId) async {
    emit(ChamadaLoading());
    try {
      final aulaDetails = await _aulaRepository.getAulaDetails(aulaId);
      emit(ChamadaSuccess(aulaDetails.alunos, aulaDetails.data));
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
      emit(ChamadaSuccess(updatedAlunos, currentState.aulaData));
    }
  }

  Future<void> submeterChamada(String aulaId) async {
    final currentState = state;
    if (currentState is ChamadaSuccess) {
      emit(ChamadaSubmitting());
      try {
        final presencasParaEnviar = currentState.alunos
            .where((aluno) => aluno.status != StatusPresenca.pendente)
            .map((aluno) => {
          'aluno_id': aluno.id,
          'status': aluno.status.toString().split('.').last,
        })
            .toList();

        if (presencasParaEnviar.isEmpty) {
          emit(ChamadaSubmitSuccess());
          return;
        }

        await _aulaRepository.submeterChamada(aulaId, presencasParaEnviar);
        emit(ChamadaSubmitSuccess());
      } catch (e) {
        // Em caso de erro, retorna para a tela anterior com os dados
        emit(ChamadaFailure(e.toString()));
        emit(currentState); // Re-emite o estado de sucesso para a UI se recuperar
      }
    }
  }

  Future<void> editarPresencaAluno({
    required String aulaId,
    required String alunoId,
    required StatusPresenca novoStatus,
  }) async {
    // Não precisa de estado de loading para uma ação rápida
    try {
      // Cria o payload para enviar para a API
      final presencaData = [{
        'aluno_id': alunoId,
        'status': novoStatus.toString().split('.').last,
      }];

      // Chama a mesma API de submissão, que faz um "upsert" (cria ou atualiza)
      await _aulaRepository.submeterChamada(aulaId, presencaData);

      // Recarrega a lista para garantir que a UI está 100% atualizada
      // com os dados do servidor.
      await fetchAlunos(aulaId);
    } catch (e) {
      emit(ChamadaFailure(e.toString()));
    }
  }
}