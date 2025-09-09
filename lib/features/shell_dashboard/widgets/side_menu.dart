import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/features/auth/cubit/auth_cubit.dart';
import 'package:escolinha_futebol_app/features/shell_dashboard/cubit/navigation_cubit.dart';

class SideMenuWidget extends StatelessWidget {
  final UserModel user;
  const SideMenuWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.nome),
            accountEmail: Text(user.email),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
            decoration: const BoxDecoration(
              color: Colors.green,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _buildMenuItems(context, user.perfil),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              // Fecha o drawer antes de deslogar, se estiver no mobile
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.of(context).pop();
              }
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, String perfil) {
    final navCubit = context.watch<NavigationCubit>();
    List<({String title, IconData icon, int index})> items;

    switch (perfil) {
      case 'admin':
        items = [
          (title: 'Dashboard', icon: Icons.dashboard, index: 0),
          (title: 'Usuários', icon: Icons.group, index: 1),
          (title: 'Turmas', icon: Icons.sports_soccer, index: 2),
          (title: 'Esportes', icon: Icons.emoji_events, index: 3),
        ];
        break;
      case 'professor':
        items = [
          (title: 'Minhas Turmas', icon: Icons.list_alt, index: 0),
        ];
        break;
      case 'aluno':
      default:
        items = [
          (title: 'Minha Turma', icon: Icons.info_outline, index: 0),
          (title: 'Horários', icon: Icons.schedule, index: 1),
        ];
        break;
    }

    return items
        .map((item) => ListTile(
      leading: Icon(item.icon),
      title: Text(item.title),
      selected: navCubit.state == item.index,
      onTap: () {
        context.read<NavigationCubit>().selectPage(item.index);
        // Fecha o drawer após a seleção no mobile
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.of(context).pop();
        }
      },
    ))
        .toList();
  }
}

