import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/turma_form_screen.dart';

class TurmaListScreen extends StatelessWidget {
  final String esporteId;
  final String esporteNome;
  final String categoria;

  const TurmaListScreen({
    super.key,
    required this.esporteId,
    required this.esporteNome,
    required this.categoria,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TurmaManagementCubit(
        RepositoryProvider.of<TurmaRepository>(context),
      )..fetchTurmas(esporteId: esporteId, categoria: categoria),
      child: Scaffold(
        appBar: AppBar(
          title: Text('$esporteNome - $categoria'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<TurmaManagementCubit, TurmaManagementState>(
            builder: (context, state) {
              if (state is TurmaManagementLoading ||
                  state is TurmaManagementInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is TurmaManagementFailure) {
                return Center(child: Text(state.message));
              }
              if (state is TurmaManagementSuccess) {
                if (state.turmas.isEmpty) {
                  return const Center(
                    child:
                    Text('Nenhuma turma encontrada para esta categoria.'),
                  );
                }
                return PaginatedDataTable2(
                  columns: const [
                    DataColumn(label: Text('Nome da Turma')),
                    DataColumn(label: Text('Categoria')),
                    DataColumn(label: Text('Ações')),
                  ],
                  source: TurmaDataSource(
                      state.turmas, context, esporteId, categoria),
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 600,
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
                Navigator.of(buttonContext).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: buttonContext.read<TurmaManagementCubit>(),
                      child: TurmaFormScreen(
                          esporteId: esporteId, categoria: categoria),
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}

// Fonte de dados para a tabela de turmas
class TurmaDataSource extends DataTableSource {
  final List<TurmaModel> turmas;
  final BuildContext context;
  final String esporteId;
  final String categoria;

  TurmaDataSource(this.turmas, this.context, this.esporteId, this.categoria);

  @override
  DataRow2 getRow(int index) {
    final turma = turmas[index];
    return DataRow2.byIndex(
      index: index,
      cells: [
        DataCell(Text(turma.nome)),
        DataCell(Text(turma.categoria)),
        DataCell(
          Row(
            children: [
              Builder(builder: (cellContext) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(cellContext).push(MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<TurmaManagementCubit>(),
                        child: TurmaFormScreen(
                            turma: turma,
                            esporteId: esporteId,
                            categoria: categoria),
                      ),
                    ));
                  },
                );
              }),
              Builder(builder: (cellContext) {
                return IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade700),
                  onPressed: () {
                    showDialog(
                      context: cellContext,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Confirmar Exclusão'),
                        content: Text(
                            'Tem certeza que deseja deletar a turma ${turma.nome}?'),
                        actions: [
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                          TextButton(
                            child: const Text('Deletar',
                                style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              context.read<TurmaManagementCubit>().deleteTurma(
                                id: turma.id,
                                esporteId: esporteId,
                                categoria: categoria,
                              );
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ],
                      ),
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
  int get rowCount => turmas.length;
  @override
  int get selectedRowCount => 0;
}

