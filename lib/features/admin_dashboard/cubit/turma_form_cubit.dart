import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart'; // Importe o TurmaModel
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_form_state.dart';

class TurmaFormCubit extends Cubit<TurmaFormState> {
  final TurmaRepository _turmaRepository;
  final UserRepository _userRepository;

  TurmaFormCubit(this._turmaRepository, this._userRepository) : super(TurmaFormInitial());

  Future<void> loadInitialData(TurmaModel? turma) async {
    emit(TurmaFormLoading());
    try {
      final results = await Future.wait([
        _userRepository.getProfessores(),
        _userRepository.getAlunos(),
      ]);
      emit(TurmaFormDataReady(
        professores: results[0],
        alunos: results[1],
        turmaExistente: turma,
      ));
    } catch (e) {
      emit(TurmaFormFailure(e.toString()));
    }
  }

  Future<void> submitTurma(Map<String, dynamic> data, String? turmaId) async {
    emit(TurmaFormSubmitting());
    try {
      if (turmaId == null) {
        await _turmaRepository.createTurma(data);
      } else {
        await _turmaRepository.updateTurma(turmaId, data);
      }
      emit(TurmaFormSuccess());
    } catch (e) {
      emit(TurmaFormFailure(e.toString()));
    }
  }
}