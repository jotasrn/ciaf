import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/aluno_form_dialog.dart';

class AlunoListScreen extends StatelessWidget {
  final Map<String, String>? initialFilters;
  const AlunoListScreen({super.key, this.initialFilters});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserManagementCubit(
        RepositoryProvider.of<UserRepository>(context),
      )..fetchUsers(filters: initialFilters ?? {'perfil': 'aluno'}),
      child: _AlunoListView(parentFilters: initialFilters ?? {'perfil': 'aluno'}),
    );
  }
}

class _AlunoListView extends StatelessWidget {
  final Map<String, String> parentFilters;
  const _AlunoListView({required this.parentFilters});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Alunos'),
      ),
      body: BlocConsumer<UserManagementCubit, UserManagementState>(
        listener: (context, state) {
          if(state is UserManagementFailure){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is UserManagementLoading || state is UserManagementInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserManagementSuccess) {
            // DUPLA VERIFICAÇÃO (SUA SUGESTÃO)
            final usuariosFiltrados = state.users.where((u) => u.perfil == 'aluno').toList();

            if (usuariosFiltrados.isEmpty) {
              return const Center(child: Text('Nenhum aluno encontrado.'));
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: PaginatedDataTable2(
                columns: const [
                  DataColumn(label: Text('Nome Completo')),
                  DataColumn(label: Text('E-mail')),
                  DataColumn(label: Text('Pagamento')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Ações')),
                ],
                source: _AlunoDataSource(usuariosFiltrados, context, parentFilters),
                minWidth: 800,
                showCheckboxColumn: false,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _AddUserButton(parentFilters: parentFilters),
    );
  }
}

class _AddUserButton extends StatelessWidget {
  final Map<String, String> parentFilters;
  const _AddUserButton({required this.parentFilters});
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showAlunoFormDialog(context: context);
      },
      child: const Icon(Icons.add),
    );
  }
}

class _AlunoDataSource extends DataTableSource {
  final List<UserModel> users;
  final BuildContext context;
  final Map<String, String> parentFilters;
  _AlunoDataSource(this.users, this.context, this.parentFilters);

  @override
  DataRow2 getRow(int index) {
    final user = users[index];
    return DataRow2.byIndex(index: index, cells: [
      DataCell(Text(user.nome)),
      DataCell(Text(user.email)),
      DataCell(
        // O Switch agora é um widget separado para melhor gerenciamento de estado
        _PaymentStatusSwitch(user: user, parentFilters: parentFilters),
      ),
      DataCell(Chip(label: Text(user.ativo ? 'Ativo' : 'Inativo'))),
      DataCell(PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'editar') {
            showAlunoFormDialog(context: context, aluno: user).then((_) {
              // ======================= CORREÇÃO AQUI =======================
              context.read<UserManagementCubit>().fetchUsers(filters: parentFilters);
              // =============================================================
            });
          } else if (value == 'desativar') {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Confirmar Ação'),
                content: Text('Tem certeza que deseja desativar o aluno ${user.nome}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<UserManagementCubit>().deleteUser(user.id);
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Desativar', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'editar', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Editar'))),
          const PopupMenuItem(value: 'desativar', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Desativar'))),
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

class _PaymentStatusSwitch extends StatelessWidget {
  final UserModel user;
  final Map<String, String> parentFilters;

  const _PaymentStatusSwitch({required this.user, required this.parentFilters});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: user.statusPagamento.status == 'pago',
      onChanged: (value) {
        final newStatus = value ? 'pago' : 'pendente';
        context.read<UserManagementCubit>().updatePaymentStatus(user.id, newStatus);
      },
    );
  }
}