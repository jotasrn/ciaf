import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/app/widgets/custom_text_form_field.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_cubit.dart';

// Este é o nosso novo formulário em formato de diálogo
Future<void> showUserFormDialog({
  required BuildContext context,
  UserModel? user,
  // Novo parâmetro para controlar os perfis exibidos
  List<String> perfisPermitidos = const ['admin', 'professor', 'aluno'],
}) async {
  // Passa o Cubit existente para o diálogo
  final userManagementCubit = context.read<UserManagementCubit>();

  await showDialog(
    context: context,
    builder: (dialogContext) {
      // Usamos o BlocProvider.value para injetar o Cubit no diálogo
      return BlocProvider.value(
        value: userManagementCubit,
        child: _UserFormDialogContent(user: user, perfisPermitidos: perfisPermitidos),
      );
    },
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
  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.nome ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _selectedProfile = widget.user?.perfil;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final userData = {
        'nome_completo': _nameController.text,
        'email': _emailController.text,
        'perfil': _selectedProfile,
        if (_passwordController.text.isNotEmpty) 'senha': _passwordController.text,
      };

      if (_isEditing) {
        context.read<UserManagementCubit>().updateUser(widget.user!.id, userData);
      } else {
        context.read<UserManagementCubit>().createUser(userData);
      }
      Navigator.of(context).pop(); // Fecha o diálogo
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Editar Usuário' : 'Novo Usuário'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400, // Largura fixa para o modal
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  controller: _nameController,
                  label: 'Nome Completo',
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _emailController,
                  label: 'E-mail',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty || !v.contains('@') ? 'E-mail inválido' : null,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _passwordController,
                  label: _isEditing ? 'Nova Senha (opcional)' : 'Senha',
                  obscureText: true,
                  validator: (v) => !_isEditing && v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedProfile,
                  decoration: const InputDecoration(labelText: 'Perfil'),
                  // USA A LISTA DE PERFIS PERMITIDOS
                  items: widget.perfisPermitidos.map((label) => DropdownMenuItem(
                    value: label,
                    child: Text(label),
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedProfile = value),
                  validator: (v) => v == null ? 'Selecione um perfil' : null,
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