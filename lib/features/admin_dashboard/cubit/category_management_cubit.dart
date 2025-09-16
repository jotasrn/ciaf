import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/category_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/category_management_state.dart';

class CategoryManagementCubit extends Cubit<CategoryManagementState> {
  final CategoryRepository _repository;
  CategoryManagementCubit(this._repository) : super(CategoryManagementInitial());

  /// Busca a lista completa de categorias
  Future<void> fetchCategorias() async {
    emit(CategoryManagementLoading());
    try {
      final categorias = await _repository.getTodasCategorias();
      emit(CategoryManagementSuccess(categorias));
    } catch (e) {
      emit(CategoryManagementFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Deleta uma categoria e recarrega a lista
  Future<void> deleteCategoria(String id) async {
    try {
      await _repository.deleteCategoria(id: id);
      fetchCategorias();
    } catch (e) {
      emit(CategoryManagementFailure(e.toString().replaceAll('Exception: ', '')));
      // Para garantir que a lista ainda seja exibida mesmo após um erro de delete,
      // podemos recarregar os dados.
      fetchCategorias();
    }
  }

// No futuro, podemos adicionar os métodos de criar e atualizar aqui.
}