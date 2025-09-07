import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_state.dart';

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
                  source: TurmaDataSource(state.turmas, context),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Navegar para a tela de criação de turma
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// Fonte de dados para a tabela de turmas
class TurmaDataSource extends DataTableSource {
  final List<TurmaModel> turmas;
  final BuildContext context;
  TurmaDataSource(this.turmas, this.context);

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
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Navegar para o formulário de edição de turma
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red.shade700),
                onPressed: () {
                  // TODO: Mostrar diálogo e chamar cubit para deletar turma
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
  int get rowCount => turmas.length;
  @override
  int get selectedRowCount => 0;
}
