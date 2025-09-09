import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_detail_state.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/models/aula_resumo_model.dart';

class TurmaDetailCubit extends Cubit<TurmaDetailState> {
  final TurmaRepository _turmaRepository;
  final AulaRepository _aulaRepository;

  TurmaDetailCubit(this._turmaRepository, this._aulaRepository) : super(TurmaDetailInitial());

  Future<void> fetchTurmaDetails(String turmaId) async {
    emit(TurmaDetailLoading());
    try {
      // Busca os dois conjuntos de dados em paralelo para mais performance
      final results = await Future.wait([
        _turmaRepository.getTurmaById(turmaId), // Precisaremos criar este método
        _aulaRepository.getAulasPorTurma(turmaId),
      ]);

      final turma = results[0] as TurmaModel;
      final aulas = results[1] as List<AulaResumoModel>;

      emit(TurmaDetailSuccess(turma: turma, aulas: aulas));
    } catch (e) {
      emit(TurmaDetailFailure(e.toString()));
    }
  }

  Future<void> agendarAulas(String turmaId) async {
    // Não emite 'loading' para não piscar a tela
    try {
      // 1. Chama a API para agendar as aulas
      await _aulaRepository.agendarAulas(turmaId);

      // 2. Emite o novo estado de SUCESSO DA AÇÃO com uma mensagem
      emit(const TurmaDetailActionSuccess('Aulas agendadas com sucesso!'));

      // 3. Busca novamente os detalhes para atualizar a lista de aulas na tela
      await fetchTurmaDetails(turmaId);
    } catch (e) {
      emit(TurmaDetailFailure(e.toString()));
    }
  }
}