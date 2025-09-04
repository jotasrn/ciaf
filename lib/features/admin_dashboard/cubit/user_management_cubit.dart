import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_state.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';

class UserManagementCubit extends Cubit<UserManagementState> {
  final UserRepository _userRepository;

  UserManagementCubit(this._userRepository) : super(UserManagementInitial());

  Future<void> fetchUsers() async {
    emit(UserManagementLoading());
    try {
      final users = await _userRepository.getUsers();
      emit(UserManagementSuccess(users));
    } catch (e) {
      emit(UserManagementFailure(e.toString()));
    }
  }
}