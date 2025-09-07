// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:escolinha_futebol_app/app/theme.dart';
import 'package:escolinha_futebol_app/core/repositories/auth_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/dashboard_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/core/services/api_service.dart';
import 'package:escolinha_futebol_app/core/services/local_storage_service.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_cubit.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_state.dart';
import 'package:escolinha_futebol_app/features/auth/screens/login_screen.dart';
import 'package:escolinha_futebol_app/features/auth/screens/splash_screen.dart';
import 'package:escolinha_futebol_app/features/shell_dashboard/screens/shell_screen.dart';

void main() {
  // Garante que os bindings do Flutter foram inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o pacote de formatação de datas para Português (Brasil)
  initializeDateFormatting('pt_BR', null).then((_) {
    // =======================================================================
    // INJEÇÃO DE DEPENDÊNCIA MANUAL
    // Criamos as instâncias únicas que serão usadas em todo o app.
    // =======================================================================
    final localStorageService = LocalStorageService();
    final apiService = ApiService(localStorageService);
    final authRepository = AuthRepository(apiService, localStorageService);
    final userRepository = UserRepository(apiService);
    final dashboardRepository = DashboardRepository(apiService);
    final aulaRepository = AulaRepository(apiService);
    final turmaRepository = TurmaRepository(apiService); // <-- Novo Repositório

    runApp(
      // =======================================================================
      // PROVIDERS
      // Disponibilizamos as instâncias para a árvore de widgets.
      // =======================================================================
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: authRepository),
          RepositoryProvider.value(value: userRepository),
          RepositoryProvider.value(value: dashboardRepository),
          RepositoryProvider.value(value: aulaRepository),
          RepositoryProvider.value(
              value: turmaRepository), // <-- Novo Repositório
        ],
        child: BlocProvider(
          create: (context) => AuthCubit(context.read<AuthRepository>())
            ..appStarted(), // Dispara a verificação de token na inicialização
          child: const MyApp(),
        ),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escolinha de Futebol',
      theme: AppTheme.temaClaro,
      debugShowCheckedModeBanner: false,

      // Configuração de Localização (Idioma)
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],

      // Roteamento inteligente baseado no estado de autenticação
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
