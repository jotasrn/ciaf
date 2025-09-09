import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/core/repositories/sport_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/sport_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/admin_home_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/sport_list_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/turma_list_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/user_list_screen.dart';
import 'package:escolinha_futebol_app/features/aluno_dashboard/screens/aluno_home_screen.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_cubit.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_state.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/screens/professor_home_screen.dart';
import 'package:escolinha_futebol_app/features/shell_dashboard/cubit/navigation_cubit.dart';
import 'package:escolinha_futebol_app/features/shell_dashboard/widgets/side_menu.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      // Fallback de segurança: se o estado não for autenticado, mostra um loader.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final UserModel user = authState.user;
    final List<Widget> pages = _getPagesForProfile(context, user.perfil);

    // Providencia o NavigationCubit para a árvore de widgets abaixo dele.
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;

          return Scaffold(
            appBar: isDesktop
                ? null
                : AppBar(
              title: const Text('Escolinha de Futebol'),
            ),
            drawer: isDesktop ? null : SideMenuWidget(user: user),
            body: Row(
              children: [
                if (isDesktop) SideMenuWidget(user: user),
                Expanded(
                  child: BlocBuilder<NavigationCubit, int>(
                    builder: (context, pageIndex) {
                      if (pageIndex >= pages.length) return pages[0];
                      return pages[pageIndex];
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Retorna a lista de telas (páginas) com base no perfil do usuário.
  List<Widget> _getPagesForProfile(BuildContext context, String perfil) {
    switch (perfil) {
      case 'admin':
        return [
          const AdminHomeScreen(),
          BlocProvider(
            create: (context) => UserManagementCubit(
              RepositoryProvider.of<UserRepository>(context),
            ),
            child: const UserListScreen(),
          ),
          const TurmaListScreen(),
          BlocProvider(
            create: (context) => SportCubit(
              RepositoryProvider.of<SportRepository>(context),
            ),
            child: const SportListScreen(),
          ),
        ];
      case 'professor':
        return [
          const ProfessorHomeScreen(),
        ];
      case 'aluno':
      default:
        return [
          const AlunoHomeScreen(),
          const Center(child: Text('Tela de Horários (Em construção)')),
        ];
    }
  }
}

