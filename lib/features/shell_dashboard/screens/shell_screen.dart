import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/admin_home_screen.dart';
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
    // Pega o estado de autenticação para obter os dados do usuário
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      // Se por algum motivo chegar aqui sem estar autenticado, mostra um loader
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final UserModel user = authState.user;
    final List<Widget> pages = _getPagesForProfile(user.perfil);

    // Providencia o NavigationCubit para a árvore de widgets abaixo dele
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Define o ponto de quebra para o layout responsivo
          bool isDesktop = constraints.maxWidth > 800;

          return Scaffold(
            // No mobile, mostra um AppBar com o botão de menu (hambúrguer)
            appBar: isDesktop
                ? null
                : AppBar(
              title: const Text('Escolinha de Futebol'),
            ),
            // No mobile, o menu fica na "gaveta" (drawer)
            drawer: isDesktop ? null : SideMenuWidget(user: user),
            body: Row(
              children: [
                // No desktop, o menu é fixo e visível à esquerda
                if (isDesktop) SideMenuWidget(user: user),
                // O conteúdo principal que muda de acordo com a seleção no menu
                Expanded(
                  child: BlocBuilder<NavigationCubit, int>(
                    builder: (context, pageIndex) {
                      // Garante que o índice não esteja fora dos limites
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

  // Retorna a lista de telas (páginas) com base no perfil do usuário
  List<Widget> _getPagesForProfile(String perfil) {
    switch (perfil) {
      case 'admin':
        return [
          const UserListScreen(),
          const Center(child: Text('Tela de Turmas (Em construção)')),
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