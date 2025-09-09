import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/sport_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/sport_state.dart';

class SportCubit extends Cubit<SportState> {
  final SportRepository _sportRepository;
  SportCubit(this._sportRepository) : super(SportInitial());

  Future<void> fetchSports() async {
    emit(SportLoading());
    try {
      final sports = await _sportRepository.getSports();
      emit(SportLoadSuccess(sports));
    } catch (e) {
      emit(SportFailure(e.toString()));
    }
  }

  Future<void> createSport({required String nome}) async {
    try {
      await _sportRepository.createSport(nome: nome);
      fetchSports(); // Recarrega a lista após criar
    } catch (e) {
      emit(SportFailure(e.toString()));
    }
  }

  Future<void> updateSport({required String id, required String nome}) async {
    try {
      await _sportRepository.updateSport(id: id, nome: nome);
      fetchSports();
    } catch (e) {
      emit(SportFailure(e.toString()));
    }
  }

  Future<void> deleteSport({required String id}) async {
    try {
      await _sportRepository.deleteSport(id: id);
      fetchSports();
    } catch (e) {
      emit(SportFailure(e.toString()));
    }
  }
}

