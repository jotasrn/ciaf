import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/chamada_state.dart';
import 'package:escolinha_futebol_app/core/models/aluno_chamada_model.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/screens/chamada_screen.dart';

class ChamadaCubit extends Cubit<ChamadaState> {
  final AulaRepository _aulaRepository;
  ChamadaCubit(this._aulaRepository) : super(ChamadaInitial());

  Future<void> fetchAlunos(String aulaId) async {
    emit(ChamadaLoading());
    try {
      final alunos = await _aulaRepository.getAlunosDaAula(aulaId);
      emit(ChamadaSuccess(alunos));
    } catch (e) {
      emit(ChamadaFailure(e.toString()));
    }
  }

  void marcarPresenca(String alunoId, StatusPresenca status) {
    if (state is ChamadaSuccess) {
      final currentState = state as ChamadaSuccess;
      final updatedAlunos = currentState.alunos.map((aluno) {
        if (aluno.id == alunoId) {
          return aluno.copyWith(status: status);
        }
        return aluno;
      }).toList();
      emit(ChamadaSuccess(updatedAlunos));
    }
  }

  Future<void> submeterChamada(String aulaId) async {
    if (state is ChamadaSuccess) {
      emit(ChamadaSubmitting());
      try {
        final currentState = state as ChamadaSuccess;
        // Filtra apenas os alunos que tiveram o status alterado
        final presencasParaEnviar = currentState.alunos
            .where((aluno) => aluno.status != StatusPresenca.pendente)
            .map((aluno) => {
          'aluno_id': aluno.id,
          'status': aluno.status.toString().split('.').last, // Converte enum para string
        })
            .toList();

        if (presencasParaEnviar.isEmpty) {
          emit(ChamadaSubmitSuccess()); // Nada a enviar
          return;
        }

        await _aulaRepository.submeterChamada(aulaId, presencasParaEnviar);
        emit(ChamadaSubmitSuccess());
      } catch (e) {
        emit(ChamadaFailure(e.toString()));
      }
    }
  }
}