import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/app/theme.dart';
import 'package:escolinha_futebol_app/core/repositories/auth_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/core/services/api_service.dart';
import 'package:escolinha_futebol_app/core/services/local_storage_service.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_cubit.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_state.dart';
import 'package:escolinha_futebol_app/features/auth/screens/login_screen.dart';
import 'package:escolinha_futebol_app/features/auth/screens/splash_screen.dart';
import 'package:escolinha_futebol_app/features/shell_dashboard/screens/shell_screen.dart';

void main() {
  final localStorageService = LocalStorageService();
  final apiService = ApiService(localStorageService);
  final authRepository = AuthRepository(apiService, localStorageService);
  final userRepository = UserRepository(apiService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: userRepository),
      ],
      child: BlocProvider(
        create: (context) =>
            AuthCubit(context.read<AuthRepository>())..appStarted(),
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
          if (state is AuthAuthenticated) {
            return const ShellScreen();
          }
          if (state is AuthUnauthenticated || state is AuthFailure) {
            return const LoginScreen();
          }
          return const SplashScreen();
        },
      ),
    );
  }
}
