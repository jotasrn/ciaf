import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/turma_detail_dialog.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/turma_form_screen.dart';

class TurmaListScreen extends StatelessWidget {
  final String title;
  final String? esporteId;
  final String? categoria;

  const TurmaListScreen({
    super.key,
    required this.title,
    this.esporteId,
    this.categoria,
  });

  @override
  Widget build(BuildContext context) {
    // A tela agora cria seu próprio provider, tornando-a independente
    return BlocProvider(
      create: (context) {
        final cubit = TurmaManagementCubit(
          RepositoryProvider.of<TurmaRepository>(context),
        );
        // Decide qual método de busca chamar com base nos filtros recebidos
        if (esporteId != null && categoria != null) {
          cubit.fetchTurmas(esporteId: esporteId!, categoria: categoria!);
        } else {
          cubit.fetchTodasTurmas();
        }
        return cubit;
      },
      child: _TurmaListView(
        title: title,
        esporteId: esporteId,
        categoria: categoria,
      ),
    );
  }
}

class _TurmaListView extends StatelessWidget {
  final String title;
  final String? esporteId;
  final String? categoria;

  const _TurmaListView({
    required this.title,
    this.esporteId,
    this.categoria,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BlocConsumer<TurmaManagementCubit, TurmaManagementState>(
        listener: (context, state) {
          if (state is TurmaManagementFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is TurmaManagementLoading || state is TurmaManagementInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TurmaManagementSuccess) {
            if (state.turmas.isEmpty) {
              return const Center(
                child: Text('Nenhuma turma encontrada.'),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: PaginatedDataTable2(
                columns: const [
                  DataColumn(label: Text('Nome da Turma')),
                  DataColumn(label: Text('Esporte')),
                  DataColumn(label: Text('Categoria')),
                  DataColumn(label: Text('Professor')),
                  DataColumn(label: Text('Ações')),
                ],
                source: TurmaDataSource(
                  state.turmas,
                  context,
                  esporteId: esporteId,
                  categoria: categoria,
                ),
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 800,
                showCheckboxColumn: false,
              ),
            );
          }
          return const Center(child: Text('Ocorreu um erro.'));
        },
      ),
      floatingActionButton: Builder(builder: (buttonContext) {
        return FloatingActionButton(
          tooltip: 'Adicionar Turma',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Para criar uma turma, navegue por Esportes > Categoria.')),
            );
          },
          child: const Icon(Icons.add),
        );
      }),
    );
  }
}

class TurmaDataSource extends DataTableSource {
  final List<TurmaModel> turmas;
  final BuildContext context;
  final String? esporteId;
  final String? categoria;
  TurmaDataSource(this.turmas, this.context, {this.esporteId, this.categoria});

  @override
  DataRow2 getRow(int index) {
    final turma = turmas[index];
    return DataRow2.byIndex(
      index: index,
      onSelectChanged: (isSelected) {
        if (isSelected ?? false) {
          showTurmaDetailDialog(
            context: context,
            turmaId: turma.id,
            turmaNome: turma.nome,
          );
        }
      },
      cells: [
        DataCell(Text(turma.nome)),
        DataCell(Text(turma.esporte.nome)),
        DataCell(Text(turma.categoria)),
        DataCell(Text(turma.professor.nome)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(builder: (cellContext) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(cellContext).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: BlocProvider.of<TurmaManagementCubit>(context),
                          child: TurmaFormScreen(
                            turma: turma,
                            esporteId: turma.esporte.id,
                            categoria: turma.categoria,
                          ),
                        ),
                      ),
                    ).then((_) {
                      final cubit = context.read<TurmaManagementCubit>();
                      if (esporteId != null && categoria != null) {
                        cubit.fetchTurmas(esporteId: esporteId!, categoria: categoria!);
                      } else {
                        cubit.fetchTodasTurmas();
                      }
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
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Confirmar Exclusão'),
                        content: Text('Tem certeza que deseja deletar a turma "${turma.nome}"?'),
                        actions: [
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                          TextButton(
                            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              final cubit = context.read<TurmaManagementCubit>();
                              cubit.deleteTurmaById(turma.id).then((_) {
                                if (esporteId != null && categoria != null) {
                                  cubit.fetchTurmas(esporteId: esporteId!, categoria: categoria!);
                                } else {
                                  cubit.fetchTodasTurmas();
                                }
                              });
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