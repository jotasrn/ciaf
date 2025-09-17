import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_detail_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_detail_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/admin_chamada_screen.dart';

Future<void> showTurmaDetailDialog({
  required BuildContext context,
  required String turmaId,
  required String turmaNome,
}) async {
  // O Cubit da lista de turmas não é necessário aqui, pois cada diálogo é autônomo
  await showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider(
        create: (context) => TurmaDetailCubit(
          context.read<TurmaRepository>(),
          context.read<AulaRepository>(),
        )..fetchTurmaDetails(turmaId),
        child:
            _TurmaDetailDialogContent(turmaId: turmaId, turmaNome: turmaNome),
      );
    },
  );
}

class _TurmaDetailDialogContent extends StatelessWidget {
  final String turmaId;
  final String turmaNome;
  const _TurmaDetailDialogContent(
      {required this.turmaId, required this.turmaNome});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(turmaNome,
                        style: Theme.of(context).textTheme.headlineSmall),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.info_outline), text: 'Visão Geral'),
                  Tab(icon: Icon(Icons.group), text: 'Alunos'),
                  Tab(icon: Icon(Icons.event_available), text: 'Aulas'),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: BlocConsumer<TurmaDetailCubit, TurmaDetailState>(
                  listener: (context, state) {
                    if (state is TurmaDetailActionSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.green),
                      );
                    }
                    if (state is TurmaDetailFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is TurmaDetailLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is TurmaDetailSuccess) {
                      return TabBarView(
                        children: [
                          _buildVisaoGeralTab(context, state),
                          _buildAlunosTab(context, state),
                          _buildAulasTab(context, state),
                        ],
                      );
                    }
                    return const Center(
                        child: Text('Erro ao carregar detalhes.'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Botão de Agendamento agora fica nas ações do Diálogo
        TextButton.icon(
          icon: const Icon(Icons.event),
          label: const Text('Agendar Aulas (Próximo Mês)'),
          onPressed: () {
            context.read<TurmaDetailCubit>().agendarAulas(turmaId);
          },
        ),
      ],
    );
  }

  Widget _buildVisaoGeralTab(BuildContext context, TurmaDetailSuccess state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
            title: const Text('Nome da Turma'),
            subtitle: Text(state.turma.nome)),
        ListTile(
            title: const Text('Esporte'),
            subtitle: Text(state.turma.esporte.nome)),
        ListTile(
            title: const Text('Categoria'),
            subtitle: Text(state.turma.categoria)),
        ListTile(
            title: const Text('Professor'),
            subtitle: Text(state.turma.professor.nome)),
        ListTile(
            title: const Text('Total de Alunos'),
            subtitle: Text(state.turma.alunos.length.toString())),
      ],
    );
  }

  Widget _buildAlunosTab(BuildContext context, TurmaDetailSuccess state) {
    return Scaffold(
      // Usamos um Scaffold interno para ter um FloatingActionButton
      body: state.turma.alunos.isEmpty
          ? const Center(child: Text('Nenhum aluno vinculado a esta turma.'))
          : ListView.builder(
              itemCount: state.turma.alunos.length,
              itemBuilder: (context, index) {
                final aluno = state.turma.alunos[index];
                return ListTile(
                  leading: CircleAvatar(
                      child: Text(aluno.nome.isNotEmpty ? aluno.nome[0] : '')),
                  title: Text(aluno.nome),
                  subtitle: Text(aluno.email),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar diálogo para buscar e adicionar aluno existente
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Funcionalidade para adicionar aluno existente em breve!')),
          );
        },
        tooltip: 'Adicionar Aluno Existente',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAulasTab(BuildContext context, TurmaDetailSuccess state) {
    if (state.aulas.isEmpty) {
      return const Center(
          child: Text('Nenhuma aula agendada para esta turma.'));
    }
    return ListView.separated(
      itemCount: state.aulas.length,
      itemBuilder: (context, index) {
        final aula = state.aulas[index];
        return ListTile(
          leading: const Icon(Icons.calendar_today_outlined),
          title: Text(
              'Aula de ${DateFormat('dd/MM/yyyy \'às\' HH:mm').format(aula.data)}'),
          subtitle: Text(
              'Presença: ${aula.totalPresentes} de ${aula.totalAlunosNaTurma}'),
          onTap: () {/* TODO: Navegar para AdminChamadaScreen */},
        );
      },
      separatorBuilder: (_, __) => const Divider(),
    );
  }
}
