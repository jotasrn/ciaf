import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:escolinha_futebol_app/core/models/user_model.dart';
import 'package:escolinha_futebol_app/features/admin_dashboard/cubit/user_management_cubit.dart';

class UserFormScreen extends StatefulWidget {
  final UserModel? user;
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
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
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<UserManagementCubit>();
      final userData = {
        'nome_completo': _nameController.text,
        'email': _emailController.text,
        'perfil': _selectedProfile,
        if (_passwordController.text.isNotEmpty) 'senha': _passwordController.text,
      };

      if (_isEditing) {
        cubit.updateUser(widget.user!.id, userData);
      } else {
        cubit.createUser(userData);
      }

      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Usuário' : 'Adicionar Novo Usuário'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome Completo'),
                    validator: (value) => value!.trim().isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty || !value.contains('@') ? 'E-mail inválido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: _isEditing ? 'Nova Senha (deixe em branco para não alterar)' : 'Senha',
                    ),
                    obscureText: true,
                    validator: (value) => !_isEditing && value!.trim().isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedProfile,
                    decoration: const InputDecoration(labelText: 'Perfil'),
                    items: ['aluno', 'professor', 'admin']
                        .map((label) => DropdownMenuItem(
                      value: label,
                      child: Text(label[0].toUpperCase() + label.substring(1)),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProfile = value;
                      });
                    },
                    validator: (value) => value == null ? 'Selecione um perfil' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(_isEditing ? 'Salvar Alterações' : 'Criar Usuário'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}