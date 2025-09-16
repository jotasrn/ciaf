import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/category_model.dart';

abstract class CategoryManagementState extends Equatable {
  const CategoryManagementState();
  @override
  List<Object> get props => [];
}

class CategoryManagementInitial extends CategoryManagementState {}

class CategoryManagementLoading extends CategoryManagementState {}

class CategoryManagementSuccess extends CategoryManagementState {
  final List<CategoryModel> categorias;
  const CategoryManagementSuccess(this.categorias);
  @override
  List<Object> get props => [categorias];
}

class CategoryManagementFailure extends CategoryManagementState {
  final String message;
  const CategoryManagementFailure(this.message);
  @override
  List<Object> get props => [message];
}