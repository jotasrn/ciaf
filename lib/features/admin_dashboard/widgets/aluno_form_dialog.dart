import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/core/repositories/user_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_form_cubit.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/turma_form_state.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_cubit.dart';
import 'package:escolinha_futebol_app/main.dart'; // Importa a navigatorKey

// A função que exibe o diálogo
Future<void> showAlunoFormDialog({
  required BuildContext context,
  UserModel? aluno,
}) async {
  // Passa o UserManagementCubit principal para o diálogo
  final userManagementCubit = context.read<UserManagementCubit>();

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: userManagementCubit,
        child: _AlunoFormDialogContent(aluno: aluno),
      );
    },
  );
}

// O conteúdo interno do diálogo
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

  DateTime? _dataNascimento;
  bool _isMenorDeIdade = false;
  bool get _isEditing => widget.aluno != null;

  // Máscaras para os campos
  final _cpfMask = MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final _telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  @override
  void initState() {
    super.initState();
    // Preenche com a data atual por padrão
    _matriculaController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Se estiver editando, preenche todos os campos com os dados existentes
    if (_isEditing && widget.aluno != null) {
      final aluno = widget.aluno!;
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
        // A senha só é enviada na criação de um usuário que não está sendo editado
        if (!_isEditing) 'senha': 'senhaPadrao123',
        if (_isMenorDeIdade)
          'contato_responsavel': {
            'nome': _respNomeController.text,
            'cpf': _cpfMask.getUnmaskedText(),
            'telefone': _telefoneMask.getUnmaskedText(),
          }
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome Completo do Aluno'),
                  validator: (value) => value!.trim().isEmpty ? 'Por favor, insira o nome.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-mail do Aluno'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty || !value.contains('@') ? 'Por favor, insira um e-mail válido.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nascimentoController,
                  decoration: const InputDecoration(labelText: 'Data de Nascimento', hintText: 'DD/MM/AAAA'),
                  readOnly: true,
                  onTap: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: _dataNascimento ?? DateTime(DateTime.now().year - 10),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if(data != null) _checkIdade(data);
                  },
                  validator: (value) => value!.isEmpty ? 'Selecione a data de nascimento.' : null,
                ),
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Visibility(
                    visible: _isMenorDeIdade,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 32),
                        Text('Dados do Responsável (Obrigatório para menores)', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _respNomeController,
                          decoration: const InputDecoration(labelText: 'Nome Completo do Responsável'),
                          validator: (value) => _isMenorDeIdade && value!.trim().isEmpty ? 'Campo obrigatório para menores.' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _respCpfController,
                          decoration: const InputDecoration(labelText: 'CPF do Responsável'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [_cpfMask],
                          validator: (value) => _isMenorDeIdade && _cpfMask.getUnmaskedText().length != 11 ? 'CPF inválido.' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _respTelefoneController,
                          decoration: const InputDecoration(labelText: 'Telefone do Responsável'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [_telefoneMask],
                          validator: (value) => _isMenorDeIdade && _telefoneMask.getUnmaskedText().length < 10 ? 'Telefone inválido.' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 32),
                TextFormField(
                  controller: _matriculaController,
                  decoration: const InputDecoration(labelText: 'Data da Matrícula'),
                  readOnly: true,
                  onTap: () async { /* TODO: Lógica para selecionar data de matrícula */ },
                  validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
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