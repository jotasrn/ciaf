import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/auth_repository.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthUnknown());

  // Função para ser chamada quando o app inicia
  Future<void> appStarted() async {
    try {
      final user = await _authRepository.tryAutoLogin();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email, password);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      // PRINT 5: O erro chegou até o Cubit?
      print('DEBUG: ERRO CAPTURADO PELO CUBIT: $e');
      emit(AuthFailure(message: e.toString()));
      // Após a falha, voltamos para o estado deslogado
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
