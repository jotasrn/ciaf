import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/aula_resumo_model.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/dashboard_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;
  final AulaRepository _aulaRepository;

  DashboardCubit(this._dashboardRepository, this._aulaRepository) : super(DashboardInitial());

  Future<void> fetchSummary() async {
    emit(DashboardLoading());
    try {
      final results = await Future.wait([
        _dashboardRepository.getSummaryData(),
        _aulaRepository.getAulasPorData(DateTime.now()),
      ]);

      final summary = results[0] as Map<String, dynamic>;
      final aulas = results[1] as List<AulaResumoModel>;

      emit(DashboardSuccess(
        totalAlunos: summary['total_alunos'] ?? 0,
        totalTurmas: summary['total_turmas'] ?? 0,
        totalNaoPagantes: summary['total_nao_pagantes'] ?? 0,
        aulasDoDia: aulas,
      ));
    } catch (e) {
      emit(DashboardFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}