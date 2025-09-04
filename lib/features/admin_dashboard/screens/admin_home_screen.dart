import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_state.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Cria o Cubit e já dispara a busca pelos usuários
      create: (context) => UserManagementCubit(
        // Precisamos prover o UserRepository para este widget. Faremos isso no main.dart
        RepositoryProvider.of<UserRepository>(context),
      )..fetchUsers(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gerenciamento de Usuários'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
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
                  child: Text('Falha ao carregar usuários: ${state.message}'),
                );
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
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Navegar para a tela de criação de usuário
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// Fonte de dados para a nossa tabela paginada
class UserDataSource extends DataTableSource {
  final List<UserModel> users;
  final BuildContext context;
  UserDataSource(this.users, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
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
              // TODO: Chamar o cubit para atualizar o status de pagamento
            },
          ),
        ),
        DataCell(
          Chip(
            label: Text(user.ativo ? 'Ativo' : 'Inativo'),
            backgroundColor: user.ativo ? Colors.green[100] : Colors.grey[300],
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Navegar para a tela de edição
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // TODO: Mostrar dialog de confirmação e chamar cubit para deletar
                },
              ),
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