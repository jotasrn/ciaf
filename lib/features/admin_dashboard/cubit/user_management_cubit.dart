import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_state.dart';

class UserManagementCubit extends Cubit<UserManagementState> {
  final UserRepository _userRepository;
  Map<String, String>? _lastFilters; // Guarda o último filtro usado

  UserManagementCubit(this._userRepository) : super(UserManagementInitial());

  Future<void> fetchUsers({Map<String, String>? filters}) async {
    _lastFilters = filters; // Salva o filtro atual
    emit(UserManagementLoading());
    try {
      final users = await _userRepository.getUsers(filters: filters);
      emit(UserManagementSuccess(users));
    } catch (e) {
      emit(UserManagementFailure(e.toString()));
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      await _userRepository.createUser(userData);
      fetchUsers(filters: _lastFilters); // Recarrega com o último filtro
    } catch (e) {
      emit(UserManagementFailure(e.toString()));
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _userRepository.updateUser(userId, userData);
      fetchUsers(filters: _lastFilters); // Recarrega com o último filtro
    } catch (e) {
      emit(UserManagementFailure(e.toString()));
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _userRepository.deleteUser(userId);
      fetchUsers(filters: _lastFilters); // Recarrega com o último filtro
    } catch (e) {
      emit(UserManagementFailure(e.toString()));
    }
  }

  Future<void> updatePaymentStatus(String userId, String status) async {
    try {
      await _userRepository.updateUserPaymentStatus(userId, status);
      fetchUsers(filters: _lastFilters); // Recarrega com o último filtro
    } catch (e) {
      emit(UserManagementFailure(e.toString()));
    }
  }
}
