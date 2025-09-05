import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/dashboard_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;
  DashboardCubit(this._dashboardRepository) : super(DashboardInitial());

  Future<void> fetchSummary() async {
    emit(DashboardLoading());
    try {
      final summary = await _dashboardRepository.getSummaryData();
      emit(DashboardSuccess(
        totalAlunos: summary['total_alunos'] ?? 0,
        totalTurmas: summary['total_turmas'] ?? 0,
        totalNaoPagantes: summary['total_nao_pagantes'] ?? 0,
      ));
    } catch (e) {
      emit(DashboardFailure(e.toString()));
    }
  }
}