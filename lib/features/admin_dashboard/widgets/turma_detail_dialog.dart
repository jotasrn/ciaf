import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:escolinha_futebol_app/core/models/aula_resumo_model.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_detail_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_detail_state.dart';
import 'package:escolinha_futebol_app/core/utils/string_extensions.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/screens/admin_chamada_screen.dart';

Future<void> showTurmaDetailDialog({
  required BuildContext context,
  required String turmaId,
  required String turmaNome,
}) async {
  await showDialog(
    context: context,
    builder: (dialogContext) {
      final screenWidth = MediaQuery.of(dialogContext).size.width;
      final dialogWidth =
          screenWidth > 800 ? screenWidth * 0.7 : screenWidth * 0.9;
      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogWidth),
          child: BlocProvider(
            create: (context) => TurmaDetailCubit(
              context.read<TurmaRepository>(),
              context.read<AulaRepository>(),
            )..fetchTurmaDetails(turmaId),
            child: _TurmaDetailDialogContent(
                turmaId: turmaId, turmaNome: turmaNome),
          ),
        ),
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
    // A estrutura do diálogo permanece a mesma...
    return DefaultTabController(
      length: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('Detalhes da Turma: $turmaNome',
                      style: Theme.of(context).textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis),
                ),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop()),
              ],
            ),
          ),
          const TabBar(tabs: [
            Tab(icon: Icon(Icons.info_outline), text: 'Visão Geral'),
            Tab(icon: Icon(Icons.group), text: 'Alunos'),
            Tab(icon: Icon(Icons.event_available), text: 'Aulas e Horários'),
          ]),
          const Divider(height: 1),
          Flexible(
            child: BlocConsumer<TurmaDetailCubit, TurmaDetailState>(
              listener: (context, state) {
                if (!context.mounted) return;
                if (state is TurmaDetailActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green));
                }
                if (state is TurmaDetailFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red));
                }
              },
              builder: (context, state) {
                if (state is TurmaDetailLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TurmaDetailSuccess) {
                  return TabBarView(children: [
                    _buildVisaoGeralTab(context, state),
                    _buildAlunosTab(context, state),
                    _buildAulasTab(context, state, turmaId),
                  ]);
                }
                return const Center(child: Text('Erro ao carregar detalhes.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisaoGeralTab(BuildContext context, TurmaDetailSuccess state) {
    final turma = state.turma;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildInfoTile(
            context, Icons.sports_soccer, 'Esporte', turma.esporte.nome),
        _buildInfoTile(context, Icons.category, 'Categoria', turma.categoria),
        _buildInfoTile(
            context, Icons.person_outline, 'Professor', turma.professor.nome),
        _buildInfoTile(context, Icons.group_outlined, 'Total de Alunos',
            turma.alunos.length.toString()),
      ],
    );
  }

  Widget _buildInfoTile(
      BuildContext context, IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
    );
  }

  Widget _buildAlunosTab(BuildContext context, TurmaDetailSuccess state) {
    // ... esta aba não muda
    return Scaffold(
      body: state.turma.alunos.isEmpty
          ? const Center(child: Text('Nenhum aluno vinculado a esta turma.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.turma.alunos.length,
              itemBuilder: (context, index) {
                final aluno = state.turma.alunos[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                        child: Text(aluno.nomeCompleto.isNotEmpty
                            ? aluno.nomeCompleto[0]
                            : '')),
                    title: Text(aluno.nomeCompleto),
                    subtitle: Text(aluno.email),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Funcionalidade para adicionar aluno existente em breve!')));
        },
        tooltip: 'Adicionar Aluno Existente',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAulasTab(
      BuildContext context, TurmaDetailSuccess state, String turmaId) {
    // A lógica de projeção de aulas permanece a mesma...
    final List<AulaResumoModel> aulasProjetadas =
        _gerarAulasProjetadas(state.turma, state.aulas);
    final hoje = DateTime.now();
    final aulasAnteriores = state.aulas
        .where((aula) =>
            aula.data.year < hoje.year ||
            (aula.data.year == hoje.year && aula.data.month < hoje.month))
        .toList();
    aulasAnteriores.sort((a, b) => b.data.compareTo(a.data));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Aulas do Mês Atual',
            style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        if (aulasProjetadas.isEmpty)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Nenhum horário fixo definido para este mês.'),
          ))
        else
          ...aulasProjetadas.map((aula) {
            final chamadaRealizada = aula.status == 'Realizada';
            return Card(
              color: aula.id.isEmpty ? Colors.blue.shade50 : null,
              child: ListTile(
                leading: Icon(
                  chamadaRealizada ? Icons.check_circle : Icons.event_note,
                  color: chamadaRealizada ? Colors.green : Colors.grey,
                ),
                title: Text(
                    'Aula de ${DateFormat('dd/MM/yyyy \'às\' HH:mm', 'pt_BR').format(aula.data)}'),
                subtitle: Text(
                    'Status: ${aula.status} | Presença: ${aula.totalPresentes}/${aula.totalAlunosNaTurma}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  if (!context.mounted) return;
                  if (chamadaRealizada) {
                    await Navigator.of(context).push(MaterialPageRoute(
                      // ✅ CORREÇÃO FINAL: Passa APENAS os parâmetros que a tela de chamada espera.
                      builder: (_) => AdminChamadaScreen(
                        aulaId: aula.id,
                        turmaNome: aula.turmaNome,
                      ),
                    ));
                    if (context.mounted) {
                      context
                          .read<TurmaDetailCubit>()
                          .refreshTurmaDetails(turmaId);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'A chamada para esta aula ainda não foi realizada.')));
                  }
                },
              ),
            );
          }),
        const SizedBox(height: 32),
        Text('Histórico de Aulas (Meses Anteriores)',
            style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        if (aulasAnteriores.isEmpty)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Nenhum registro de aulas de meses anteriores.'),
          ))
        else
          ...aulasAnteriores.map((aula) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.blueGrey),
                title: Text(
                    'Aula de ${DateFormat('dd/MM/yyyy \'às\' HH:mm', 'pt_BR').format(aula.data)}'),
                subtitle: Text(
                    'Status: ${aula.status} | Presença: ${aula.totalPresentes}/${aula.totalAlunosNaTurma}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  if (!context.mounted) return;
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AdminChamadaScreen(
                      aulaId: aula.id,
                      turmaNome: aula.turmaNome,
                    ),
                  ));
                  if (context.mounted) {
                    context
                        .read<TurmaDetailCubit>()
                        .refreshTurmaDetails(turmaId);
                  }
                },
              ),
            );
          }),
      ],
    );
  }

  List<AulaResumoModel> _gerarAulasProjetadas(
      TurmaModel turma, List<AulaResumoModel> aulasExistentes) {
    // ... a lógica desta função permanece a mesma, não precisa mudar.
    if (turma.horarios.isEmpty) return [];
    final diasDaSemana = {
      1: 'segunda',
      2: 'terca',
      3: 'quarta',
      4: 'quinta',
      5: 'sexta',
      6: 'sabado',
      7: 'domingo'
    };
    final aulasSalvasPorData = {
      for (var aula in aulasExistentes)
        DateFormat('yyyy-MM-dd HH:mm').format(aula.data): aula
    };
    final List<AulaResumoModel> aulasProjetadas = [];
    final hoje = DateTime.now();
    final primeiroDiaDoMes = DateTime(hoje.year, hoje.month, 1);
    final ultimoDiaDoMes = DateTime(hoje.year, hoje.month + 1, 0);
    for (int i = 0; i < ultimoDiaDoMes.day; i++) {
      final diaAtual = primeiroDiaDoMes.add(Duration(days: i));
      final nomeDiaSemana = diasDaSemana[diaAtual.weekday];
      for (var horario in turma.horarios) {
        if (horario['dia_semana'] == nomeDiaSemana) {
          final horaInicio = (horario['hora_inicio'] ?? '00:00').split(':');
          final dataDaAula = DateTime(diaAtual.year, diaAtual.month,
              diaAtual.day, int.parse(horaInicio[0]), int.parse(horaInicio[1]));
          final chaveData = DateFormat('yyyy-MM-dd HH:mm').format(dataDaAula);
          if (aulasSalvasPorData.containsKey(chaveData)) {
            aulasProjetadas.add(aulasSalvasPorData[chaveData]!);
          } else {
            aulasProjetadas.add(AulaResumoModel(
              id: '',
              data: dataDaAula,
              totalAlunosNaTurma: turma.alunos.length,
              totalPresentes: 0,
              status: 'Projetada',
              turmaNome: turma.nome,
              esporteNome: turma.esporte.nome,
            ));
          }
        }
      }
    }
    aulasProjetadas.sort((a, b) => a.data.compareTo(b.data));
    return aulasProjetadas;
  }
}
