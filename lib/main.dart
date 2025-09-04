import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/app/theme.dart';
import 'package:escolinha_futebol_app/core/repositories/auth_repository.dart';
import 'package:escolinha_futebol_app/core/services/api_service.dart';
import 'package:escolinha_futebol_app/core/services/local_storage_service.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_cubit.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_state.dart';
import 'package:escolinha_futebol_app/features/auth/screens/login_screen.dart';
import 'package:escolinha_futebol_app/features/auth/screens/splash_screen.dart';
import 'package:escolinha_futebol_app/features/shell_dashboard/screens/shell_screen.dart';

void main() {
  // 1. Instanciamos nossas classes de baixo para cima
  final localStorageService = LocalStorageService();
  final apiService = ApiService(localStorageService);
  final authRepository = AuthRepository(apiService, localStorageService);

  runApp(
    // 2. Providenciamos as instâncias para a árvore de widgets
    RepositoryProvider(
      create: (context) => authRepository,
      child: BlocProvider(
        create: (context) => AuthCubit(context.read<AuthRepository>())
          ..appStarted(), // 3. Disparamos a verificação inicial
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escolinha de Futebol',
      theme: AppTheme.temaClaro,
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          // 4. Reagimos ao estado da autenticação para mostrar a tela certa
          if (state is AuthAuthenticated) {
            return const ShellScreen();
          }
          if (state is AuthUnauthenticated || state is AuthFailure) {
            return const LoginScreen();
          }
          // Por padrão (AuthUnknown), mostramos uma tela de loading
          return const SplashScreen();
        },
      ),
    );
  }
}