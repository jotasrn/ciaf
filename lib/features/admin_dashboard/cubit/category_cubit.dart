// lib/features/admin_dashboard/cubit/category_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final TurmaRepository _turmaRepository;

  CategoryCubit(this._turmaRepository) : super(CategoryInitial());

  Future<void> fetchCategorias(String esporteId) async {
    emit(CategoryLoading());
    try {
      final categorias = await _turmaRepository.getCategorias(esporteId);
      emit(CategorySuccess(categorias));
    } catch (e) {
      emit(CategoryFailure(e.toString()));
    }
  }

  Future<void> createCategoria({
    required String nome,
    required String esporteId,
  }) async {
    // Não emite 'loading' para não piscar a tela toda, a UI pode mostrar um loader no botão
    try {
      await _turmaRepository.createCategoria(nome: nome, esporteId: esporteId);
      // Após criar, busca a lista atualizada para a UI refletir a mudança
      await fetchCategorias(esporteId);
    } catch (e) {
      // Emite um estado de falha para a UI poder mostrar uma SnackBar
      emit(CategoryFailure(e.toString()));
    }
  }

  Future<void> updateCategoria({
    required String id,
    required String nome,
    required String esporteId,
  }) async {
    try {
      await _turmaRepository.updateCategoria(id: id, nome: nome);
      await fetchCategorias(esporteId); // Recarrega a lista
    } catch (e) {
      emit(CategoryFailure(e.toString()));
    }
  }

  Future<void> deleteCategoria({
    required String id,
    required String esporteId,
  }) async {
    try {
      await _turmaRepository.deleteCategoria(id: id);
      await fetchCategorias(esporteId); // Recarrega a lista
    } catch (e) {
      emit(CategoryFailure(e.toString()));
    }
  }
}