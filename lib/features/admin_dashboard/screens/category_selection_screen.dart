import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/category_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/turma_list_screen.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/simple_form_dialog.dart';

class CategorySelectionScreen extends StatelessWidget {
  final String esporteId;
  final String esporteNome;

  const CategorySelectionScreen({
    super.key,
    required this.esporteId,
    required this.esporteNome,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoryCubit(
        RepositoryProvider.of<TurmaRepository>(context),
      )..fetchCategorias(esporteId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(esporteNome),
          actions: [
            Builder(builder: (context) {
              return IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Adicionar Categoria',
                onPressed: () async {
                  final novaCategoria = await showSimpleFormDialog(
                    context: context,
                    title: 'Adicionar Nova Categoria',
                  );
                  if (novaCategoria != null && novaCategoria.isNotEmpty) {
                    context.read<CategoryCubit>().createCategoria(
                      nome: novaCategoria,
                      esporteId: esporteId,
                    );
                  }
                },
              );
            })
          ],
        ),
        body: BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CategoryFailure) {
              return Center(child: Text(state.message));
            }
            if (state is CategorySuccess) {
              if (state.categorias.isEmpty) {
                return const Center(
                  child:
                  Text('Nenhuma categoria encontrada para este esporte.'),
                );
              }
              return ListView.builder(
                itemCount: state.categorias.length,
                itemBuilder: (context, index) {
                  final categoria = state.categorias[index];
                  return ListTile(
                    title: Text(categoria.nome),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              size: 20, color: Colors.grey),
                          tooltip: 'Editar Categoria',
                          onPressed: () async {
                            final categoriaEditada =
                            await showSimpleFormDialog(
                              context: context,
                              title: 'Editar Categoria',
                              initialValue: categoria.nome,
                            );
                            if (categoriaEditada != null &&
                                categoriaEditada.isNotEmpty) {
                              context.read<CategoryCubit>().updateCategoria(
                                id: categoria.id,
                                nome: categoriaEditada,
                                esporteId: esporteId,
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              size: 20, color: Colors.red.shade700),
                          tooltip: 'Deletar Categoria',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Confirmar Exclusão'),
                                content: Text(
                                    'Tem certeza que deseja deletar a categoria ${categoria.nome}?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(),
                                  ),
                                  TextButton(
                                    child: const Text('Deletar',
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      context
                                          .read<CategoryCubit>()
                                          .deleteCategoria(
                                        id: categoria.id,
                                        esporteId: esporteId,
                                      );
                                      Navigator.of(dialogContext).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => TurmaListScreen(
                          esporteId: esporteId,
                          esporteNome: esporteNome,
                          categoria: categoria.nome,
                        ),
                      ));
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

