import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/chamadas_do_dia_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/chamadas_do_dia_state.dart';

class ChamadasDoDiaWidget extends StatelessWidget {
  const ChamadasDoDiaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChamadasDoDiaCubit(
        RepositoryProvider.of<AulaRepository>(context),
      )..fetchChamadas(), // Busca as chamadas do dia ao iniciar
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Cabeçalho com o título e os filtros
              BlocBuilder<ChamadasDoDiaCubit, ChamadasDoDiaState>(
                builder: (context, state) {
                  String dataExibida =
                      DateFormat('dd/MM/yyyy').format(DateTime.now());
                  if (state is ChamadasDoDiaSuccess) {
                    dataExibida =
                        DateFormat('dd/MM/yyyy').format(state.selectedDate);
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Chamadas do Dia",
                              style: Theme.of(context).textTheme.titleLarge),
                          Text(dataExibida,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      Builder(
                        builder: (buttonContext) {
                          return IconButton(
                            icon: const Icon(Icons.calendar_today,
                                color: Colors.grey),
                            onPressed: () async {
                              final cubit =
                                  buttonContext.read<ChamadasDoDiaCubit>();
                              final novaData = await showDatePicker(
                                context: buttonContext,
                                initialDate: (state is ChamadasDoDiaSuccess)
                                    ? state.selectedDate
                                    : DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (novaData != null) {
                                cubit.fetchChamadas(data: novaData);
                              }
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const Divider(height: 24),
              // A lista de chamadas
              Expanded(
                child: BlocBuilder<ChamadasDoDiaCubit, ChamadasDoDiaState>(
                  builder: (context, state) {
                    if (state is ChamadasDoDiaLoading ||
                        state is ChamadasDoDiaInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ChamadasDoDiaFailure) {
                      return Center(child: Text(state.message));
                    }
                    if (state is ChamadasDoDiaSuccess) {
                      if (state.aulas.isEmpty) {
                        return const Center(
                            child:
                                Text('Nenhuma aula agendada para esta data.'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.aulas.length,
                        itemBuilder: (context, index) {
                          final aula = state.aulas[index];
                          final progresso = aula.totalAlunosNaTurma > 0
                              ? aula.totalPresentes / aula.totalAlunosNaTurma
                              : 0.0;

                          return ListTile(
                            title:
                                Text('${aula.turmaNome} (${aula.esporteNome})'),
                            subtitle: Text(
                              'Presença: ${aula.totalPresentes} de ${aula.totalAlunosNaTurma}',
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(DateFormat('HH:mm').format(aula.data)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      value: progresso,
                                      strokeWidth: 3,
                                      backgroundColor: Colors.grey.shade200,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              // TODO: Navegar para a tela de detalhes da aula/chamada
                            },
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(),
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
}
