import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_detail_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_detail_state.dart';

Future<void> showTurmaDetailDialog({
  required BuildContext context,
  required String turmaId,
  required String turmaNome,
}) async {
  await showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider(
        create: (context) => TurmaDetailCubit(
          context.read<TurmaRepository>(),
          context.read<AulaRepository>(),
        )..fetchTurmaDetails(turmaId),
        child: _TurmaDetailDialogContent(turmaNome: turmaNome),
      );
    },
  );
}

class _TurmaDetailDialogContent extends StatelessWidget {
  final String turmaNome;
  const _TurmaDetailDialogContent({required this.turmaNome});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Remove o padding padrão para que o conteúdo ocupe todo o espaço
      contentPadding: EdgeInsets.zero,
      // Define um tamanho máximo para o diálogo
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7, // 70% da largura da tela
        height: MediaQuery.of(context).size.height * 0.8, // 80% da altura
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              // Cabeçalho do modal com o título e o botão de fechar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(turmaNome, style: Theme.of(context).textTheme.headlineSmall),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Abas de navegação
              const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.info_outline), text: 'Visão Geral'),
                  Tab(icon: Icon(Icons.group), text: 'Alunos'),
                  Tab(icon: Icon(Icons.event_available), text: 'Aulas'),
                ],
              ),
              const Divider(height: 1),
              // Conteúdo das abas
              Expanded(
                child: BlocBuilder<TurmaDetailCubit, TurmaDetailState>(
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
                          _buildVisaoGeralTab(context, state),
                          _buildAlunosTab(context, state),
                          _buildAulasTab(context, state),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisaoGeralTab(BuildContext context, TurmaDetailSuccess state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(title: const Text('Nome da Turma'), subtitle: Text(state.turma.nome)),
        ListTile(title: const Text('Esporte'), subtitle: Text(state.turma.esporte.nome)),
        ListTile(title: const Text('Categoria'), subtitle: Text(state.turma.categoria)),
        ListTile(title: const Text('Professor'), subtitle: Text(state.turma.professor.nome)),
        ListTile(title: const Text('Total de Alunos'), subtitle: Text(state.turma.alunos.length.toString())),
      ],
    );
  }

  Widget _buildAlunosTab(BuildContext context, TurmaDetailSuccess state) {
    if(state.turma.alunos.isEmpty) {
      return const Center(child: Text('Nenhum aluno vinculado a esta turma.'));
    }
    return ListView.builder(
      itemCount: state.turma.alunos.length,
      itemBuilder: (context, index) {
        final aluno = state.turma.alunos[index];
        return ListTile(
          leading: CircleAvatar(child: Text(aluno.nome.isNotEmpty ? aluno.nome[0] : '')),
          title: Text(aluno.nome),
          subtitle: Text(aluno.email),
        );
      },
    );
  }

  Widget _buildAulasTab(BuildContext context, TurmaDetailSuccess state) {
    if(state.aulas.isEmpty) {
      return const Center(child: Text('Nenhuma aula agendada para esta turma.'));
    }
    return ListView.separated(
      itemCount: state.aulas.length,
      itemBuilder: (context, index) {
        final aula = state.aulas[index];
        return ListTile(
          leading: const Icon(Icons.calendar_today_outlined),
          title: Text('Aula de ${DateFormat('dd/MM/yyyy \'às\' HH:mm').format(aula.data)}'),
          subtitle: Text('Presença: ${aula.totalPresentes} de ${aula.totalAlunosNaTurma}'),
          onTap: () { /* TODO: Navegar para AdminChamadaScreen */ },
        );
      },
      separatorBuilder: (_, __) => const Divider(),
    );
  }
}