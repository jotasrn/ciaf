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
    // Usa a cor primária do tema que definimos
    final primaryColor = Theme.of(context).primaryColor;

    return Drawer(
      elevation: 4.0,
      backgroundColor: primaryColor, // Cor de fundo baseada no tema
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        children: [
          // Cabeçalho com dados do usuário
          UserAccountsDrawerHeader(
            accountName: Text(user.nome,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.nome.isNotEmpty ? user.nome[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 32, color: primaryColor),
              ),
            ),
            decoration: BoxDecoration(
              color: primaryColor,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _buildMenuItems(context, user.perfil),
            ),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white70),
            title: const Text('Sair', style: TextStyle(color: Colors.white70)),
            onTap: () {
              // Fecha o drawer antes de deslogar, se estiver no mobile
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.of(context).pop();
              }
              context.read<AuthCubit>().logout();
            },
          ),
          const SizedBox(height: 16),
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
          (title: 'Dashboard', icon: Icons.dashboard_outlined, index: 0),
          (title: 'Usuários', icon: Icons.group_outlined, index: 1),
          (title: 'Alunos', icon: Icons.school_outlined, index: 2),
          (title: 'Turmas', icon: Icons.sports_soccer_outlined, index: 3),
          (title: 'Esportes', icon: Icons.emoji_events_outlined, index: 4),
        ];
        break;
      case 'professor':
        items = [
          (title: 'Minhas Turmas', icon: Icons.list_alt_outlined, index: 0),
        ];
        break;
      case 'aluno':
      default:
        items = [
          (title: 'Minha Turma', icon: Icons.info_outline, index: 0),
          (title: 'Horários', icon: Icons.schedule_outlined, index: 1),
        ];
        break;
    }

    return items.map((item) {
      final isSelected = navCubit.state == item.index;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color:
          isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(item.icon, color: Colors.white),
          title: Text(item.title, style: const TextStyle(color: Colors.white)),
          onTap: () {
            context.read<NavigationCubit>().selectPage(item.index);
            // Fecha o drawer após a seleção no mobile
            if (Scaffold.of(context).isDrawerOpen) {
              Navigator.of(context).pop();
            }
          },
        ),
      );
    }).toList();
  }
}

