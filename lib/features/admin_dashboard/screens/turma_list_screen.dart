import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/sport_model.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/repositories/sport_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/turma_form_dialog.dart';
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
    // A tela continua autônoma, criando seu próprio Cubit.
    return BlocProvider(
      create: (context) {
        final cubit = TurmaManagementCubit(
          RepositoryProvider.of<TurmaRepository>(context),
        );
        // Lógica para carregar todas as turmas ou turmas filtradas.
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
              SnackBar(
                  content: Text(state.message.replaceAll('Exception: ', '')),
                  backgroundColor: Colors.red),
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
            // Sua estrutura com PaginatedDataTable2 está mantida.
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
          // Fallback para qualquer outro estado de erro.
          return const Center(
              child: Text('Ocorreu um erro ao carregar as turmas.'));
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
          showTurmaDetailDialog(
              context: context, turmaId: turma.id, turmaNome: turma.nome);
        }
      },
      cells: [
        DataCell(Text(turma.nome)),
        // ✅ CORRETO: Acessa a propriedade 'nome' do objeto 'esporte'.
        DataCell(Text(turma.esporte.nome)),
        DataCell(Text(turma.categoria)),
        // ✅ CORRETO: Acessa a propriedade 'nome' do objeto 'professor'.
        DataCell(Text(turma.professor.nome)),
        DataCell(
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'editar') {
                await showTurmaFormDialog(
                  context: context,
                  turma: turma,
                  esporteId: turma.esporte.id,
                  categoria: turma.categoria,
                );
                // Atualiza a lista após a edição
                final cubit = context.read<TurmaManagementCubit>();
                if (esporteId != null && categoria != null) {
                  cubit.fetchTurmas(esporteId: esporteId!, categoria: categoria!);
                } else {
                  cubit.fetchTodasTurmas();
                }
              } else if (value == 'excluir') {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Confirmar Exclusão'),
                    content: Text('Tem certeza que deseja deletar a turma "${turma.nome}"?'),
                    actions: [
                      TextButton(
                          child: const Text('Cancelar'),
                          onPressed: () => Navigator.of(dialogContext).pop()),
                      TextButton(
                        child: const Text('Deletar',
                            style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          context.read<TurmaManagementCubit>().deleteTurmaById(turma.id);
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
                      leading: Icon(Icons.edit_outlined), title: Text('Editar'))),
              const PopupMenuItem(
                  value: 'excluir',
                  child: ListTile(
                      leading: Icon(Icons.delete_outline), title: Text('Excluir'))),
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
    // Busca os esportes com suas respectivas categorias
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
              content: SingleChildScrollView( // Para evitar overflow em telas pequenas
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<SportWithCategoriesModel>(
                      isExpanded: true,
                      hint: const Text('1. Selecione um Esporte'),
                      value: selectedSport,
                      items: sportsWithCategories.map((sport) {
                        return DropdownMenuItem(
                          value: sport,
                          child: Text(sport.nome),
                        );
                      }).toList(),
                      onChanged: (sport) {
                        setState(() {
                          selectedSport = sport;
                          selectedCategory = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (selectedSport != null)
                      DropdownButtonFormField<CategoryBasicModel>(
                        isExpanded: true,
                        hint: const Text('2. Selecione uma Categoria'),
                        value: selectedCategory,
                        items: selectedSport!.categorias.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat.nome),
                          );
                        }).toList(),
                        onChanged: (cat) =>
                            setState(() => selectedCategory = cat),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => navigator.pop(false),
                  child: const Text('Cancelar'),
                ),
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
      final chosenSport = selectedSport!;
      final chosenCategory = selectedCategory!;
      // Chama o formulário final passando os dados selecionados
      await showTurmaFormDialog(
        context: context,
        esporteId: chosenSport.id,
        categoria: chosenCategory.nome,
      );
      // Recarrega as turmas após o diálogo ser fechado.
      cubit.fetchTodasTurmas();
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red),
      );
    }
  }
}