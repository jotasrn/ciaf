import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/category_model.dart';
import 'package:escolinha_futebol_app/core/repositories/category_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/category_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/category_management_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/simple_form_dialog.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/category_form_dialog.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoryManagementCubit(
        RepositoryProvider.of<CategoryRepository>(context),
      )..fetchCategorias(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Gerenciar Categorias')),
        body: BlocConsumer<CategoryManagementCubit, CategoryManagementState>(
          listener: (context, state) {
            if (state is CategoryManagementFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is CategoryManagementLoading || state is CategoryManagementInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CategoryManagementSuccess) {
              if (state.categorias.isEmpty) {
                return const Center(child: Text('Nenhuma categoria cadastrada.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.categorias.length,
                itemBuilder: (context, index) {
                  final categoria = state.categorias[index];
                  return ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: Text(categoria.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(categoria.esporteNome ?? 'Esporte não definido'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'editar') {
                          final novoNome = await showSimpleFormDialog(
                            context: context,
                            title: 'Editar Categoria',
                            initialValue: categoria.nome,
                          );
                          if (novoNome != null && novoNome.isNotEmpty) {
                            context.read<CategoryManagementCubit>().updateCategoria(categoria.id, novoNome);
                          }
                        } else if (value == 'excluir') {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Confirmar Exclusão'),
                              content: Text('Tem certeza que deseja deletar a categoria "${categoria.nome}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
                                TextButton(
                                  onPressed: () {
                                    context.read<CategoryManagementCubit>().deleteCategoria(categoria.id);
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: const Text('Deletar', style: TextStyle(color: Colors.red)),
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
                  );
                },
                separatorBuilder: (_, __) => const Divider(indent: 16, endIndent: 16),
              );
            }
            return const Center(child: Text('Ocorreu um erro ao carregar as categorias.'));
          },
        ),
        floatingActionButton: Builder(
            builder: (buttonContext) {
              return FloatingActionButton(
                tooltip: 'Adicionar Categoria e Turma',
                onPressed: () => showCategoryFormDialog(context: buttonContext),
                child: const Icon(Icons.add),
              );
            }
        ),
      ),
    );
  }
}