import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/admin_home_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/user_list_screen.dart';
import 'package:escolinha_futebol_app/features/aluno_dashboard/screens/aluno_home_screen.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_cubit.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_state.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/screens/professor_home_screen.dart';
import 'package:escolinha_futebol_app/features/shell_dashboard/cubit/navigation_cubit.dart';
import 'package:escolinha_futebol_app/features/shell_dashboard/widgets/side_menu.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_cubit.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      // Fallback de segurança: se o estado não for autenticado, mostra um loader.
      // O roteador principal em main.dart já deve prevenir isso.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final UserModel user = authState.user;
    final List<Widget> pages = _getPagesForProfile(user.perfil);

    // Providencia o NavigationCubit para a árvore de widgets abaixo dele.
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Define o ponto de quebra para o layout responsivo.
          // Acima de 800 pixels de largura, o menu lateral é fixo.
          bool isDesktop = constraints.maxWidth > 800;

          return Scaffold(
            // No mobile, mostra um AppBar com o botão de menu (hambúrguer).
            appBar: isDesktop
                ? null
                : AppBar(
              title: const Text('Escolinha de Futebol'),
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
                      // Garante que o índice não esteja fora dos limites da lista.
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
  /// A ordem das telas deve corresponder à ordem dos itens no SideMenuWidget.
  List<Widget> _getPagesForProfile(String perfil) {
    switch (perfil) {
      case 'admin':
        return [
          // Página 0 (Dashboard)
          const AdminHomeScreen(),

          // Página 1 (Usuários) - Precisa do UserManagementCubit
          BlocProvider(
            create: (context) => UserManagementCubit(
              RepositoryProvider.of<UserRepository>(context),
            ),
            child: const UserListScreen(),
          ),

          // Página 2 (Turmas) - Placeholder
          const Center(child: Text('Tela de Turmas (Em construção)')),

          // Página 3 (Relatórios) - Placeholder
          const Center(child: Text('Tela de Relatórios (Em construção)')),
        ];
      case 'professor':
        return [
          const ProfessorHomeScreen(),
          const Center(child: Text('Tela de Chamada (Em construção)')),
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