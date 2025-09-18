import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_form_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_form_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_cubit.dart';
import 'package:escolinha_futebol_app/main.dart'; // Para a navigatorKey

/// Modelo auxiliar para gerenciar o estado dos horários na UI
class Horario {
  String diaSemana;
  TimeOfDay? horaInicio;
  TimeOfDay? horaFim;
  Horario({required this.diaSemana, this.horaInicio, this.horaFim});

  Map<String, String> toJson() {
    final context = navigatorKey.currentContext;
    if (context == null)
      return {'dia_semana': diaSemana, 'hora_inicio': '', 'hora_fim': ''};
    return {
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio?.format(context) ?? '',
      'hora_fim': horaFim?.format(context) ?? '',
    };
  }
}

/// Função principal que exibe o diálogo de formulário de turma.
Future<void> showTurmaFormDialog({
  required BuildContext context,
  required String esporteId,
  required String categoria,
  TurmaModel? turma,
}) async {
  // Passa o Cubit da lista para que o formulário possa recarregá-la
  final turmaManagementCubit = context.read<TurmaManagementCubit>();
  await showDialog(
    context: context,
    builder: (dialogContext) {
      // Provê o Cubit da lista de turmas para o diálogo
      return BlocProvider.value(
        value: turmaManagementCubit,
        child: _TurmaFormDialogContent(
          turma: turma,
          esporteId: esporteId,
          categoria: categoria,
        ),
      );
    },
  );
}

/// Widget que cria o Cubit específico do formulário.
class _TurmaFormDialogContent extends StatelessWidget {
  final TurmaModel? turma;
  final String esporteId;
  final String categoria;

  const _TurmaFormDialogContent({
    this.turma,
    required this.esporteId,
    required this.categoria,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TurmaFormCubit(
        context.read<TurmaRepository>(),
        context.read<UserRepository>(),
      )..loadInitialData(turma),
      child: _TurmaFormView(
        turma: turma,
        esporteId: esporteId,
        categoria: categoria,
      ),
    );
  }
}

/// O StatefulWidget que contém a lógica e a UI do formulário.
class _TurmaFormView extends StatefulWidget {
  final TurmaModel? turma;
  final String esporteId;
  final String categoria;

  const _TurmaFormView({
    this.turma,
    required this.esporteId,
    required this.categoria,
  });

  @override
  State<_TurmaFormView> createState() => _TurmaFormViewState();
}

class _TurmaFormViewState extends State<_TurmaFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedProfessorId;
  List<String> _selectedAlunosIds = [];
  List<Horario> _horarios = [];
  bool get _isEditing => widget.turma != null;
  bool _fieldsInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.turma?.nome ?? '');
  }

  /// Preenche os campos do formulário com os dados da turma no modo de edição.
  void _initializeFields(TurmaModel turma) {
    _selectedProfessorId = turma.professor.id;
    _selectedAlunosIds = turma.alunos.map((aluno) => aluno.id).toList();
    _horarios = turma.horarios.map((horarioJson) {
      TimeOfDay? parseTime(String? timeStr) {
        if (timeStr == null || timeStr.isEmpty) return null;
        try {
          return TimeOfDay.fromDateTime(DateFormat.Hm().parse(timeStr));
        } catch (e) {
          return null;
        }
      }

      return Horario(
        diaSemana: horarioJson['dia_semana'],
        horaInicio: parseTime(horarioJson['hora_inicio']),
        horaFim: parseTime(horarioJson['hora_fim']),
      );
    }).toList();
    _fieldsInitialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nome': _nameController.text,
        'esporte_id': widget.esporteId,
        'categoria': widget.categoria,
        'professor_id': _selectedProfessorId,
        'alunos_ids': _selectedAlunosIds,
        'horarios': _horarios.map((h) => h.toJson()).toList(),
      };
      context.read<TurmaFormCubit>().submitTurma(data, widget.turma?.id);
    }
  }

  void _adicionarHorario() {
    setState(() => _horarios.add(Horario(diaSemana: 'segunda')));
  }

  void _removerHorario(int index) {
    setState(() => _horarios.removeAt(index));
  }

  Future<TimeOfDay?> _selecionarHorario(BuildContext context,
      {TimeOfDay? initialTime}) {
    return showTimePicker(
        context: context, initialTime: initialTime ?? TimeOfDay.now());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TurmaFormCubit, TurmaFormState>(
      listener: (context, state) {
        if (state is TurmaFormSuccess) {
          context.read<TurmaManagementCubit>().fetchTodasTurmas();
          Navigator.of(context).pop();
        }
        if (state is TurmaFormFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return AlertDialog(
          title: Text(_isEditing ? 'Editar Turma' : 'Nova Turma'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: _buildDialogContent(state),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: (state is TurmaFormSubmitting) ? null : _submitForm,
              child: (state is TurmaFormSubmitting)
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(_isEditing ? 'Salvar' : 'Criar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogContent(TurmaFormState state) {
    if (state is TurmaFormLoading || state is TurmaFormInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is TurmaFormDataReady) {
      if (_isEditing && !_fieldsInitialized && state.turmaExistente != null) {
        _initializeFields(state.turmaExistente!);
      }
      return _buildForm(state.professores, state.alunos);
    }
    return const Center(child: Text('Erro ao carregar dados do formulário.'));
  }

  Widget _buildForm(List<UserModel> professores, List<UserModel> alunos) {
    if (_isEditing &&
        _selectedProfessorId != null &&
        !professores.any((p) => p.id == _selectedProfessorId)) {
      if (widget.turma != null) {
        professores.insert(
            0,
            UserModel(
                id: widget.turma!.professor.id,
                nomeCompleto: '${widget.turma!.professor.nome} (Inativo)',
                email: '',
                perfil: 'professor',
                ativo: false,
                statusPagamento: const StatusPagamento(status: 'N/A')));
      }
    }

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome da Turma'),
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedProfessorId,
              decoration: const InputDecoration(labelText: 'Professor'),
              items: professores
                  .map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.nomeCompleto)))
                  .toList(),
              onChanged: (id) => setState(() => _selectedProfessorId = id),
              validator: (id) => id == null ? 'Selecione um professor' : null,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Horários da Turma',
                    style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                    icon: Icon(Icons.add_circle,
                        color: Theme.of(context).primaryColor),
                    onPressed: _adicionarHorario)
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _horarios.length,
              itemBuilder: (context, index) {
                final horario = _horarios[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: horario.diaSemana,
                        items: [
                          'segunda',
                          'terca',
                          'quarta',
                          'quinta',
                          'sexta',
                          'sabado'
                        ]
                            .map((dia) =>
                                DropdownMenuItem(value: dia, child: Text(dia)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => horario.diaSemana = value!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () async {
                          final time = await _selecionarHorario(context,
                              initialTime: horario.horaInicio);
                          if (time != null)
                            setState(() => horario.horaInicio = time);
                        },
                        child: InputDecorator(
                          decoration:
                              const InputDecoration(labelText: 'Início'),
                          child: Text(
                              horario.horaInicio?.format(context) ?? '--:--'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () async {
                          final time = await _selecionarHorario(context,
                              initialTime: horario.horaFim);
                          if (time != null)
                            setState(() => horario.horaFim = time);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Fim'),
                          child:
                              Text(horario.horaFim?.format(context) ?? '--:--'),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.red),
                      onPressed: () => _removerHorario(index),
                    )
                  ],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
            ),
            if (_horarios.isEmpty)
              const Text('Nenhum horário adicionado.',
                  style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Text('Alunos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            MultiSelectDialogField<String>(
              items: alunos
                  .map((a) => MultiSelectItem<String>(a.id, a.nomeCompleto))
                  .toList(),
              initialValue: _selectedAlunosIds,
              title: const Text("Alunos"),
              buttonText: const Text("Selecionar Alunos"),
              onConfirm: (values) {
                setState(() => _selectedAlunosIds = values);
              },
              chipDisplay: MultiSelectChipDisplay(
                onTap: (value) =>
                    setState(() => _selectedAlunosIds.remove(value as String)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
