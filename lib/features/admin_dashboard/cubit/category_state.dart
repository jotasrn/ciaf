// lib/features/admin_dashboard/cubit/category_state.dart

import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/category_model.dart';

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

