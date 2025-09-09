import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_detail_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_detail_state.dart';

class TurmaDetailScreen extends StatelessWidget {
  final String turmaId;
  final String turmaNome;

  const TurmaDetailScreen({
    super.key,
    required this.turmaId,
    required this.turmaNome,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TurmaDetailCubit(
        context.read<TurmaRepository>(),
        context.read<AulaRepository>(),
      )..fetchTurmaDetails(turmaId),
      child: DefaultTabController(
        length: 3, // Teremos 3 abas
        child: Scaffold(
          appBar: AppBar(
            title: Text(turmaNome),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.info_outline), text: 'Visão Geral'),
                Tab(icon: Icon(Icons.group), text: 'Alunos'),
                Tab(icon: Icon(Icons.event_available), text: 'Aulas'),
              ],
            ),
            actions: [
              Builder(builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.event),
                  tooltip: 'Agendar Aulas para o Próximo Mês',
                  onPressed: () {
                    context.read<TurmaDetailCubit>().agendarAulas(turmaId);
                  },
                );
              }),
            ],
          ),
          body: BlocConsumer<TurmaDetailCubit, TurmaDetailState>(
            listener: (context, state) {
              // Ouve o novo estado de evento para mostrar a SnackBar
              if (state is TurmaDetailActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              // O listener de falha continua o mesmo
              if (state is TurmaDetailFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
            builder: (context, state) {
              if (state is TurmaDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is TurmaDetailFailure) {
                return Center(child: Text(state.message));
              }
              if (state is TurmaDetailSuccess) {
                return TabBarView(
                  children: [
                    // Aba 1: Visão Geral
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ListTile(
                            title: const Text('Nome'),
                            subtitle: Text(state.turma.nome)),
                        ListTile(
                            title: const Text('Categoria'),
                            subtitle: Text(state.turma.categoria)),
                        ListTile(
                            title: const Text('Professor'),
                            subtitle: Text(state.turma.professor.nome)),
                        ListTile(
                            title: const Text('Total de Alunos'),
                            subtitle:
                            Text(state.turma.alunos.length.toString())),
                      ],
                    ),
                    // Aba 2: Alunos
                    ListView.builder(
                      itemCount: state.turma.alunos.length,
                      itemBuilder: (context, index) {
                        final aluno = state.turma.alunos[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text(aluno.nome[0])),
                          title: Text(aluno.nome),
                          subtitle: Text(aluno.email),
                        );
                      },
                    ),
                    // Aba 3: Aulas
                    ListView.separated(
                      itemCount: state.aulas.length,
                      itemBuilder: (context, index) {
                        final aula = state.aulas[index];
                        return ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                              'Aula de ${DateFormat('dd/MM/yyyy \'às\' HH:mm').format(aula.data)}'),
                          subtitle: Text(
                              'Presença: ${aula.totalPresentes} de ${aula.totalAlunosNaTurma}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Navegar para a tela de detalhes da chamada específica
                          },
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

