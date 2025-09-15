import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/admin_home_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/sport_list_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/turma_list_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/aluno_list_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/admin_prof_list_screen.dart';
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final UserModel user = authState.user;

    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pageTitles = _getPageTitlesForProfile(user.perfil);
          final pages = _getPagesForProfile(user.perfil);
          bool isDesktop = constraints.maxWidth > 800;

          return Scaffold(
            appBar: isDesktop ? null : AppBar(
              title: BlocBuilder<NavigationCubit, int>(
                builder: (context, pageIndex) => Text(pageTitles[pageIndex]),
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
        return ['Dashboard', 'Usuários', 'Alunos', 'Turmas', 'Esportes'];
      case 'professor':
        return ['Minhas Turmas'];
      default:
        return ['Minha Turma'];
    }
  }

  List<Widget> _getPagesForProfile(String perfil) {
    switch (perfil) {
      case 'admin':
        return [
          const AdminHomeScreen(),
          const AdminProfListScreen(),
          const AlunoListScreen(),
          const TurmaListScreen(title: 'Todas as Turmas'),
          const SportListScreen(),
        ];
      case 'professor':
        return [const ProfessorHomeScreen()];
      default:
        return [const AlunoHomeScreen()];
    }
  }
}