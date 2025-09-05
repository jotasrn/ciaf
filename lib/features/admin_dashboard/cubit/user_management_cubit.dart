import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_state.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';

class UserManagementCubit extends Cubit<UserManagementState> {
  final UserRepository _userRepository;

  UserManagementCubit(this._userRepository) : super(UserManagementInitial());

  Future<void> fetchUsers({Map<String, String>? filters}) async {
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
      // Após criar com sucesso, buscamos a lista atualizada
      fetchUsers();
    } catch (e) {
      // Podemos emitir um estado de falha específico para o formulário no futuro
      print('Erro ao criar usuário: $e');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _userRepository.updateUser(userId, userData);
      fetchUsers();
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _userRepository.deleteUser(userId);
      fetchUsers();
    } catch (e) {
      print('Erro ao deletar usuário: $e');
    }
  }
}
