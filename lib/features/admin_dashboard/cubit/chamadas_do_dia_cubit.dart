import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/aula_resumo_model.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
// Importe o arquivo de estado
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/chamadas_do_dia_state.dart';

// A definição dos estados NÃO deve estar aqui.

// Cubit
class ChamadasDoDiaCubit extends Cubit<ChamadasDoDiaState> {
  final AulaRepository _aulaRepository;
  ChamadasDoDiaCubit(this._aulaRepository) : super(ChamadasDoDiaInitial());

  Future<void> fetchChamadas({DateTime? data}) async {
    emit(ChamadasDoDiaLoading());
    try {
      final dataParaBuscar = data ?? DateTime.now();
      final aulas = await _aulaRepository.getAulasPorData(dataParaBuscar);
      emit(ChamadasDoDiaSuccess(aulas, dataParaBuscar));
    } catch (e) {
      emit(ChamadasDoDiaFailure(e.toString()));
    }
  }
}