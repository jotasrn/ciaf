import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/sport_model.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/repositories/sport_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/turma_form_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/turma_detail_dialog.dart';

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
      appBar: AppBar(title: Text(title)),
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
              return const Center(child: Text('Nenhuma turma encontrada.'));
            }
            return PaginatedDataTable2(
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
              minWidth: 800,
              showCheckboxColumn: false,
            );
          }
          return const Center(child: Text('Ocorreu um erro.'));
        },
      ),
      floatingActionButton: Builder(builder: (buttonContext) {
        return FloatingActionButton(
          tooltip: 'Adicionar Turma',
          onPressed: () => showCreateTurmaDialog(buttonContext),
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
          showTurmaDetailDialog(context: context, turmaId: turma.id, turmaNome: turma.nome);
        }
      },
      cells: [
        DataCell(Text(turma.nome)),
        DataCell(Text(turma.esporte.nome)),
        DataCell(Text(turma.categoria)),
        DataCell(Text(turma.professor.nome)),
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              final cubit = context.read<TurmaManagementCubit>();
              if (value == 'editar') {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: TurmaFormScreen(
                      turma: turma,
                      esporteId: turma.esporte.id,
                      categoria: turma.categoria,
                    ),
                  ),
                )).then((_) {
                  if (esporteId != null && categoria != null) {
                    cubit.fetchTurmas(esporteId: esporteId!, categoria: categoria!);
                  } else {
                    cubit.fetchTodasTurmas();
                  }
                });
              } else if (value == 'excluir') {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Confirmar Exclusão'),
                    content: Text('Tem certeza que deseja deletar a turma "${turma.nome}"?'),
                    actions: [
                      TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(dialogContext).pop()),
                      TextButton(
                        child: const Text('Deletar', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          cubit.deleteTurmaById(turma.id);
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'editar', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Editar'))),
              const PopupMenuItem(value: 'excluir', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Excluir'))),
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

/// Função que exibe o diálogo de dois passos para criar uma turma
Future<void> showCreateTurmaDialog(BuildContext context) async {
  final navigator = Navigator.of(context);
  final cubit = context.read<TurmaManagementCubit>();

  try {
    final List<SportWithCategoriesModel> sportsWithCategories =
    await context.read<SportRepository>().getSportsWithCategories();

    SportWithCategoriesModel? selectedSport;
    CategoryBasicModel? selectedCategory;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Criar Nova Turma: Selecione'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<SportWithCategoriesModel>(
                    hint: const Text('1. Selecione um Esporte'),
                    value: selectedSport,
                    items: sportsWithCategories.map((sport) {
                      return DropdownMenuItem(value: sport, child: Text(sport.nome));
                    }).toList(),
                    onChanged: (sport) {
                      setState(() {
                        selectedSport = sport;
                        selectedCategory = null;
                      });
                    },
                    validator: (v) => v == null ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  if (selectedSport != null)
                    DropdownButtonFormField<CategoryBasicModel>(
                      hint: const Text('2. Selecione uma Categoria'),
                      value: selectedCategory,
                      items: selectedSport!.categorias.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat.nome));
                      }).toList(),
                      onChanged: (cat) => setState(() => selectedCategory = cat),
                      validator: (v) => v == null ? 'Campo obrigatório' : null,
                    ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => navigator.pop(false), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: (selectedSport != null && selectedCategory != null)
                      ? () => navigator.pop(true)
                      : null,
                  child: const Text('Avançar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && selectedSport != null && selectedCategory != null) {
      navigator.push(MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: TurmaFormScreen(
            esporteId: selectedSport!.id,
            categoria: selectedCategory!.nome,
          ),
        ),
      )).then((_) => cubit.fetchTodasTurmas());
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
    );
  }
}