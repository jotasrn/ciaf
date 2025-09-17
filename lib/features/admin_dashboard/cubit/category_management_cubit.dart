import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/category_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/category_management_state.dart';

class CategoryManagementCubit extends Cubit<CategoryManagementState> {
  final CategoryRepository _repository;
  CategoryManagementCubit(this._repository) : super(CategoryManagementInitial());

  Future<void> fetchCategorias() async {
    emit(CategoryManagementLoading());
    try {
      final categorias = await _repository.getTodasCategorias();
      emit(CategoryManagementSuccess(categorias));
    } catch (e) {
      emit(CategoryManagementFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createCategoria(String nome, String esporteId) async {
    try {
      await _repository.createCategoria(nome: nome, esporteId: esporteId);
      fetchCategorias(); // Recarrega a lista
    } catch (e) {
      emit(CategoryManagementFailure(e.toString()));
    }
  }

  Future<void> updateCategoria(String id, String nome) async {
    try {
      await _repository.updateCategoria(id: id, nome: nome);
      fetchCategorias();
    } catch (e) {
      emit(CategoryManagementFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteCategoria(String id) async {
    try {
      await _repository.deleteCategoria(id: id);
      fetchCategorias();
    } catch (e) {
      emit(CategoryManagementFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}