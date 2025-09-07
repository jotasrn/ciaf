import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/category_model.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';

// Estados
abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategorySuccess extends CategoryState {
  final List<CategoryModel> categorias;
  const CategorySuccess(this.categorias);
  @override
  List<Object> get props => [categorias];
}

class CategoryFailure extends CategoryState {
  final String message;
  const CategoryFailure(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
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
    try {
      await _turmaRepository.createCategoria(nome: nome, esporteId: esporteId);
      // Após criar, busca a lista atualizada para a UI refletir a mudança
      fetchCategorias(esporteId);
    } catch (e) {
      // Poderíamos emitir um estado de erro aqui para mostrar na UI
      print('Erro ao criar categoria: $e');
    }
  }
}
