import 'package:equatable/equatable.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthUnknown extends AuthState {}        // Estado inicial, enquanto verificamos o token
class AuthUnauthenticated extends AuthState {}  // Confirmado que não há usuário logado
class AuthLoading extends AuthState {}        // Tentando fazer login
class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated({required this.user});
  @override
  List<Object?> get props => [user];
}
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure({required this.message});
  @override
  List<Object?> get props => [message];
}