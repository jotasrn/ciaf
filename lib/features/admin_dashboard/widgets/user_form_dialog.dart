import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:escolinha_futebol_app/core/models/turma_model.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/core/repositories/turma_repository.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_cubit.dart';
import 'package:escolinha_futebol_app/app/widgets/custom_text_form_field.dart';


Future<void> showUserFormDialog({
  required BuildContext context,
  UserModel? user,
  List<String> perfisPermitidos = const ['admin', 'professor', 'aluno'],
}) async {
  final userManagementCubit = context.read<UserManagementCubit>();
  await showDialog(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: userManagementCubit,
      child: _UserFormDialogContent(user: user, perfisPermitidos: perfisPermitidos),
    ),
  );
}

class _UserFormDialogContent extends StatefulWidget {
  final UserModel? user;
  final List<String> perfisPermitidos;
  const _UserFormDialogContent({this.user, required this.perfisPermitidos});

  @override
  State<_UserFormDialogContent> createState() => _UserFormDialogContentState();
}

class _UserFormDialogContentState extends State<_UserFormDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  String? _selectedProfile;
  bool _showTurmasField = false; // Controla a visibilidade do campo de turmas

  List<TurmaModel> _turmasDisponiveis = [];
  List<String> _selectedTurmasIds = [];
  bool _carregandoTurmas = false;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.nomeCompleto ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _selectedProfile = widget.user?.perfil;

    if (_selectedProfile == 'professor') {
      _showTurmasField = true;
      _carregarTurmas();
    }
  }

  Future<void> _carregarTurmas() async {
    setState(() => _carregandoTurmas = true);
    try {
      final turmas = await context.read<TurmaRepository>().getTodasTurmas();
      if(mounted) {
        setState(() {
          _turmasDisponiveis = turmas;
          // TODO: Pré-selecionar turmas do professor no modo de edição
        });
      }
    } finally {
      if(mounted) {
        setState(() => _carregandoTurmas = false);
      }
    }
  }

  void _onProfileChanged(String? novoPerfil) {
    setState(() {
      _selectedProfile = novoPerfil;
      _showTurmasField = (novoPerfil == 'professor');
      if (_showTurmasField && _turmasDisponiveis.isEmpty) {
        _carregarTurmas();
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final userData = {
        'nome_completo': _nameController.text,
        'email': _emailController.text,
        'perfil': _selectedProfile,
        if (_passwordController.text.isNotEmpty) 'senha': _passwordController.text,
        if (_showTurmasField) 'turmas_ids': _selectedTurmasIds,
      };

      if (_isEditing) {
        context.read<UserManagementCubit>().updateUser(widget.user!.id, userData);
      } else {
        context.read<UserManagementCubit>().createUser(userData);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Editar Usuário' : 'Novo Usuário'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(controller: _nameController, label: 'Nome Completo', validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
                const SizedBox(height: 16),
                CustomTextFormField(controller: _emailController, label: 'E-mail', keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty || !v.contains('@') ? 'E-mail inválido' : null),
                const SizedBox(height: 16),
                CustomTextFormField(controller: _passwordController, label: _isEditing ? 'Nova Senha (opcional)' : 'Senha', obscureText: true, validator: (v) => !_isEditing && v!.isEmpty ? 'Campo obrigatório' : null),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedProfile,
                  decoration: const InputDecoration(labelText: 'Perfil'),
                  items: widget.perfisPermitidos.map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
                  onChanged: _onProfileChanged,
                  validator: (v) => v == null ? 'Selecione um perfil' : null,
                ),
                // Campo de turmas condicional
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Visibility(
                    visible: _showTurmasField,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: _carregandoTurmas
                          ? const Center(child: CircularProgressIndicator())
                          : MultiSelectDialogField<String>(
                        items: _turmasDisponiveis.map((t) => MultiSelectItem<String>(t.id, t.nome)).toList(),
                        initialValue: _selectedTurmasIds,
                        title: const Text("Vincular a Turmas"),
                        buttonText: const Text("Selecionar Turmas"),
                        onConfirm: (values) {
                          setState(() => _selectedTurmasIds = values);
                        },
                      ),
                    ),
                  ),
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