import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/aluno_chamada_model.dart';
import 'package:escolinha_futebol_app/core/repositories/aula_repository.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/chamada_cubit.dart';
import 'package:escolinha_futebol_app/features/professor_dashboard/cubit/chamada_state.dart';
import 'package:escolinha_futebol_app/core/utils/string_extensions.dart';

class AdminChamadaScreen extends StatefulWidget {
  final String aulaId;
  final String turmaNome;

  const AdminChamadaScreen({
    super.key,
    required this.aulaId,
    required this.turmaNome,
  });

  @override
  State<AdminChamadaScreen> createState() => _AdminChamadaScreenState();
}

class _AdminChamadaScreenState extends State<AdminChamadaScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChamadaCubit(
        RepositoryProvider.of<AulaRepository>(context),
      )..fetchAlunos(widget.aulaId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Revisar Chamada - ${widget.turmaNome}'),
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.done : Icons.edit),
              tooltip: _isEditing ? 'Finalizar Edição' : 'Habilitar Edição',
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
            ),
          ],
        ),
        body: BlocConsumer<ChamadaCubit, ChamadaState>(
          listener: (context, state) {
            if (state is ChamadaFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is ChamadaLoading || state is ChamadaInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChamadaSuccess) {
              final todosAlunos = state.alunos;

              if (todosAlunos.isEmpty) {
                return const Center(
                    child: Text('Nenhum aluno encontrado para esta turma.'));
              }

              return ListView.builder(
                itemCount: todosAlunos.length,
                itemBuilder: (context, index) {
                  final aluno = todosAlunos[index];
                  return ListTile(
                    leading: CircleAvatar(
                        child: Text(aluno.nome.isNotEmpty ? aluno.nome[0] : 'S')),
                    title: Text(aluno.nome),
                    subtitle: aluno.status != StatusPresenca.pendente
                        ? Chip(
                      label: Text(aluno.status
                          .toString()
                          .split('.')
                          .last
                          .capitalize()),
                      backgroundColor:
                      _getStatusColor(aluno.status).withOpacity(0.2),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    )
                        : null,
                    trailing: _isEditing
                        ? PopupMenuButton<StatusPresenca>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (novoStatus) {
                        context.read<ChamadaCubit>().editarPresencaAluno(
                          aulaId: widget.aulaId,
                          alunoId: aluno.id,
                          novoStatus: novoStatus,
                        );
                      },
                      itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<StatusPresenca>>[
                        const PopupMenuItem<StatusPresenca>(
                          value: StatusPresenca.presente,
                          child: Text('Marcar como Presente'),
                        ),
                        const PopupMenuItem<StatusPresenca>(
                          value: StatusPresenca.ausente,
                          child: Text('Marcar como Ausente'),
                        ),
                        const PopupMenuItem<StatusPresenca>(
                          value: StatusPresenca.justificado,
                          child: Text('Marcar como Justificado'),
                        ),
                      ],
                    )
                        : null,
                  );
                },
              );
            }
            return const Center(child: Text('Erro ao carregar dados.'));
          },
        ),
      ),
    );
  }

  Color _getStatusColor(StatusPresenca status) {
    switch (status) {
      case StatusPresenca.presente:
        return Colors.green;
      case StatusPresenca.ausente:
        return Colors.red;
      case StatusPresenca.justificado:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

