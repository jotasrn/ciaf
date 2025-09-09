import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
// Reutilizamos o mesmo arquivo de estado, pois a estrutura de dados é a mesma
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/chamadas_do_dia_state.dart';

class AulaSelectionCubit extends Cubit<ChamadasDoDiaState> {
  final AulaRepository _aulaRepository;

  AulaSelectionCubit(this._aulaRepository) : super(ChamadasDoDiaInitial());

  /// Busca apenas as aulas associadas a um ID de turma específico.
  Future<void> fetchAulasDaTurma(String turmaId) async {
    emit(ChamadasDoDiaLoading());
    try {
      final aulas = await _aulaRepository.getAulasPorTurma(turmaId);
      // Usamos o estado de sucesso, a data selecionada não é relevante aqui
      // mas o estado exige, então passamos a data atual.
      emit(ChamadasDoDiaSuccess(aulas, DateTime.now()));
    } catch (e) {
      emit(ChamadasDoDiaFailure(e.toString()));
    }
  }
}