import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:escolinha_futebol_app/core/models/aluno_chamada_model.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/chamada_cubit.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/chamada_state.dart';

class ChamadaScreen extends StatelessWidget {
  final String aulaId;
  final String turmaNome;

  const ChamadaScreen({
    super.key,
    required this.aulaId,
    required this.turmaNome,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChamadaCubit(
        RepositoryProvider.of<AulaRepository>(context),
      )..fetchAlunos(aulaId),
      child: BlocListener<ChamadaCubit, ChamadaState>(
        listener: (context, state) {
          if (state is ChamadaSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chamada salva com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          }
          if (state is ChamadaFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.replaceAll('Exception: ', '')),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: _ChamadaView(aulaId: aulaId, turmaNome: turmaNome),
      ),
    );
  }
}

class _ChamadaView extends StatelessWidget {
  const _ChamadaView({
    required this.aulaId,
    required this.turmaNome,
  });

  final String aulaId;
  final String turmaNome;

  @override
  Widget build(BuildContext context) {
    final currentState = context.watch<ChamadaCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text('Chamada - $turmaNome')),
      body: _buildBody(context, currentState),
      floatingActionButton: (currentState is ChamadaSuccess)
          ? FloatingActionButton.extended(
        onPressed: () {
          context.read<ChamadaCubit>().submeterChamada(aulaId);
        },
        label: const Text('Finalizar Chamada'),
        icon: const Icon(Icons.check),
      )
          : (currentState is ChamadaSubmitting
          ? FloatingActionButton.extended(
        onPressed: null,
        label: const Text('Enviando...'),
        icon: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2)),
      )
          : null),
    );
  }

  Widget _buildBody(BuildContext context, ChamadaState state) {
    if (state is ChamadaLoading ||
        state is ChamadaInitial ||
        state is ChamadaSubmitting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ChamadaSuccess) {
      if (state.alunos.isEmpty) {
        return const Center(
            child: Text('Nenhum aluno encontrado nesta turma.'));
      }
      return Column(
        children: [
          // Cabeçalho com a data correta
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today,
                    color: Theme.of(context).primaryColor),
                title: Text(turmaNome,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                // Usa a 'aulaData' que agora vem do estado
                subtitle: Text(
                    'Data: ${DateFormat('dd/MM/yyyy').format(state.aulaData)}'),
              ),
            ),
          ),
          const Divider(),
          // Lista de alunos
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: state.alunos.length,
              itemBuilder: (context, index) {
                final aluno = state.alunos[index];
                return ListTile(
                  leading: CircleAvatar(
                      child: Text(aluno.nome.isNotEmpty ? aluno.nome[0] : '?')),
                  title: Text(aluno.nome),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StatusBox(
                        label: 'Presente',
                        icon: Icons.check,
                        color: Colors.green,
                        isSelected: aluno.status == StatusPresenca.presente,
                        onTap: () {
                          context
                              .read<ChamadaCubit>()
                              .marcarPresenca(aluno.id, StatusPresenca.presente);
                        },
                      ),
                      const SizedBox(width: 8),
                      _StatusBox(
                        label: 'Faltou',
                        icon: Icons.close,
                        color: Colors.red,
                        isSelected: aluno.status == StatusPresenca.ausente,
                        onTap: () {
                          context
                              .read<ChamadaCubit>()
                              .marcarPresenca(aluno.id, StatusPresenca.ausente);
                        },
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) =>
              const Divider(height: 0, indent: 16, endIndent: 16),
            ),
          ),
        ],
      );
    }

    if (state is ChamadaFailure) {
      return Center(child: Text(state.message));
    }

    return const Center(child: Text('Ocorreu um erro inesperado.'));
  }
}

// WIDGET AUXILIAR PARA OS BOTÕES DE PRESENÇA (AS "CAIXAS")
class _StatusBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusBox({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade400),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style:
              TextStyle(color: isSelected ? Colors.white : Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

