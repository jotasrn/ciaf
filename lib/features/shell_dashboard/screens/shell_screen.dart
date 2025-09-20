import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Imports de Repositórios
import 'package:escolinha_futebol_app/core/repositories/dashboard_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/sport_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';

// Imports de Cubits
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/dashboard_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/sport_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_cubit.dart';

// Imports do Auth e Navegação
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_cubit.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_state.dart';
import 'package:escolinha_futebol_app/features/shell_dashboard/cubit/navigation_cubit.dart';
import 'package:escolinha_futebol_app/features/shell_dashboard/widgets/side_menu.dart';

// Imports das Telas
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/admin_home_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/admin_prof_list_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/aluno_list_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/sport_list_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/turma_list_screen.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/screens/professor_home_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/category_list_screen.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final UserModel user = authState.user;

    // A lógica de criação de Cubits está aqui, no topo da ShellScreen
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavigationCubit()),
        // Provê todos os Cubits que o Admin pode precisar de uma só vez
        if (user.perfil == 'admin') ...[
          BlocProvider(
            create: (context) => DashboardCubit(
              context.read<DashboardRepository>(),
              context.read<AulaRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                UserManagementCubit(context.read<UserRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                TurmaManagementCubit(context.read<TurmaRepository>()),
          ),
          BlocProvider(
            create: (context) => SportCubit(context.read<SportRepository>()),
          ),
        ],
        // Adicione aqui os providers para Professor e Aluno se precisarem
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pageTitles = _getPageTitlesForProfile(user.perfil);
          final pages = _getPagesForProfile(user.perfil);
          bool isDesktop = constraints.maxWidth > 800;

          return Scaffold(
            appBar: isDesktop
                ? null
                : AppBar(
              title: BlocBuilder<NavigationCubit, int>(
                builder: (context, pageIndex) =>
                    Text(pageTitles[pageIndex]),
              ),
            ),
            drawer: isDesktop ? null : SideMenuWidget(user: user),
            body: Row(
              children: [
                if (isDesktop) SideMenuWidget(user: user),
                Expanded(
                  child: BlocBuilder<NavigationCubit, int>(
                    builder: (context, pageIndex) => pages[pageIndex],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _getPageTitlesForProfile(String perfil) {
    switch (perfil) {
      case 'admin':
        return ['Dashboard', 'Usuários', 'Alunos', 'Turmas', 'Esportes', 'Categorias'];
      case 'professor':
        return ['Minhas Turmas'];
      case 'aluno':
      default:
        return ['Minha Turma', 'Horários'];
    }
  }

  List<Widget> _getPagesForProfile(String perfil) {
    switch (perfil) {
      case 'admin':
        return [
          const AdminHomeScreen(),
          const AdminProfListScreen(),
          const AlunoListScreen(),
          const CategoryListScreen(),
          const TurmaListScreen(title: 'Gerenciar Turmas'),
          const SportListScreen(),
        ];
      case 'professor':
        return [const ProfessorHomeScreen()
        ];
      case 'aluno':
      default:
        return [
          const Center(child: Text('Dashboard do Aluno (Em construção)')),
        ];
    }
  }
}

