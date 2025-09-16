import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/category_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/category_management_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/category_management_state.dart';

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
                SnackBar(content: Text(state.message.replaceAll('Exception: ', '')), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is CategoryManagementLoading || state is CategoryManagementInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CategoryManagementSuccess) {
              if(state.categorias.isEmpty) {
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
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                      tooltip: 'Deletar Categoria',
                      onPressed: () {
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
                      },
                    ),
                  );
                },
                separatorBuilder: (_, __) => const Divider(indent: 16, endIndent: 16),
              );
            }
            return const Center(child: Text('Ocorreu um erro ao carregar as categorias.'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Adicionar Categoria',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Para criar uma categoria, navegue por Esportes > Selecionar Categoria.')),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}