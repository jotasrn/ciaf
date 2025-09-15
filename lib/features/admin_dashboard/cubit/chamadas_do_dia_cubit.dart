import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/chamadas_do_dia_state.dart';

// Cubit
class ChamadasDoDiaCubit extends Cubit<ChamadasDoDiaState> {
  final AulaRepository _aulaRepository;
  ChamadasDoDiaCubit(this._aulaRepository) : super(ChamadasDoDiaInitial());

  Future<void> fetchChamadas({DateTime? data}) async {
    emit(ChamadasDoDiaLoading());
    try {
      // Usa a data fornecida ou a data de hoje
      final dataParaBuscar = data ?? DateTime.now();
      final aulas = await _aulaRepository.getAulasPorData(dataParaBuscar);
      emit(ChamadasDoDiaSuccess(aulas, dataParaBuscar));
    } catch (e) {
      emit(ChamadasDoDiaFailure(e.toString()));
    }
  }
}
