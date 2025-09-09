import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/chamadas_do_dia_state.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/aula_selection_cubit.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/screens/chamada_screen.dart';

class AulaSelectionScreen extends StatelessWidget {
  final TurmaModel turma;
  const AulaSelectionScreen({super.key, required this.turma});

  @override
  Widget build(BuildContext context) {
    // Provê o novo Cubit para a tela e já inicia a busca pelas aulas da turma
    return BlocProvider(
      create: (context) => AulaSelectionCubit(
        RepositoryProvider.of<AulaRepository>(context),
      )..fetchAulasDaTurma(turma.id),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Selecionar Aula - ${turma.nome}'),
        ),
        body: BlocBuilder<AulaSelectionCubit, ChamadasDoDiaState>(
          builder: (context, state) {
            if (state is ChamadasDoDiaLoading || state is ChamadasDoDiaInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChamadasDoDiaFailure) {
              return Center(child: Text(state.message));
            }
            if (state is ChamadasDoDiaSuccess) {
              if (state.aulas.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Nenhuma aula encontrada para esta turma.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }
              // Ordena as aulas da mais recente para a mais antiga
              final aulasOrdenadas = List.from(state.aulas)
                ..sort((a, b) => b.data.compareTo(a.data));

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: aulasOrdenadas.length,
                itemBuilder: (context, index) {
                  final aula = aulasOrdenadas[index];
                  bool chamadaRealizada = aula.status == 'realizada';

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: ListTile(
                      leading: Icon(
                        chamadaRealizada ? Icons.check_circle : Icons.pending_actions,
                        color: chamadaRealizada ? Colors.green : Colors.orange,
                      ),
                      title: Text(
                        'Aula de ${DateFormat('dd/MM/yyyy \'às\' HH:mm').format(aula.data)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        chamadaRealizada
                            ? 'Chamada finalizada'
                            : 'Chamada pendente',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navega para a tela de chamada, passando os IDs necessários
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ChamadaScreen(
                            aulaId: aula.id,
                            turmaNome: turma.nome,
                          ),
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