import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/user_form_screen.dart';

class UserListScreen extends StatelessWidget {
  final Map<String, String>? initialFilters;

  const UserListScreen({super.key, this.initialFilters});

  @override
  Widget build(BuildContext context) {
    // A tela agora cria seu próprio provider, tornando-a independente
    return BlocProvider(
      create: (context) => UserManagementCubit(
        RepositoryProvider.of<UserRepository>(context),
      )..fetchUsers(filters: initialFilters),
      child: const _UserListView(),
    );
  }
}

class _UserListView extends StatelessWidget {
  const _UserListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Usuários'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<UserManagementCubit, UserManagementState>(
          builder: (context, state) {
            if (state is UserManagementLoading || state is UserManagementInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is UserManagementFailure) {
              return Center(
                  child: Text('Falha ao carregar usuários: ${state.message}'));
            }
            if (state is UserManagementSuccess) {
              return PaginatedDataTable2(
                columns: const [
                  DataColumn(label: Text('Nome Completo')),
                  DataColumn(label: Text('E-mail')),
                  DataColumn(label: Text('Perfil')),
                  DataColumn(label: Text('Pagamento')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Ações')),
                ],
                source: UserDataSource(state.users, context),
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 800,
                showCheckboxColumn: false,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: Builder(
        builder: (buttonContext) {
          return FloatingActionButton(
            onPressed: () {
              Navigator.of(buttonContext)
                  .push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: BlocProvider.of<UserManagementCubit>(context),
                    child: const UserFormScreen(),
                  ),
                ),
              )
                  .then((_) {
                // Após o formulário fechar, recarrega a lista
                context.read<UserManagementCubit>().fetchUsers();
              });
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

class UserDataSource extends DataTableSource {
  final List<UserModel> users;
  final BuildContext context;
  UserDataSource(this.users, this.context);

  @override
  DataRow2 getRow(int index) {
    final user = users[index];
    return DataRow2.byIndex(
      index: index,
      cells: [
        DataCell(Text(user.nome)),
        DataCell(Text(user.email)),
        DataCell(Text(user.perfil)),
        DataCell(
          Switch(
            value: user.statusPagamento.status == 'pago',
            onChanged: (value) {
              final newStatus = value ? 'pago' : 'pendente';
              context
                  .read<UserManagementCubit>()
                  .updatePaymentStatus(user.id, newStatus);
            },
          ),
        ),
        DataCell(
          Chip(
            label: Text(user.ativo ? 'Ativo' : 'Inativo'),
            backgroundColor: user.ativo
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        DataCell(
          Row(
            children: [
              Builder(builder: (cellContext) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(cellContext)
                        .push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: BlocProvider.of<UserManagementCubit>(context),
                          child: UserFormScreen(user: user),
                        ),
                      ),
                    )
                        .then((_) {
                      // Recarrega a lista após a edição
                      context.read<UserManagementCubit>().fetchUsers();
                    });
                  },
                );
              }),
              Builder(builder: (cellContext) {
                return IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade700),
                  onPressed: () {
                    showDialog(
                      context: cellContext,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Confirmar Exclusão'),
                          content: Text(
                              'Tem certeza que deseja desativar o usuário ${user.nome}?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancelar'),
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                            ),
                            TextButton(
                              child: Text('Desativar',
                                  style:
                                  TextStyle(color: Colors.red.shade900)),
                              onPressed: () {
                                context
                                    .read<UserManagementCubit>()
                                    .deleteUser(user.id);
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => users.length;
  @override
  int get selectedRowCount => 0;
}

