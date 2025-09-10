import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/professor_dashboard_cubit.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/professor_dashboard_state.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/screens/aula_selection_screen.dart';
import 'package:escolinha_futebol_app/core/utils/string_extensions.dart';

class ProfessorHomeScreen extends StatelessWidget {
  const ProfessorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfessorDashboardCubit(
        RepositoryProvider.of<TurmaRepository>(context),
      )..fetchMinhasTurmas(),
      child: Scaffold(
        body: BlocBuilder<ProfessorDashboardCubit, ProfessorDashboardState>(
          builder: (context, state) {
            if (state is ProfessorDashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfessorDashboardFailure) {
              return Center(child: Text(state.message));
            }
            if (state is ProfessorDashboardSuccess) {
              if (state.turmas.isEmpty) {
                return const Center(
                    child: Text('Você não está associado a nenhuma turma.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.turmas.length,
                itemBuilder: (context, index) {
                  final turma = state.turmas[index];
                  final horariosStr = turma.horarios.map((h) {
                    final dia = (h['dia_semana'] as String? ?? 'N/D').capitalize();
                    final inicio = h['hora_inicio'] ?? '--:--';
                    return '$dia às $inicio';
                  }).join(', ');

                  return Card(
                    // Usando o CardTheme do nosso tema
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(turma.nome,
                          style: Theme.of(context).textTheme.titleLarge),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InfoRow(
                                icon: Icons.sports_soccer,
                                text: '${turma.esporte.nome} - ${turma.categoria}'),
                            const SizedBox(height: 4),
                            InfoRow(icon: Icons.schedule, text: horariosStr),
                          ],
                        ),
                      ),
                      trailing:
                      const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => AulaSelectionScreen(turma: turma),
                        ));
                      },
                    ),
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

// Widget auxiliar para deixar o layout do subtítulo mais limpo
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const InfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey[800]))),
      ],
    );
  }
}

