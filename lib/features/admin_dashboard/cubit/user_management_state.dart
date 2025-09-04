import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';

abstract class UserManagementState extends Equatable {
  const UserManagementState();
  @override
  List<Object> get props => [];
}

class UserManagementInitial extends UserManagementState {}
class UserManagementLoading extends UserManagementState {}
class UserManagementSuccess extends UserManagementState {
  final List<UserModel> users;
  const UserManagementSuccess(this.users);
  @override
  List<Object> get props => [users];
}
class UserManagementFailure extends UserManagementState {
  final String message;
  const UserManagementFailure(this.message);
  @override
  List<Object> get props => [message];
}