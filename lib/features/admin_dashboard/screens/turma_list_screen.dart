import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/turma_detail_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/turma_form_screen.dart';

class TurmaListScreen extends StatelessWidget {
  // Parâmetros agora são opcionais para permitir listagem geral ou filtrada
  final String? esporteId;
  final String? esporteNome;
  final String? categoria;

  const TurmaListScreen({
    super.key,
    this.esporteId,
    this.esporteNome,
    this.categoria,
  });

  @override
  Widget build(BuildContext context) {
    // A tela agora precisa do seu próprio BlocProvider para ser reutilizável
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
      child: Scaffold(
        appBar: AppBar(
          // O título é dinâmico: mostra os filtros ou um título geral
          title: Text(esporteNome != null
              ? '$esporteNome - $categoria'
              : 'Gerenciamento de Turmas'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<TurmaManagementCubit, TurmaManagementState>(
            builder: (context, state) {
              if (state is TurmaManagementLoading || state is TurmaManagementInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is TurmaManagementFailure) {
                return Center(child: Text(state.message));
              }
              if (state is TurmaManagementSuccess) {
                if (state.turmas.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma turma encontrada.'),
                  );
                }
                // A fonte de dados agora recebe os filtros para saber como se comportar
                return PaginatedDataTable2(
                  columns: const [
                    DataColumn(label: Text('Nome da Turma')),
                    DataColumn(label: Text('Esporte')),
                    DataColumn(label: Text('Categoria')),
                    DataColumn(label: Text('Professor')),
                    DataColumn(label: Text('Ações')),
                  ],
                  source: TurmaDataSource(state.turmas, context, esporteId, categoria),
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
        // O botão de adicionar só aparece na visualização filtrada
        floatingActionButton: (esporteId != null && categoria != null)
            ? Builder(
          builder: (buttonContext) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(buttonContext).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: buttonContext.read<TurmaManagementCubit>(),
                      child: TurmaFormScreen(
                          esporteId: esporteId!, categoria: categoria!),
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          },
        )
            : null, // Não mostra o botão na lista geral
      ),
    );
  }
}

class TurmaDataSource extends DataTableSource {
  final List<TurmaModel> turmas;
  final BuildContext context;
  final String? esporteId;
  final String? categoria;

  TurmaDataSource(this.turmas, this.context, this.esporteId, this.categoria);

  @override
  DataRow2 getRow(int index) {
    final turma = turmas[index];
    return DataRow2.byIndex(
      index: index,
      onSelectChanged: (isSelected) {
        if (isSelected ?? false) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => TurmaDetailScreen(
              turmaId: turma.id,
              turmaNome: turma.nome,
            ),
          ));
        }
      },
      cells: [
        DataCell(Text(turma.nome)),
        DataCell(Text(turma.esporte.nome)),
        DataCell(Text(turma.categoria)),
        DataCell(Text(turma.professor.nome)),
        DataCell(
          Row(
            children: [
              Builder(builder: (cellContext) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(cellContext).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<TurmaManagementCubit>(),
                          child: TurmaFormScreen(
                              turma: turma,
                              esporteId: turma.esporte.id,
                              categoria: turma.categoria),
                        ),
                      ),
                    ).then((_) {
                      // Decide qual lista recarregar com base nos filtros
                      if (esporteId != null && categoria != null) {
                        context.read<TurmaManagementCubit>().fetchTurmas(
                            esporteId: esporteId!, categoria: categoria!);
                      } else {
                        context.read<TurmaManagementCubit>().fetchTodasTurmas();
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
                        content: Text(
                            'Tem certeza que deseja deletar a turma "${turma.nome}"?'),
                        actions: [
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                          TextButton(
                            child: const Text('Deletar',
                                style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              // Decide qual método de delete chamar
                              if (esporteId != null && categoria != null) {
                                context.read<TurmaManagementCubit>().deleteTurma(
                                  id: turma.id,
                                  esporteId: esporteId!,
                                  categoria: categoria!,
                                );
                              } else {
                                context.read<TurmaManagementCubit>().deleteTurmaById(turma.id);
                              }
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

