import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_cubit.dart';
import 'package:escolinha_futebol_app/main.dart';

Future<void> showAlunoFormDialog({
  required BuildContext context,
  UserModel? aluno,
}) async {
  // Passa o UserManagementCubit principal para o diálogo
  final userManagementCubit = context.read<UserManagementCubit>();

  await showDialog(
    context: context,
    // Garante que o diálogo use o Cubit da tela que o chamou
    builder: (dialogContext) => BlocProvider.value(
      value: userManagementCubit,
      child: _AlunoFormDialogContent(aluno: aluno),
    ),
  );
}

class _AlunoFormDialogContent extends StatefulWidget {
  final UserModel? aluno;
  const _AlunoFormDialogContent({this.aluno});

  @override
  State<_AlunoFormDialogContent> createState() => _AlunoFormDialogContentState();
}

class _AlunoFormDialogContentState extends State<_AlunoFormDialogContent> {
  final _formKey = GlobalKey<FormState>();
  // Controladores para todos os campos
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _nascimentoController = TextEditingController();
  final _matriculaController = TextEditingController();
  final _respNomeController = TextEditingController();
  final _respCpfController = TextEditingController();
  final _respTelefoneController = TextEditingController();

  String? _selectedTurmaId;
  DateTime? _dataNascimento;
  bool _isMenorDeIdade = false;
  bool get _isEditing => widget.aluno != null;

  // Listas e flags para dados assíncronos
  List<TurmaModel> _turmasDisponiveis = [];
  bool _carregandoDados = true;

  // Máscaras para os campos
  final _cpfMask = MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final _telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    try {
      final turmas = await context.read<TurmaRepository>().getTodasTurmas();
      if (mounted) {
        setState(() {
          _turmasDisponiveis = turmas;
          // Preenche os campos se estiver no modo de edição
          if (_isEditing && widget.aluno != null) {
            _preencherCamposParaEdicao(widget.aluno!);
          } else {
            _matriculaController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
          }
          _carregandoDados = false;
        });
      }
    } catch (e) {
      if(mounted) {
        setState(() => _carregandoDados = false);
        // Mostrar um erro
      }
    }
  }

  void _preencherCamposParaEdicao(UserModel aluno) {
    _nomeController.text = aluno.nome;
    _emailController.text = aluno.email;

    if (aluno.dataNascimento != null) {
      _checkIdade(aluno.dataNascimento!);
    }
    if (aluno.dataMatricula != null) {
      _matriculaController.text = DateFormat('dd/MM/yyyy').format(aluno.dataMatricula!);
    }
    if (aluno.contatoResponsavel != null) {
      _respNomeController.text = aluno.contatoResponsavel!['nome'] ?? '';
      _respCpfController.text = _cpfMask.maskText(aluno.contatoResponsavel!['cpf'] ?? '');
      _respTelefoneController.text = _telefoneMask.maskText(aluno.contatoResponsavel!['telefone'] ?? '');
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _nascimentoController.dispose();
    _matriculaController.dispose();
    _respNomeController.dispose();
    _respCpfController.dispose();
    _respTelefoneController.dispose();
    super.dispose();
  }

  void _checkIdade(DateTime dataNascimento) {
    setState(() {
      _dataNascimento = dataNascimento;
      _nascimentoController.text = DateFormat('dd/MM/yyyy').format(dataNascimento);
      final idade = DateTime.now().difference(dataNascimento).inDays / 365.25;
      _isMenorDeIdade = idade < 18;
    });
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final dadosAluno = {
        'nome_completo': _nomeController.text,
        'email': _emailController.text,
        'perfil': 'aluno',
        'data_nascimento': _dataNascimento!.toIso8601String(),
        'data_matricula': DateFormat('dd/MM/yyyy').parse(_matriculaController.text).toIso8601String(),
        if (!_isEditing) 'senha': 'senhaPadrao123',
        if (_isMenorDeIdade)
          'contato_responsavel': {
            'nome': _respNomeController.text,
            'cpf': _cpfMask.getUnmaskedText(),
            'telefone': _telefoneMask.getUnmaskedText(),
          },
        // Envia o ID da turma selecionada (pode ser nulo)
        'turma_id': _selectedTurmaId,
      };

      if (_isEditing) {
        context.read<UserManagementCubit>().updateUser(widget.aluno!.id, dadosAluno);
      } else {
        context.read<UserManagementCubit>().createUser(dadosAluno);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Editar Aluno' : 'Novo Aluno'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: _carregandoDados
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome Completo do Aluno'), validator: (v) => v!.trim().isEmpty ? 'Campo obrigatório' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-mail do Aluno'), validator: (v) => v!.isEmpty || !v.contains('@') ? 'E-mail inválido' : null),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nascimentoController,
                  decoration: const InputDecoration(labelText: 'Data de Nascimento'),
                  readOnly: true,
                  onTap: () async {
                    final data = await showDatePicker(context: context, initialDate: _dataNascimento ?? DateTime(DateTime.now().year - 10), firstDate: DateTime(1950), lastDate: DateTime.now());
                    if(data != null) _checkIdade(data);
                  },
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedTurmaId,
                  decoration: const InputDecoration(labelText: 'Vincular a uma Turma (Opcional)'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Nenhuma')),
                    ..._turmasDisponiveis.map((turma) => DropdownMenuItem(value: turma.id, child: Text(turma.nome))),
                  ],
                  onChanged: (value) => setState(() => _selectedTurmaId = value),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Visibility(
                    visible: _isMenorDeIdade,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 32),
                        Text('Dados do Responsável', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        TextFormField(controller: _respNomeController, decoration: const InputDecoration(labelText: 'Nome do Responsável'), validator: (v) => _isMenorDeIdade && v!.trim().isEmpty ? 'Campo obrigatório' : null),
                        const SizedBox(height: 16),
                        TextFormField(controller: _respCpfController, decoration: const InputDecoration(labelText: 'CPF do Responsável'), inputFormatters: [_cpfMask], validator: (v) => _isMenorDeIdade && _cpfMask.getUnmaskedText().length != 11 ? 'CPF inválido' : null),
                        const SizedBox(height: 16),
                        TextFormField(controller: _respTelefoneController, decoration: const InputDecoration(labelText: 'Telefone do Responsável'), inputFormatters: [_telefoneMask], validator: (v) => _isMenorDeIdade && _telefoneMask.getUnmaskedText().length < 10 ? 'Telefone inválido' : null),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 32),
                TextFormField(
                  controller: _matriculaController,
                  decoration: const InputDecoration(labelText: 'Data da Matrícula'),
                  readOnly: true,
                  onTap: () async { /* Pode implementar um date picker aqui também */ },
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _submitForm, child: Text(_isEditing ? 'Salvar' : 'Criar')),
      ],
    );
  }
}