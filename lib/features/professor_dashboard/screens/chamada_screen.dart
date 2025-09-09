import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/chamada_cubit.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/chamada_state.dart';
import 'package:escolinha_futebol_app/core/models/aluno_chamada_model.dart';

// Enum movido para o modelo, mas pode ficar aqui se preferir
enum StatusPresenca { presente, ausente, justificado, pendente }

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
      child: BlocConsumer<ChamadaCubit, ChamadaState>(
        listener: (context, state) {
          if (state is ChamadaSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chamada salva com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            // Volta para a tela anterior
            Navigator.of(context).pop();
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
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text('Chamada - $turmaNome')),
            body: _buildBody(context, state),
            floatingActionButton: (state is ChamadaSuccess)
                ? FloatingActionButton.extended(
              onPressed: () {
                context.read<ChamadaCubit>().submeterChamada(aulaId);
              },
              label: const Text('Finalizar Chamada'),
              icon: const Icon(Icons.check),
            )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ChamadaState state) {
    if (state is ChamadaLoading || state is ChamadaInitial || state is ChamadaSubmitting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ChamadaSuccess) {
      if (state.alunos.isEmpty) {
        return const Center(child: Text('Nenhum aluno encontrado nesta turma.'));
      }
      return ListView.separated(
        itemCount: state.alunos.length,
        itemBuilder: (context, index) {
          final aluno = state.alunos[index];
          return ListTile(
            leading: CircleAvatar(child: Text(aluno.nome[0])),
            title: Text(aluno.nome),
            trailing: SizedBox(
              width: 210,
              child: SegmentedButton<StatusPresenca>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: StatusPresenca.presente, label: Text('Presente'), icon: Icon(Icons.check_circle_outline)),
                  ButtonSegment(value: StatusPresenca.ausente, label: Text('Faltou'), icon: Icon(Icons.cancel_outlined)),
                ],
                selected: {aluno.status},
                onSelectionChanged: (newSelection) {
                  context.read<ChamadaCubit>().marcarPresenca(aluno.id, newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 0),
      );
    }
    return const Center(child: Text('Ocorreu um erro.'));
  }
}