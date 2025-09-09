import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/core/utils/string_extensions.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/professor_dashboard_cubit.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/professor_dashboard_state.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/screens/aula_selection_screen.dart';

class ProfessorHomeScreen extends StatelessWidget {
  const ProfessorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Providencia o Cubit para esta tela e já dispara a busca pelas turmas
    return BlocProvider(
      create: (context) => ProfessorDashboardCubit(
        RepositoryProvider.of<TurmaRepository>(context),
      )..fetchMinhasTurmas(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Minhas Turmas'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        ),
        body: BlocBuilder<ProfessorDashboardCubit, ProfessorDashboardState>(
          builder: (context, state) {
            // Exibe um indicador de progresso enquanto os dados são carregados
            if (state is ProfessorDashboardLoading ||
                state is ProfessorDashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            // Exibe uma mensagem de erro se a busca falhar
            if (state is ProfessorDashboardFailure) {
              return Center(child: Text(state.message));
            }
            // Constrói a lista de turmas quando os dados chegam com sucesso
            if (state is ProfessorDashboardSuccess) {
              if (state.turmas.isEmpty) {
                return const Center(
                  child: Text('Você não está associado a nenhuma turma.'),
                );
              }
              // Constrói a lista de turmas usando os dados reais da API
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.turmas.length,
                itemBuilder: (context, index) {
                  final turma = state.turmas[index];

                  // Formata os horários para exibição de forma mais elegante
                  final horariosStr = turma.horarios.map((h) {
                    final dia = h['dia_semana'].toString().capitalize();
                    final inicio = h['hora_inicio'];
                    return '$dia - $inicio';
                  }).join(' / ');

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.sports_soccer,
                          color: Colors.green, size: 40),
                      title: Text(turma.nome,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${turma.esporte.nome}\n$horariosStr'),
                      trailing:
                      const Icon(Icons.arrow_forward_ios, size: 16),
                      isThreeLine: true,
                      onTap: () {
                        // Navega para a tela de seleção de aulas daquela turma
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => AulaSelectionScreen(turma: turma),
                        ));
                      },
                    ),
                  );
                },
              );
            }
            // Estado de fallback, caso algo inesperado aconteça
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

