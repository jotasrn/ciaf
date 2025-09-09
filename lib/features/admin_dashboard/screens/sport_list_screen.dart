import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/sport_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/sport_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/sport_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/widgets/simple_form_dialog.dart';

class SportListScreen extends StatelessWidget {
  const SportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // O BlocProvider cria o Cubit e o disponibiliza para os widgets filhos.
    // A chamada `..fetchSports()` inicia a busca pelos dados assim que a tela é criada.
    return BlocProvider(
      create: (context) => SportCubit(
        RepositoryProvider.of<SportRepository>(context),
      )..fetchSports(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gerenciamento de Esportes'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          // BlocConsumer é ótimo pois combina o BlocListener (para ações como SnackBars)
          // com o BlocBuilder (para construir a UI).
          child: BlocConsumer<SportCubit, SportState>(
            listener: (context, state) {
              // Mostra uma SnackBar vermelha em caso de falha na API
              if (state is SportFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              // Mostra um indicador de progresso enquanto os dados carregam
              if (state is SportLoading || state is SportInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              // Constrói a lista quando os dados chegam com sucesso
              if (state is SportLoadSuccess) {
                if (state.sports.isEmpty) {
                  return const Center(child: Text('Nenhum esporte cadastrado.'));
                }
                return ListView.separated(
                  itemCount: state.sports.length,
                  itemBuilder: (context, index) {
                    final sport = state.sports[index];
                    return ListTile(
                      leading: const Icon(Icons.emoji_events_outlined),
                      title: Text(sport.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red.shade700),
                        onPressed: () {
                          // Mostra um diálogo de confirmação antes de deletar
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Confirmar Exclusão'),
                              content: Text(
                                  'Tem certeza que deseja deletar o esporte "${sport.nome}"? Isso não será possível se ele estiver em uso por alguma turma.'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancelar'),
                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                ),
                                TextButton(
                                  child: const Text('Deletar', style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    // Chama o método do Cubit para deletar o esporte
                                    context.read<SportCubit>().deleteSport(id: sport.id);
                                    Navigator.of(dialogContext).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(),
                );
              }
              // Estado padrão caso algo inesperado aconteça
              return const Center(child: Text('Nenhum esporte encontrado.'));
            },
          ),
        ),
        // Botão para adicionar novos esportes
        floatingActionButton: Builder(
          builder: (buttonContext) {
            return FloatingActionButton(
              onPressed: () async {
                final novoEsporte = await showSimpleFormDialog(
                  context: context, // Usa o context principal para o tema
                  title: 'Adicionar Novo Esporte',
                );
                if (novoEsporte != null && novoEsporte.isNotEmpty) {
                  // Usa o buttonContext para garantir que o Cubit será encontrado
                  buttonContext.read<SportCubit>().createSport(nome: novoEsporte);
                }
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}