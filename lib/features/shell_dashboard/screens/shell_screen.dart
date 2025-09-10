import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/admin_home_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/turma_list_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/sport_list_screen.dart';
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
    // Pega o estado de autenticação para obter os dados do usuário.
    final authState = context.watch<AuthCubit>().state;

    // Um fallback de segurança, embora o roteador principal em main.dart deva prevenir isso.
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final UserModel user = authState.user;
    // Pega a lista de telas e títulos com base no perfil do usuário.
    final List<Widget> pages = _getPagesForProfile(user.perfil);
    final List<String> pageTitles = _getPageTitlesForProfile(user.perfil);

    // Providencia o NavigationCubit para a árvore de widgets abaixo dele.
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Define o ponto de quebra para o layout responsivo.
          bool isDesktop = constraints.maxWidth > 800;

          return Scaffold(
            appBar: isDesktop
                ? null // Sem AppBar no layout de desktop.
                : AppBar(
              // O título é construído com base no estado do NavigationCubit.
              title: BlocBuilder<NavigationCubit, int>(
                builder: (context, pageIndex) {
                  if (pageIndex >= pageTitles.length) return const Text('');
                  return Text(pageTitles[pageIndex]);
                },
              ),
            ),
            // No mobile, o menu fica na "gaveta" (drawer).
            drawer: isDesktop ? null : SideMenuWidget(user: user),
            body: Row(
              children: [
                // No desktop, o menu é fixo e visível à esquerda.
                if (isDesktop) SideMenuWidget(user: user),

                // O conteúdo principal que muda de acordo com a seleção no menu.
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

  /// Retorna a lista de TÍTULOS que deve corresponder à ordem da lista de PÁGINAS.
  List<String> _getPageTitlesForProfile(String perfil) {
    switch (perfil) {
      case 'admin':
        return [
          'Dashboard',
          'Gerenciar Usuários',
          'Gerenciar Turmas',
          'Gerenciar Esportes',
        ];
      case 'professor':
        return ['Minhas Turmas'];
      case 'aluno':
      default:
        return ['Minha Turma'];
    }
  }

  /// Retorna a lista de PÁGINAS (Widgets) com base no perfil do usuário.
  List<Widget> _getPagesForProfile(String perfil) {
    switch (perfil) {
      case 'admin':
        return [
          const AdminHomeScreen(),
          const UserListScreen(),
          const TurmaListScreen(),
          const SportListScreen(),
        ];
      case 'professor':
        return [
          const ProfessorHomeScreen(),
        ];
      case 'aluno':
      default:
        return [
          const AlunoHomeScreen(),
        ];
    }
  }
}