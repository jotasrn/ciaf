import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/user_form_dialog.dart';

class AdminProfListScreen extends StatelessWidget {
  const AdminProfListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserManagementCubit(
        RepositoryProvider.of<UserRepository>(context),
      )..fetchUsers(filters: {'perfil_ne': 'aluno'}),
      child: const _AdminProfListView(),
    );
  }
}

class _AdminProfListView extends StatelessWidget {
  const _AdminProfListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Admins e Professores')),
      body: BlocBuilder<UserManagementCubit, UserManagementState>(
        builder: (context, state) {
            if (state is UserManagementLoading || state is UserManagementInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is UserManagementFailure) {
              return Center(child: Text('Falha ao carregar: ${state.message}'));
            }
            if (state is UserManagementSuccess) {
              // Filtro aplicado na UI para mostrar apenas admins e professores
              final usuariosFiltrados =
              state.users.where((u) => u.perfil != 'aluno').toList();

              if (usuariosFiltrados.isEmpty) {
                return const Center(
                    child: Text('Nenhum admin ou professor encontrado.'));
              }

              return PaginatedDataTable2(
                columns: const [
                  DataColumn(label: Text('Nome Completo')),
                  DataColumn(label: Text('E-mail')),
                  DataColumn(label: Text('Perfil')),
                  DataColumn(label: Text('Ações')),
                ],
                source: _AdminProfDataSource(usuariosFiltrados, context),
                minWidth: 600,
                showCheckboxColumn: false,
              );
            }
            return const SizedBox.shrink();
        },
      ),
      floatingActionButton: Builder(
        builder: (buttonContext) {
          return FloatingActionButton(
            onPressed: () {
              showUserFormDialog(
                context: buttonContext,
                perfisPermitidos: ['admin', 'professor'], // <-- RESTRIÇÃO APLICADA
              ).then((_) {
                buttonContext.read<UserManagementCubit>().fetchUsers(filters: {'perfil_ne': 'aluno'});
              });
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

class _AdminProfDataSource extends DataTableSource {
  final List<UserModel> users;
  final BuildContext context;
  _AdminProfDataSource(this.users, this.context);

  @override
  DataRow2 getRow(int index) {
    final user = users[index];
    return DataRow2.byIndex(index: index, cells: [
      DataCell(Text(user.nome)),
      DataCell(Text(user.email)),
      DataCell(Chip(label: Text(user.perfil))),
      DataCell(PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'editar') {
            // A chamada de edição também passa a restrição de perfis
            showUserFormDialog(
              context: context,
              user: user,
              perfisPermitidos: ['admin', 'professor'], // <-- RESTRIÇÃO APLICADA
            ).then((_) {
              context.read<UserManagementCubit>().fetchUsers(filters: {'perfil_ne': 'aluno'});
            });
          } else if (value == 'desativar') {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Confirmar Ação'),
                content: Text(
                    'Tem certeza que deseja desativar o usuário ${user.nome}?'),
                actions: [
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                  TextButton(
                    child: const Text('Desativar',
                        style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      context.read<UserManagementCubit>().deleteUser(user.id);
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ],
              ),
            );
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'editar',
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Editar'),
            ),
          ),
          const PopupMenuItem(
            value: 'desativar',
            child: ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Desativar'),
            ),
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => users.length;
  @override
  int get selectedRowCount => 0;
}

