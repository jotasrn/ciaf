import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:escolinha_futebol_app/main.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_form_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_form_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_management_cubit.dart';

// Modelo auxiliar para os horários
class Horario {
  String diaSemana;
  TimeOfDay? horaInicio;
  TimeOfDay? horaFim;
  Horario({required this.diaSemana, this.horaInicio, this.horaFim});

  Map<String, String> toJson() {
    final context = navigatorKey.currentContext;
    if (context == null) {
      return {'dia_semana': diaSemana, 'hora_inicio': '', 'hora_fim': ''};
    }
    return {
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio?.format(context) ?? '',
      'hora_fim': horaFim?.format(context) ?? '',
    };
  }
}

class TurmaFormScreen extends StatelessWidget {
  final TurmaModel? turma;
  final String esporteId;
  final String categoria;

  const TurmaFormScreen({
    super.key,
    this.turma,
    required this.esporteId,
    required this.categoria,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TurmaFormCubit(
        context.read(),
        context.read(),
      )..loadInitialData(turma),
      child: _TurmaFormView(
        turma: turma,
        esporteId: esporteId,
        categoria: categoria,
      ),
    );
  }
}

class _TurmaFormView extends StatefulWidget {
  final TurmaModel? turma;
  final String esporteId;
  final String categoria;
  const _TurmaFormView(
      {this.turma, required this.esporteId, required this.categoria});

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

  void _initializeFields(TurmaModel turma) {
    _selectedProfessorId = turma.professor.id;
    _selectedAlunosIds = turma.alunos.map((a) => a.id).toList();
    _horarios = turma.horarios.map((h) {
      TimeOfDay? parseTime(String? timeStr) {
        if (timeStr == null || timeStr.isEmpty) return null;
        try {
          return TimeOfDay.fromDateTime(DateFormat.Hm().parse(timeStr));
        } catch (e) {
          return null;
        }
      }

      return Horario(
        diaSemana: h['dia_semana'],
        horaInicio: parseTime(h['hora_inicio']),
        horaFim: parseTime(h['hora_fim']),
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
      if (_selectedProfessorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Selecione um professor.'),
            backgroundColor: Colors.red));
        return;
      }
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
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Turma' : 'Nova Turma')),
      body: BlocConsumer<TurmaFormCubit, TurmaFormState>(
        listener: (context, state) {
          if (state is TurmaFormSuccess) {
            context.read<TurmaManagementCubit>().fetchTurmas(
                esporteId: widget.esporteId, categoria: widget.categoria);
            Navigator.of(context).pop();
          }
          if (state is TurmaFormFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is TurmaFormLoading || state is TurmaFormInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TurmaFormDataReady) {
            if (_isEditing &&
                !_fieldsInitialized &&
                state.turmaExistente != null) {
              _initializeFields(state.turmaExistente!);
            }
            return _buildForm(state.professores, state.alunos);
          }
          if (state is TurmaFormSubmitting) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(
              child: Text('Erro ao carregar dados do formulário.'));
        },
      ),
    );
  }

  Widget _buildForm(List<UserModel> professores, List<UserModel> alunos) {
    if (_isEditing && _selectedProfessorId != null) {
      bool professorJaNaLista =
      professores.any((p) => p.id == _selectedProfessorId);
      if (!professorJaNaLista && widget.turma != null) {
        final professorDaTurma = widget.turma!.professor;
        professores.insert(
            0,
            UserModel(
                id: professorDaTurma.id,
                nome: '${professorDaTurma.nome} (Inativo)',
                email: '',
                perfil: 'professor',
                ativo: false,
                statusPagamento: const StatusPagamento(status: 'N/A')));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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
                  .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome)))
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
                    icon: const Icon(Icons.add_circle, color: Colors.green),
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
                          if (time != null) {
                            setState(() => horario.horaInicio = time);
                          }
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
                          if (time != null) {
                            setState(() => horario.horaFim = time);
                          }
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
                  .map((a) => MultiSelectItem<String>(a.id, a.nome))
                  .toList(),
              initialValue: _selectedAlunosIds,
              title: const Text("Alunos"),
              buttonText: const Text("Selecionar Alunos da Turma"),
              onConfirm: (values) {
                setState(() => _selectedAlunosIds = values);
              },
              chipDisplay: MultiSelectChipDisplay(
                onTap: (value) =>
                    setState(() => _selectedAlunosIds.remove(value as String)),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(_isEditing ? 'Salvar Alterações' : 'Criar Turma'),
            ),
          ],
        ),
      ),
    );
  }
}

